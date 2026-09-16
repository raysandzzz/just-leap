extends Area2D

@export var animation: AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	animation.play("FlagOut")
	if animation.animation_finished:
		animation.play("Flag")
