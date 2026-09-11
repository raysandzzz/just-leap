extends CharacterBody2D

@export var animation: AnimatedSprite2D

const MAX_JUMPS = 2

var _speed: float = 150.0
var _jump_speed: float = -320.0
var _jumps_left: int = MAX_JUMPS

func _physics_process(delta: float):
	# Gravity
	velocity += get_gravity() * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = _jump_speed
	
	# Horizontal movement
	if Input.is_action_pressed("left"):
		velocity.x = -(_speed)
		animation.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = _speed
		animation.flip_h = false	
	else:
		velocity.x = 0
	
	# Double jump
	if is_on_floor():
		_jumps_left = MAX_JUMPS
	if Input.is_action_just_pressed("jump") && _jumps_left > 0:
		velocity.y = _jump_speed
		_jumps_left -= 1
	
	move_and_slide()
	
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
