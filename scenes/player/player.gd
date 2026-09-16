extends CharacterBody2D

@export var animation: AnimatedSprite2D

const MAX_JUMPS = 1

var _speed: float = 150.0
var _jump_speed: float = -300.0
var _jumps_left: int = MAX_JUMPS
var _can_wall_jump: bool = true
var _current_slide_speed: float = 80.0  # Default value


func _physics_process(delta: float):
	# Get the directional input (-1, 1)
	var input_dir = Input.get_axis("left", "right")
	
	# Gravity
	velocity += get_gravity() * delta
	
	# Horizontal movement
	if Input.is_action_pressed("left"):
		velocity.x = -(_speed)
		animation.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = _speed
		animation.flip_h = false
	else:
		velocity.x = 0
	
	# Double jump // Wall jump
	if is_on_floor():
		_jumps_left = MAX_JUMPS
		_can_wall_jump = true
	elif is_on_wall():
		if _can_wall_jump:
			_jumps_left = 1
	else:
		_can_wall_jump = true
	
	# Regular Jump and Wall jump reset
	if Input.is_action_just_pressed("jump") and _jumps_left > 0:
		velocity.y = _jump_speed
		_jumps_left -= 1
		if is_on_wall():
			_can_wall_jump = false
		elif not is_on_floor():
			animation.play("DoubleJump")
	
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

# A function to get how "frictional" (XD) is an specific tile.
func _custom_friction():
	if is_on_wall():
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Check if collider is a tile
			if collider is TileMapLayer:
				var hit_pos = collision.get_position() - collision.get_normal() 
				var tile_coord = collider.local_to_map(collider.to_local(hit_pos))
				var tile_data = collider.get_cell_tile_data(tile_coord)
				
				if tile_data:
					var custom_speed = tile_data.get_custom_data("friction")
					if custom_speed != null:
						_current_slide_speed = custom_speed
						break
