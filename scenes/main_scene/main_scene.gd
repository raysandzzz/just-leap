extends Node2D

@export var scenes: Array[PackedScene]

var _current_scene: int = 1
var _instanced_scene: Node

func _ready() -> void:
	_create_scene(_current_scene)

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

func _delete_scene() -> void:
	if is_instance_valid(_instanced_scene):
		_instanced_scene.queue_free()

func _restart() -> void:
	_delete_scene()
	# Wait for the old scene to actually be removed from the tree
	await get_tree().process_frame
	_create_scene(_current_scene)
	Transition.open_circle()
