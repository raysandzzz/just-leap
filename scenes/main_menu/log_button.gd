extends Button

@export var stats_panel: Control
@export var close_button: Button

@onready var deaths_label: Label = stats_panel.get_node("VBoxContainer/DeathsLabel")
@onready var time_label: Label = stats_panel.get_node("VBoxContainer/TimeLabel")

func _ready() -> void:
	visible = GlobalCounter.has_beaten_game
	# Hide panel initially
	if stats_panel:
		stats_panel.visible = false
	
	pressed.connect(_on_pressed)
	
	if close_button:
		close_button.pressed.connect(_close_panel)

func _on_pressed() -> void:
	if not stats_panel:
		return
		
	# Toggle visibility
	stats_panel.visible = not stats_panel.visible
	
	if stats_panel.visible:
		_update_display()

func _close_panel() -> void:
	if stats_panel:
		stats_panel.visible = false

func _update_display() -> void:
	var formatted_time: String = GlobalCounter.format_time(GlobalCounter.last_run_time)
	deaths_label.text = tr("menu_log_deaths_label") % GlobalCounter.deaths
	time_label.text = tr("menu_log_time_label") % formatted_time
