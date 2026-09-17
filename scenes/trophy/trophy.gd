extends Area2D

@export var animation: AnimatedSprite2D


func _on_body_entered(_body: Node2D):
	# If player already pressed the trophy, return
	if Events.trophy_was_pressed:
		return
		
	if Events.is_flag_active:
		press_trophy()

func press_trophy():
	animation.play("Pressed")
	Events.trophy_was_pressed = true
	Events.trophy_activate.emit()
	# Here the congrats logic and more xd
