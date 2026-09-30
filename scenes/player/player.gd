extends CharacterBody2D

signal player_dead

@export var animation: AnimatedSprite2D

@onready var camera: Camera2D = get_node_or_null("Camera2D")

@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var footsteps_sound: AudioStreamPlayer = $FootstepsSound
@onready var dead_sound: AudioStreamPlayer = $DeadSound
@onready var tele_sound: AudioStreamPlayer = $TeleportSound
@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound

const MAX_JUMPS: int = 1
const DEFAULT_SPEED: float = 125.0

var _speed: float = DEFAULT_SPEED
var _current_floor_speed: float = DEFAULT_SPEED
var _jump_speed: float = -270.0
var _jumps_left: int = MAX_JUMPS
var _can_wall_jump: bool = true
var _current_slide_speed: float = 80.0  # Default value
var _controls_locked: bool = false
var _dead: bool = false
var _is_wall_unclimbable: bool = false
var _has_left_wall: bool = true
var _is_bouncing_x: bool = false
var _is_stepping: bool = false

func _ready() -> void:
	# Force to use the inner Camera2D in player instance
	# Only if it exists, else general Camera2D from MainScene will be used
	if camera:
		camera.make_current()
	
	# Keep player still while spawning
	_controls_locked = true
	velocity = Vector2.ZERO
	
	# Connect to start appearing once the transition finishes opening
	Transition.transition_finished.connect(play_appear_sequence, CONNECT_ONE_SHOT)
	add_to_group("players")
	Events.trophy_activate.connect(_on_level_finished)
	
	# Time_over signal connected to _time_over function, that's it XD
	Events.time_over.connect(_time_over)
	
	# If the dialogue started, lock controls, else return
	Events.dialogue_started.connect(lock_movement)
	Events.dialogue_finished.connect(unlock_movement)
	
	Events.game_started.connect(play_appear_sequence)

func _physics_process(delta: float):
	# Get the directional input (-1, 1)
	var input_dir = Input.get_axis("left", "right")
	
	if _controls_locked || _dead:
		return
	
	# Gravity
	velocity += get_gravity() * delta
	
	
	# Horizontal movement
	_horizontal_movement()
	
	# Double jump // Wall jump
	_doublewall_jump()
	
	# Regular Jump and Wall jump reset
	_regular_jump()
	
	move_and_slide()
	
	_handle_footsteps_input()
	
	# Var 'normalized' to detect if the player is close to the wall
	var normalized = get_wall_normal()
	
	# A verif var to create a 'friction' feeling while climbing
	var is_pressing_against_wall = is_on_wall() && (input_dir * normalized.x) < 0 && not _is_wall_unclimbable
	
	_custom_friction()
	
	# If it is falling (velocity.y > 0), we limit the fall to the friction velocity.
	if is_pressing_against_wall && !is_on_floor():
		if velocity.y > 0:
			velocity.y = min(velocity.y, _current_slide_speed)
	
	# Animation
	if !is_on_floor() && !is_on_wall():
		if animation.animation != "DoubleJump":
			animation.play("Fall")
	elif velocity.x != 0:
		animation.play("Run")
	elif is_on_wall() && !is_on_floor():
		animation.play("Wall")
		if normalized.x > 0:
			animation.offset.x = -0.5
		elif normalized.x < 0:
			animation.offset.x = 0.2
		else:
			animation.offset.x = 0.0
	else:
		animation.play("Idle")


func _horizontal_movement():
	# Direct digital movement without inertia or momentum preservation
	if Input.is_action_pressed("left"):
		velocity.x = -_current_floor_speed
		animation.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = _current_floor_speed
		animation.flip_h = false
	else:
		velocity.x = 0

func _doublewall_jump():
	if is_on_floor():
		_jumps_left = MAX_JUMPS
		_can_wall_jump = true
		_has_left_wall = true
	elif is_on_wall():
		# Only grant wall jump if the player has detached from the wall first
		if _can_wall_jump and _has_left_wall and not _is_wall_unclimbable:
			_jumps_left = 1
	else:
		# Player is airborne and away from the wall; re-enable wall attachment
		_has_left_wall = true

