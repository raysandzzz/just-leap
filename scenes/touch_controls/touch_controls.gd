extends CanvasLayer

# debug var
@export var force_visible_on_pc: bool = true

func _ready() -> void:
	# Initial visibility check based on current game state
	_update_visibility()
	
	# Listen for the game start event to show controls dynamically
	if not Events.game_started.is_connected(_update_visibility):
		Events.game_started.connect(_update_visibility)

func _update_visibility() -> void:
	# If game hasn't started yet (Main Menu), keep them hidden
	if not Events.is_game_started:
		visible = false
		return
		
	# Show if running on mobile or forcing visibility for PC testing
	if OS.has_feature("mobile"):
		visible = true
	else:
		visible = false
