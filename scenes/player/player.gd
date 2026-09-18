extends CharacterBody2D

signal player_dead

@export var animation: AnimatedSprite2D

const MAX_JUMPS: int = 1
const DEFAULT_SPEED: float = 150.0

var _speed: float = DEFAULT_SPEED
var _current_floor_speed: float = DEFAULT_SPEED
var _jump_speed: float = -300.0
var _jumps_left: int = MAX_JUMPS
var _can_wall_jump: bool = true
var _current_slide_speed: float = 80.0  # Default value
var _controls_locked: bool = false
var _dead: bool = false

func _ready() -> void:
	add_to_group("players")
	Events.trophy_activate.connect(_on_level_finished)
	Events.time_over.connect(_time_over)

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
	
	# Var 'normalized' to detect if the player is close to the wall
	var normalized = get_wall_normal()
	
	# A verif var to create a 'friction' feeling while climbing
	var is_pressing_against_wall = is_on_wall() && (input_dir * normalized.x) < 0
	
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
			animation.offset.x = -2.0
		elif normalized.x < 0:
			animation.offset.x = 2.0
		else:
			animation.offset.x = 0.0
	else:
		animation.play("Idle")

func _horizontal_movement():
	if Input.is_action_pressed("left"):
		velocity.x = -(_current_floor_speed)
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
		elif is_on_wall():
			if _can_wall_jump:
				_jumps_left = 1
		else:
			_can_wall_jump = true

func _regular_jump():
	if Input.is_action_just_pressed("jump") and _jumps_left > 0:
		velocity.y = _jump_speed
		_jumps_left -= 1
		if is_on_wall():
			_can_wall_jump = false
		elif not is_on_floor():
			animation.play("DoubleJump")

func _on_level_finished() -> void:
	_controls_locked = true
	velocity.x = 0
	animation.play("Fall")
	animation.pause()
	await get_tree().create_timer(2.0).timeout
	animation.play("Vanish")
	await animation.animation_finished
	await Transition.close_circle(0.8)
	Events.level_finished.emit()

func _time_over() -> void:
	_dead = true
	_controls_locked = true
	velocity.x = 0
	animation.play("Explosion")
	await animation.animation_finished
	await Transition.close_circle(0.8)
	player_dead.emit()

func kill_player():
	animation.modulate = Color(155.0, 0.0, 0.0, 1.0)
	_dead = true
	animation.stop()
	await get_tree().create_timer(0.5).timeout
	player_dead.emit()


# A function to get how "frictional" (XD) is a specific tile (wall or floor).
func _custom_friction():
	_current_floor_speed = _speed # Speed reset
	
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
				
				# FLOOR FRICTION (read the custom data layer from the floor)
				if is_on_floor() and collision.get_normal().y < -0.5:
					var floor_friction = tile_data.get_custom_data("floor_friction")
					if floor_friction != null and floor_friction > 0.0:
						_current_floor_speed = floor_friction
