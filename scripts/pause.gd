extends Node

@export var paused_screen: ColorRect
@onready var pause_sound: AudioStreamPlayer2D = $PauseSFX
var _can_pause: bool = false

func _ready() -> void:
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

func _input(event: InputEvent) -> void:
	if not _can_pause:
		return
	
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		pause_sound.play()
		paused_screen.visible = !paused_screen.visible
