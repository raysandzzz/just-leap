extends Node

# Signals to manages some game states
signal flag_activate
signal trophy_activate
signal time_over

# Signals to manage the transitions
signal level_finished
signal player_killed
signal spawn_finished

# Signals to manage the dialogues easier
signal dialogue_started
signal dialogue_finished

# Signal to emit when game start for first time
signal game_started

var is_game_started: bool = false

# I put these var's here at the start of the development
# Now i think i could perform their job in a better way
# But i don't wanna break the game rn lol
var is_flag_active: bool = false
var trophy_was_pressed: bool = false

# It is not supposed this one to be here, but is easier tho
# A function to activate/deactivate fullscreen with F11
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var is_fs: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED if is_fs else DisplayServer.WINDOW_MODE_FULLSCREEN
		)
