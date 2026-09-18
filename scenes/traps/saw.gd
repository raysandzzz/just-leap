extends Area2D

@onready var saw_animation: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if not Events.spawn_finished.is_connected(_resume_animation):
		Events.spawn_finished.connect(_resume_animation)
	
	if not Events.player_killed.is_connected(_stop_animation):
		Events.player_killed.connect(_stop_animation)
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill_player"):
		body.kill_player()

func _stop_animation():
	if saw_animation:
		saw_animation.stop()

func _resume_animation() -> void:
	if saw_animation:
		saw_animation.play("On")
