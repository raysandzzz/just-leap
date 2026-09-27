extends HSlider

# Audio bus name configured in the Audio panel
@export var music_bus_name: String = "Music"

var _bus_index: int

func _ready() -> void:
	# Fetch target audio bus index
	_bus_index = AudioServer.get_bus_index(music_bus_name)
	
	# Synchronize slider position with current bus volume (convert dB to linear 0.0 - 1.0)
	var current_db: float = AudioServer.get_bus_volume_db(_bus_index)
	value = db_to_linear(current_db)
	
	# Listen to slider value changes
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
	# Convert linear value (0.0 - 1.0) to decibels
	var db_value: float = linear_to_db(new_value)
	
	# Apply converted volume to the target bus
	AudioServer.set_bus_volume_db(_bus_index, db_value)
	
	# Mute completely if slider reaches absolute zero to save audio processing
	AudioServer.set_bus_mute(_bus_index, new_value == 0.0)
