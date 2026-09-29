extends Area2D

@export var animation: AnimatedSprite2D
@export var flag_sound: AudioStreamPlayer2D

var _counter = 1

func _on_body_entered(_body: Node2D):
	if _counter > 0:
		_counter -= 1
		Events.is_flag_active = true
		Events.flag_activate.emit()
		animation.play("FlagOut")
		flag_sound.play()
		await animation.animation_finished
		animation.play("Flag")
