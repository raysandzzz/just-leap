extends CanvasLayer

@onready var label: Label = $Control/Label

@export var init_time: float = 30.0

var time_left: float = 0.0
var time_speed: float = 1.0
var twinkle_counter: float = 0.0
var paused: bool = false

func _ready():
	time_left = init_time
	_update_text()
	Events.flag_activate.connect(_activate_fast_mode)
	Events.trophy_activate.connect(pause_timer)

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

func pause_timer() -> void:
	paused = true
	label.modulate = Color.GOLD

func play_timer() -> void:
	paused = false
