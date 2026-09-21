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

# I put these var's here at the start of the development
# Now i think i could perform their job in a better way
# But i don't wanna break the game rn lol
var is_flag_active: bool = false
var trophy_was_pressed: bool = false
