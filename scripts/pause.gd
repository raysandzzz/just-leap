extends Node

@export var paused_screen: ColorRect
@export var volume_control: VBoxContainer
@onready var pause_sound: AudioStreamPlayer2D = $PauseSFX
var _can_pause: bool = false

func _ready() -> void:
	if OS.has_feature("mobile"):
		volume_control.visible = false
	
	# Dialogue locks. Ignore pause if dialogue is currently running
	_connect_event(Events.dialogue_started, func(): _can_pause = false)
	_connect_event(Events.dialogue_finished, func(): _can_pause = true)
	
	# Transition / spawn locks
	_connect_event(Events.player_killed, func(): _can_pause = false)
	_connect_event(Events.spawn_finished, func(): _can_pause = true)
	_connect_event(Events.level_finished, func(): _can_pause = false)
	_connect_event(Events.trophy_activate, func(): _can_pause = false)
	_connect_event(Events.time_over, func(): _can_pause = false)
	
	# Main menu is on screen -> enable pause once game starts
	_connect_event(Events.game_started, func(): _can_pause = true)
	_connect_event(Events.animation_started, func(): _can_pause = false)
	
	# Game finished, so can pause... maybe...
	_connect_event(Events.game_finished, func():
		_can_pause = false
		get_tree().paused = false
		if is_instance_valid(paused_screen):
			paused_screen.visible = false
	)

func _connect_event(ev: Signal, callable: Callable):
	if not ev.is_connected(callable):
		ev.connect(callable)

# Extracted logic to be called from multiple input sources
func _toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	pause_sound.play()
	paused_screen.visible = !paused_screen.visible

func _input(event: InputEvent) -> void:
	if not _can_pause:
		return
	
	# Pause action (ESC key, PC controller, etc.)
	if event.is_action_pressed("pause"):
		_toggle_pause()
		return
		
	# Unpause by tapping anywhere on the screen (only works if already paused)
	if get_tree().paused and event is InputEventScreenTouch and event.pressed:
		get_viewport().set_input_as_handled() # Prevent tapping buttons behind the pause screen
		_toggle_pause()

func _notification(what: int) -> void:
	# Listen for the Android native back gesture/button
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _can_pause:
			_toggle_pause()
