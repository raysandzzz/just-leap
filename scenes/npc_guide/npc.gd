extends Area2D

# Array which contains the NPC's dialogues
@export var dialogue_lines: Array[String] = [
	"[wave amp=30.0 freq=5.0 connected=1]Use A/D to run and Space to jump.[/wave]",
	"[wave amp=30.0 freq=5.0 connected=1]Collect the flag to unlock the trophy![/wave]",
	"[wave amp=35.0 freq=6.0 connected=1]Be fast, the clock is ticking![/wave]"
]

@onready var prompt_label: Label = $PromptLabel
@onready var dialogue_label: RichTextLabel = $Marker2D/Dialogues
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var dialogue_sound: AudioStreamPlayer2D

var _can_interact: bool = false
var _is_talking: bool = false
var _current_index: int = 0

func _ready() -> void:
	animation.play("Idle")
	
	prompt_label.visible = false
	dialogue_label.visible = false
	
	# Prevent duplicate connection errors
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not _can_interact:
		return
		
	if Input.is_action_just_pressed("interact"):
		_advance_dialogue()
		dialogue_sound.play()

func _advance_dialogue() -> void:
	# Hide prompt when conversation begins
	if _is_talking == false:
		_is_talking = true
		_current_index = 0
		prompt_label.visible = false
		dialogue_label.visible = true
		Events.dialogue_started.emit()
	
	# Display line or finish dialogue sequence
	if _current_index < dialogue_lines.size():
		var raw_key: String = dialogue_lines[_current_index]
		var translated_text: String = tr(raw_key)
		dialogue_label.text = "[wave amp=12.0 freq=3.0 connected=0]%s[/wave]" % translated_text
		_current_index += 1
	else:
		_close_dialogue()

func _close_dialogue() -> void:
	_is_talking = false
	dialogue_label.visible = false
	Events.dialogue_finished.emit()
	
	# Show prompt again if player is still within interaction range
	if _can_interact:
		prompt_label.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players") and !_is_talking:
		_can_interact = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		_can_interact = false
		if _is_talking:
			_close_dialogue()
		prompt_label.visible = false
