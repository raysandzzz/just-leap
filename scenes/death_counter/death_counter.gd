extends Control

@export var label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalCounter.update_death_counter.connect(_update_text)


func _update_text():
	label.text = str(GlobalCounter.deaths)
