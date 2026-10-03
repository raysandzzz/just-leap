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
@export var requires_game_beaten: bool = false

var _can_interact: bool = false
var _is_talking: bool = false
var _current_index: int = 0
var _is_advancing: bool = false # Safety lock to prevent double touch triggers

func _ready() -> void:
	if requires_game_beaten and not GlobalCounter.has_beaten_game:
		queue_free()
		return
	animation.play("Idle")
	
	# Adapt prompt text based on the platform using translation keys
	if OS.has_feature("mobile"):
		prompt_label.text = tr("npc_prompt_mobile")
	else:
		prompt_label.text = tr("npc_prompt_label")
	
	prompt_label.visible = false
	dialogue_label.visible = false
	
	# Prevent duplicate connection errors
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	# Ignore input if player is not near or if text is currently advancing
	if not _can_interact or _is_advancing:
		return
	
	# Check for PC keyboard interact action or Mobile screen tap
	var is_interact_action: bool = event.is_action_pressed("interact")
	var is_screen_tap: bool = event is InputEventScreenTouch and event.pressed
	
	if is_interact_action or is_screen_tap:
		get_viewport().set_input_as_handled() # Consume event so it doesn't propagate
		_advance_dialogue()

func _advance_dialogue() -> void:
	_is_advancing = true # Lock input temporarily
	
	# Hide prompt when conversation begins
	if _is_talking == false:
		_is_talking = true
		_current_index = 0
		prompt_label.visible = false
		dialogue_label.visible = true
		Events.dialogue_started.emit()
	
	dialogue_sound.play()
	
	# Display line or finish dialogue sequence
	if _current_index < dialogue_lines.size():
		var raw_key: String = dialogue_lines[_current_index]
		var translated_text: String = tr(raw_key)
		dialogue_label.text = "[wave amp=12.0 freq=3.0 connected=0]%s[/wave]" % translated_text
		_current_index += 1
	else:
		_close_dialogue()
		
	# Tiny delay to prevent double triggers on sensitive mobile touch screens
	await get_tree().create_timer(0.15).timeout
	_is_advancing = false

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
