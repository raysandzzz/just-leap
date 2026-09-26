extends Camera2D

func _ready() -> void:
	# Ensure the camera is centered on the player at start
	position = Vector2.ZERO
	
	# Force this camera to take control over any previous or main scene camera
	enabled = true
	make_current()
	
	# Reset smoothing to prevent initial lerp drift
	reset_smoothing()
