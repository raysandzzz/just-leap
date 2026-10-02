extends Button

@onready var volume_slider: HSlider = $"../VolumeSlider"

# Bus name configured in the Audio panel
@export var music_bus_name: String = "Master"

var _bus_index: int

func _ready() -> void:
	# Fetch bus index from AudioServer
	_bus_index = AudioServer.get_bus_index(music_bus_name)
	
	# Make sure it acts as a toggle button
	toggle_mode = true
	
	# Connect toggle event
	toggled.connect(_on_toggled)
	
	# Connect signal safely to avoid duplicate connections
	if not volume_slider.value_changed.is_connected(_on_volume_slider_value_changed):
		volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	
	# Sync when it becomes visible (e.g. when opening pause menu)
	visibility_changed.connect(_on_visibility_changed)
	
	# Synchronize slider and icon state with the actual audio server on load
	_sync_with_audio_server()

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_sync_with_audio_server()

func _sync_with_audio_server() -> void:
	# Block signals temporarily to prevent triggering value_changed during initialization
	volume_slider.set_block_signals(true)
	
	# Check the actual server state instead of forcing defaults
	var is_muted = AudioServer.is_bus_mute(_bus_index)
	
	if is_muted:
		volume_slider.value = 0.0
		set_pressed_no_signal(false) # Shows muted icon state WITHOUT triggering _on_toggled
	else:
		var db_volume = AudioServer.get_bus_volume_db(_bus_index)
		volume_slider.value = db_to_linear(db_volume)
		set_pressed_no_signal(true)  # Shows active icon state WITHOUT triggering _on_toggled
		
	volume_slider.set_block_signals(false)

func _on_toggled(is_enabled: bool) -> void:
	# When button is toggled ON (pressed = true) -> unmuted / active volume
	# When button is toggled OFF (pressed = false) -> muted
	AudioServer.set_bus_mute(_bus_index, !is_enabled)
	
	# Block slider signals to avoid firing _on_volume_slider_value_changed and causing a loop
	volume_slider.set_block_signals(true)
	if is_enabled and volume_slider.value <= 0.0:
		volume_slider.value = 0.5 # Restore a default level if unmuting from zero
		AudioServer.set_bus_volume_db(_bus_index, linear_to_db(0.5)) # Force audio server to match the 0.5 change
	elif not is_enabled:
		volume_slider.value = 0.0
	volume_slider.set_block_signals(false)

func _on_volume_slider_value_changed(value: float) -> void:
	_bus_index = AudioServer.get_bus_index(music_bus_name)
	
	if value <= 0.0:
		AudioServer.set_bus_mute(_bus_index, true)
		set_pressed_no_signal(false) # Updates visual button state WITHOUT triggering _on_toggled
	else:
		AudioServer.set_bus_mute(_bus_index, false)
		AudioServer.set_bus_volume_db(_bus_index, linear_to_db(value))
		set_pressed_no_signal(true) # Updates visual button state WITHOUT triggering _on_toggled
	
	_update_icon(value)

func _update_icon(value: float) -> void:
	if value <= 0.0:
		toggle_mode = true
		set_pressed_no_signal(false)
	else:
		set_pressed_no_signal(true)
