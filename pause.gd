extends Node

var _can_pause: bool = true

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

func _connect_event(ev: Signal, callable: Callable):
	if not ev.is_connected(callable):
		ev.connect(callable)

func _input(event: InputEvent) -> void:
	if not _can_pause:
		return
	
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused

func _on_dialogue_started() -> void:
	_can_pause = false

func _on_dialogue_finished() -> void:
	_can_pause = true
