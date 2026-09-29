extends Button

# Reference to the container holding Start and Quit buttons
@onready var main_buttons_container: Control = $"../.."
@onready var button_sound: AudioStreamPlayer2D = $"../ButtonSFX"

func _ready() -> void:
	pressed.connect(_on_start_pressed)
	Events.game_finished.connect(_on_game_finished)

func _on_start_pressed() -> void:
	# Inform the game that gameplay has officially started
	Events.is_game_started = true
	Events.game_started.emit()
	
	button_sound.play()
	await get_tree().create_timer(0.2).timeout
	
	# Delete Start and Quit buttons
	#if is_instance_valid(main_buttons_container):
	#	main_buttons_container.queue_free()
	# (Changed to be able to resume the menu later)
	if is_instance_valid(main_buttons_container):
		main_buttons_container.hide()

func _on_game_finished() -> void:
	await Events.animation_finished
	Events.is_game_started = false
	# Resume main menu:
	if is_instance_valid(main_buttons_container):
		main_buttons_container.show()
