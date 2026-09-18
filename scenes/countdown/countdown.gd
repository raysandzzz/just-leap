extends CanvasLayer

@onready var label: Label = $Control/Label

@export var init_time: float = 15.0

var time_left: float = 0.0
var time_speed: float = 1.0
var twinkle_counter: float = 0.0
var paused: bool = false

func _ready():
	time_left = init_time
	time_speed = 1.0
	twinkle_counter = 0.0
	paused = false
	label.modulate = Color.WHITE
	Events.is_flag_active = false
	
	_update_text()
	
	if not Events.flag_activate.is_connected(_activate_fast_mode):
		Events.flag_activate.connect(_activate_fast_mode)
	if not Events.trophy_activate.is_connected(pause_timer):
		Events.trophy_activate.connect(pause_timer)
	
	# Start counting only if the transition is finished
	if not Transition.transition_finished.is_connected(play_timer):
		Transition.transition_finished.connect(play_timer, CONNECT_ONE_SHOT)

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
	label.text = "Time: %05.2f" % time_left

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
	Events.time_over.emit()

func pause_timer() -> void:
	paused = true
	label.modulate = Color.GOLD

func play_timer() -> void:
	paused = false
