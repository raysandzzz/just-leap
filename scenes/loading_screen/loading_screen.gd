extends CanvasLayer


# The path to your heavy MainScene
var next_scene_path: String = "res://scenes/main_scene/main_scene.tscn"

func _ready() -> void:
	# Request Godot to load the heavy scene in a background thread
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(_delta: float) -> void:
	# Check the status of the background loading every frame
	var load_status: int = ResourceLoader.load_threaded_get_status(next_scene_path)
	
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		# The scene and all its PackedScenes are fully loaded in RAM
		# Now we can transition safely without freezes
		var loaded_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(loaded_scene)
		
		# Optional: Turn off _process to prevent running this twice in the exact same frame
		set_process(false)
		
	elif load_status == ResourceLoader.THREAD_LOAD_FAILED:
		# Handle the error if the path is wrong
		printerr("Failed to load MainScene!")
		set_process(false)
