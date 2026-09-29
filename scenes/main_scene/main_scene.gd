extends Node2D

@export var scenes: Array[PackedScene]
@export var animation: AnimationPlayer
@onready var music: AudioStreamPlayer = $MusicPlayer
@onready var music_2: AudioStreamPlayer = $MusicPlayer2
@onready var music_3_credits: AudioStreamPlayer = $MusicPlayer3Credits

const BG_TIER_1 = preload("res://assets/Background/Green.png")
const BG_TIER_2 = preload("res://assets/Background/Gray.png")
@onready var background_rect: TextureRect = $Background/TextureRect

var _current_scene: int = 0
var _instanced_scene: Node

func _ready() -> void:
	Events.level_finished.connect(_next_level)
	Events.game_finished.connect(_new_game)
	
	# If scene 0 is your Main Menu, instantiate it on ready. 
	# (If MainMenu is a separate UI node in MainScene, remove _create_scene from here)
	_create_scene(_current_scene, false)
	
	# Removed redundant music and background calls here since _create_scene handles them.

func _create_scene(scene_number: int, open_transition: bool = true) -> void:
	if scene_number < 0 or scene_number >= scenes.size():
		return
	
	_instanced_scene = scenes[scene_number].instantiate()
	add_child(_instanced_scene)
	
	# Update music and background AFTER the scene instance is added
	set_music_for_level(_current_scene)
	set_background_for_level(_current_scene)
	
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		var player: Node = players[0]
		if not player.player_dead.is_connected(_restart):
			player.player_dead.connect(_restart, CONNECT_ONE_SHOT)
	
	if open_transition:
		await get_tree().process_frame
		Transition.open_circle()

func _delete_scene() -> void:
	if is_instance_valid(_instanced_scene):
		_instanced_scene.queue_free()

func _next_level() -> void:
	_current_scene += 1
	_delete_scene()
	
	# Create scene normally instead of call_deferred to keep proper sync
	_create_scene(_current_scene)
	
	# Removed redundant music and background calls here.

func _restart() -> void:
	_delete_scene()
	# Wait for the old scene to actually be removed from the tree
	await get_tree().process_frame
	_create_scene(_current_scene)

func set_music_for_level(current_level: int) -> void:
	var scene_resource = scenes[current_level] if current_level >= 0 and current_level < scenes.size() else null
	var scene_path = scene_resource.resource_path if scene_resource else ""
	
	if "final_screen.tscn" in scene_path:
		if music.playing:
			music.stop()
		if music_2.playing:
			music_2.stop()
		if not music_3_credits.playing:
			await get_tree().create_timer(2.5).timeout
			music_3_credits.play()
	elif current_level < 6:
		if music_2.playing:
			music_2.stop()
		if not music.playing:
			music.play()
	else:
		if music.playing:
			music.stop()
		if not music_2.playing:
			music_2.play()

func set_background_for_level(level_number: int) -> void:
	var scene_resource = scenes[level_number] if level_number >= 0 and level_number < scenes.size() else null
	var scene_path = scene_resource.resource_path if scene_resource else ""
	
	if background_rect:
		background_rect.show()
	
	if "final_screen.tscn" in scene_path:
		background_rect.texture = BG_TIER_2
	elif level_number < 6:
		background_rect.texture = BG_TIER_1
	else:
		background_rect.texture = BG_TIER_2

func _new_game() -> void:
	_current_scene = 0
	
	# 1. Delete the blacked-out final screen while the screen is already dark
	_delete_scene()
	
	# 2. Wait one frame for the deletion to process
	await get_tree().process_frame
	
	Events.is_game_started = false
	
	# 3. Instantiate scene 0 (or level 1) behind the fade
	_create_scene(_current_scene, false)
	
	# 4. NOW play the "NewGame" animation to fade-in / open the screen and reveal scene 0
	if animation:
		animation.play("NewGame")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Events.animation_finished.emit()
