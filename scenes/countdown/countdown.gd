extends CanvasLayer

@onready var label: Label = $Control/Label

@export var init_time: float = 30.0

var time_left: float = 0.0
var time_speed: float = 1.0
var twinkle_counter: float = 0.0
var paused: bool = false

func _ready():
	label.visible = false
	time_left = init_time
	time_speed = 1.0
	twinkle_counter = 0.0
	paused = true
	label.modulate = Color.WHITE
	Events.is_flag_active = false
	
	_update_text()
	
	if not Events.flag_activate.is_connected(_activate_fast_mode):
		Events.flag_activate.connect(_activate_fast_mode)
	if not Events.trophy_activate.is_connected(pause_timer):
		Events.trophy_activate.connect(pause_timer)
	if not Events.player_killed.is_connected(_on_player_killed):
		Events.player_killed.connect(_on_player_killed)
	
	if not Events.dialogue_started.is_connected(_on_dialogue):
		Events.dialogue_started.connect(_on_dialogue)
	if not Events.dialogue_finished.is_connected(play_timer):
		Events.dialogue_finished.connect(play_timer)
	
	# Start counting only if the transition and spawn is finished
	_connect_player_spawn()

func _connect_player_spawn() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		var player: Node = players[0]
		if not Events.spawn_finished.is_connected(play_timer):
			Events.spawn_finished.connect(play_timer, CONNECT_ONE_SHOT)
	else:
		await get_tree().process_frame
		if is_inside_tree():
			_connect_player_spawn()

func _process(delta: float):
	if paused:
		return
	
	if time_left > 0.0:
		time_left -= delta * time_speed
		if time_left <= 0.0:
			_time_over()
		
		_update_text()
		
		if Events.is_flag_active:
			_process_twinkle(delta)

func _update_text():
	# Format the number to two decimals places in this way: 00.00
	label.text = tr("countdown_label") % time_left

func _activate_fast_mode():
	time_speed = 2.0
	Events.is_flag_active = true

func _process_twinkle(delta: float):
	twinkle_counter += delta * 6.0    # This one basically manages the "twinkspeed" by change the float number
	if int(twinkle_counter) % 2 == 0:  # Math operation to manage the colors, twinking depends on it
		label.modulate = Color.WHITE
	else:
		label.modulate = Color.RED

func _time_over():
	label.modulate = Color.RED
	time_left = 0.0
	paused = true
	Events.time_over.emit()
	Events.player_killed.emit()

func pause_timer() -> void: # Pause timer after pressed trophy
	paused = true
	label.modulate = Color.GOLD

func _on_player_killed() -> void: # Pause timer after player get killed
	paused = true
	label.modulate = Color.RED # Shows red instead of gold

func _on_dialogue() -> void:
	paused = true
	label.modulate = Color("72a11d")

func play_timer() -> void:
	label.visible = true
	paused = false
	label.modulate = Color.WHITE
