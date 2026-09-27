extends Button

# Reference to the container holding Start and Quit buttons
@onready var main_buttons_container: Control = $"../.."
@onready var button_sound: AudioStreamPlayer2D = $"../ButtonSFX"

func _ready() -> void:
	pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	# Inform the game that gameplay has officially started
	Events.game_started.emit()
	Events.is_game_started = true
	
	button_sound.play()
	await get_tree().create_timer(0.2).timeout
	
	# Delete Start and Quit buttons
	if is_instance_valid(main_buttons_container):
		main_buttons_container.queue_free()
