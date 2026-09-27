extends Button

@onready var button_sound: AudioStreamPlayer2D = $"../ButtonSFX"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_exit)

func _exit():
	button_sound.play()
	await get_tree().create_timer(0.2).timeout
	
	get_tree().quit()
