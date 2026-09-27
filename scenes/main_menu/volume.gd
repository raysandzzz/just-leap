extends Button # Use CheckButton, TextureButton or Button depending on your node

# Bus name configured in the Audio panel
@export var music_bus_name: String = "Music"

var _bus_index: int

func _ready() -> void:
	# Fetch bus index from AudioServer
	_bus_index = AudioServer.get_bus_index(music_bus_name)
	
	# Make sure it acts as a toggle button
	toggle_mode = true
	
	# Default state: button unpressed (showing active volume icon) and music unmuted
	button_pressed = false
	AudioServer.set_bus_mute(_bus_index, false)
	
	# Connect toggle event
	toggled.connect(_on_toggled)

func _on_toggled(is_muted: bool) -> void:
	# When button is toggled ON -> mute music
	# When button is toggled OFF -> play music
	AudioServer.set_bus_mute(_bus_index, is_muted)
