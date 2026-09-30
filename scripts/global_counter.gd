extends Node

signal update_death_counter

# Session metrics (in-game tracking)
var current_run_deaths: int = 0
var total_time: float = 0.0
var is_timing: bool = false
var current_level: int = 0

# Last completed run metrics (read by the main menu)
var deaths: int = 0
var last_run_time: float = 0.0
var has_beaten_game: bool = false

const SAVE_PATH: String = "user://stats.json"

func _ready() -> void:
	load_stats()
	if Events.has_signal("game_finished"):
		Events.game_finished.connect(_on_game_finished)

func _process(delta: float) -> void:
	# Accumulate time starting from Level 0
	if is_timing and current_level >= 0:
		total_time += delta

func add_death() -> void:
	current_run_deaths += 1
	update_death_counter.emit()

func start_level_timer(level_id: int) -> void:
	current_level = level_id
	is_timing = true

func stop_timer() -> void:
	is_timing = false

func start_new_run() -> void:
	# Reset active session when a new game starts
	current_run_deaths = 0
	total_time = 0.0
	is_timing = false
	current_level = 0
	update_death_counter.emit()

func _on_game_finished() -> void:
	# Finalize run stats when the player beats the game
	stop_timer()
	deaths = current_run_deaths
	last_run_time = total_time
	has_beaten_game = true
	save_stats()

func format_time(time_in_seconds: float) -> String:
	var minutes: int = int(time_in_seconds) / 60
	var seconds: int = int(time_in_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func save_stats() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data: Dictionary = {
			"deaths": deaths,
			"last_run_time": last_run_time,
			"has_beaten_game": has_beaten_game
		}
		file.store_string(JSON.stringify(data))

func load_stats() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			deaths = parsed.get("deaths", 0)
			last_run_time = parsed.get("last_run_time", 0.0)
			has_beaten_game = parsed.get("has_beaten_game", false)
