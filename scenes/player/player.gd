extends CharacterBody2D

@export var animation: AnimatedSprite2D

const MAX_JUMPS = 2

var _speed: float = 150.0
var _jump_speed: float = -320.0
var _jumps_left: int = MAX_JUMPS
var _can_wall_jump: bool = true

func _physics_process(delta: float):
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
		if _jumps_left == MAX_JUMPS:
			_jumps_left = 1
	
	# Regular Jump and Wall jump reset
	if Input.is_action_just_pressed("jump") and _jumps_left > 0:
		velocity.y = _jump_speed
		_jumps_left -= 1
		if is_on_wall():
			_can_wall_jump = false
	
	
	move_and_slide()
	
	# Var 'normalized' to detect if the player is close to the wall
	var normalized = get_wall_normal()
	
	# Animation
	if !is_on_floor() && !is_on_wall() && _jumps_left > 0:
		animation.play("Fall")
	elif !is_on_floor() && _jumps_left == 0:
		animation.play("DoubleJump")
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
