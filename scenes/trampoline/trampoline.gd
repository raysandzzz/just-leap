extends Area2D

@export var bounce_force: float = 450.0
@onready var trampo_animation: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	trampo_animation.play("Idle")

func _on_body_entered(body: Node2D) -> void:
	# Only bounce when the player is moving downwards onto the trampoline
	if body.has_method("bounce") and body.velocity.y >= 0.0:
		body.bounce(bounce_force)
		
		# Play spring launch animation and return to idle state
		trampo_animation.play("Jump")
		await trampo_animation.animation_finished
		trampo_animation.play("Idle")
