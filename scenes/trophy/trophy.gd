extends Area2D

@export var animation: AnimatedSprite2D
@export var trophy_sound: AudioStreamPlayer2D

func _ready():
	Events.trophy_was_pressed = false
	if not Events.flag_activate.is_connected(_on_flag_activated):
		Events.flag_activate.connect(_on_flag_activated)

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
	trophy_sound.play()

func _on_flag_activated():
	animation.play("FlagDetected")
	await animation.animation_finished
	animation.play("Active")
