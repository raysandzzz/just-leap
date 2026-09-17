extends Area2D

@export var animation: AnimatedSprite2D

var _counter = 1

func _on_body_entered(_body: Node2D):
	if _counter > 0:
		animation.play("Pressed")
		_counter -= 1
	else:
		pass
