extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.material.set_shader_parameter("progress", 1.0)

func close_circle(duration: float = 0.8) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(
		color_rect.material, 
		"shader_parameter/progress", 
		0.0, 
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished

func open_circle(duration: float = 0.8) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(
		color_rect.material, 
		"shader_parameter/progress", 
		1.0, 
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished

func transition_to_scene(target_scene_path: String, duration: float = 0.8) -> void:
	await close_circle(duration)
	get_tree().change_scene_to_file(target_scene_path)
	await open_circle(duration)