func _regular_jump():
	if Input.is_action_just_pressed("jump") and _jumps_left > 0:
		velocity.y = _jump_speed
		jump_sound.play()
		_jumps_left -= 1
		if is_on_wall():
			# Lock wall jump refills until the player detaches in the air
			_has_left_wall = false
		elif not is_on_floor():
			animation.play("DoubleJump")

func _on_level_finished() -> void:
	_controls_locked = true
	velocity.x = 0
	animation.play("Fall")
	animation.pause()
	await get_tree().create_timer(2.0).timeout
	animation.play("Vanish")
	tele_sound.play()
	await animation.animation_finished
	await Transition.close_circle(0.8)
	Events.level_finished.emit()

func _time_over() -> void:
	_dead = true
	_controls_locked = true
	velocity.x = 0
	animation.play("Explosion")
	explosion_sound.play()
	await animation.animation_finished
	await Transition.close_circle(0.8)
	GlobalCounter.add_death()
	player_dead.emit()

func kill_player():
	dead_sound.play()
	Events.player_killed.emit()
	
	animation.modulate = Color(155.0, 0.0, 0.0, 1.0)
	_dead = true
	animation.stop()
	
	await get_tree().create_timer(0.5).timeout
	GlobalCounter.add_death()
	player_dead.emit()

func play_appear_sequence() -> void:
	await get_tree().create_timer(0.5).timeout
	
	animation.play("Appear")
	tele_sound.play()
	await animation.animation_finished
	_controls_locked = false
	Events.spawn_finished.emit()

# This function connect the trampoline script with player
# And this way we can give the player an extra jump when he bounces haha
func bounce(force: float):
	# Override vertical velocity directly to cancel fall momentum
	velocity.y = -force
	# Reset the jump and play an expected animation in this kind of mechanic :)
	_jumps_left = 1
	animation.play("Fall")

func lock_movement():
	_controls_locked = true
	animation.play("Idle")

func unlock_movement():
	_controls_locked = false

# A function to get how "frictional" (XD) is a specific tile (wall or floor).
func _custom_friction():
	_current_floor_speed = _speed # Speed reset
	_is_wall_unclimbable = false # Reset
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var hit_pos = collision.get_position() - collision.get_normal()
			var tile_coord = collider.local_to_map(collider.to_local(hit_pos))
			var tile_data = collider.get_cell_tile_data(tile_coord)
			
			if tile_data:
				# WALL FRICTION
				if is_on_wall():
					var wall_friction = tile_data.get_custom_data("friction")
					if wall_friction != null:
						_current_slide_speed = wall_friction
					# Detect if wall is climbable.
					var unclimbable = tile_data.get_custom_data("unclimbable")
					if unclimbable != null and unclimbable == true:
						_is_wall_unclimbable = true
					
				# FLOOR FRICTION (read the custom data layer from the floor)
				if is_on_floor() and collision.get_normal().y < -0.5:
					var floor_friction = tile_data.get_custom_data("floor_friction")
					if floor_friction != null and floor_friction > 0.0:
						_current_floor_speed = floor_friction

# All next 3 functions to manage the footsteps sfx correctly

func _on_animated_sprite_2d_frame_changed() -> void:
	if animation.animation == "Run" and is_on_floor():
		# Trigger only on the specific contact frames
		if animation.frame == 3 or animation.frame == 9:
			_play_footstep()

func _handle_footsteps_input() -> void:
	if is_on_floor() and abs(velocity.x) > 10.0:
		if not _is_stepping:
			# Play instant sound on first movement tap without waiting for animation frame
			_is_stepping = true
			_play_footstep()
	else:
		# Reset trigger when stationary or in the air
		_is_stepping = false

func _play_footstep() -> void:
	# Random pitch variation to prevent audio fatigue
	footsteps_sound.pitch_scale = randf_range(0.9, 1.1)
	footsteps_sound.play()
