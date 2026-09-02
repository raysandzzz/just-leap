extends CharacterBody2D

@export var animation: AnimatedSprite2D

var _speed: float = 200.0
var _jump_speed: float = -320.0

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
	
	# Animation
	if !is_on_floor():
		animation.play("Fall")
	elif velocity.x != 0:
		animation.play("Run")
	else:
		animation.play("Idle")
	
	move_and_slide()
