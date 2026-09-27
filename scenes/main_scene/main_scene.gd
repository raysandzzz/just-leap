extends Node2D

@export var scenes: Array[PackedScene]
@onready var music: AudioStreamPlayer = $MusicPlayer
@onready var music_2: AudioStreamPlayer = $MusicPlayer2

const BG_TIER_1 = preload("res://assets/Background/Green.png")
const BG_TIER_2 = preload("res://assets/Background/Gray.png")
@onready var background_rect: TextureRect = $CanvasLayer/TextureRect

var _current_scene: int = 1
var _instanced_scene: Node

func _ready() -> void:
	Events.level_finished.connect(_next_level)
	_create_scene(_current_scene)
	
	set_music_for_level(_current_scene)
	set_background_for_level(_current_scene)

func _create_scene(scene_number: int) -> void:
	if scene_number < 1 or scene_number > scenes.size():
		return
	
	_instanced_scene = scenes[scene_number - 1].instantiate()
	add_child(_instanced_scene)
	
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		var player: Node = players[0]
		if not player.player_dead.is_connected(_restart):
			player.player_dead.connect(_restart, CONNECT_ONE_SHOT)
	
	await get_tree().process_frame
	
	Transition.open_circle()

func _delete_scene() -> void:
	if is_instance_valid(_instanced_scene):
		_instanced_scene.queue_free()

func _next_level() -> void:
	_current_scene += 1
	_delete_scene()
	_create_scene.call_deferred(_current_scene)
	
	# Update music and background when advancing levels
	set_music_for_level(_current_scene)
	set_background_for_level(_current_scene)

func _restart() -> void:
	_delete_scene()
	# Wait for the old scene to actually be removed from the tree
	await get_tree().process_frame
	_create_scene(_current_scene)

func set_music_for_level(current_level: int) -> void:
	# Levels 0 to 5 correspond to scene index 1 to 6
	if current_level < 7:
		if music_2.playing:
			music_2.stop()
		if not music.playing:
			music.play()
	else:
		# Level 6 and onward (scene index 7+)
		if music.playing:
			music.stop()
		if not music_2.playing:
			music_2.play()

func set_background_for_level(level_number: int) -> void:
	# Levels 0 to 5 correspond to scene index 1 to 6
	if level_number < 7:
		background_rect.texture = BG_TIER_1
	else:
		# Level 6 and onward (scene index 7+)
		background_rect.texture = BG_TIER_2
