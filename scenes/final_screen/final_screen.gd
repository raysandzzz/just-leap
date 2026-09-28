extends Node2D

@export var cutscene: AnimationPlayer
@export var player_animation: AnimatedSprite2D
@export var player: CharacterBody2D
@export var explosion_sfx: AudioStreamPlayer

func _ready():
	play_cutscene()
	if not cutscene.animation_finished.is_connected(_on_animation_player_animation_finished):
		cutscene.animation_finished.connect(_on_animation_player_animation_finished)

func play_cutscene():
	await Events.spawn_finished
	Events.animation_started.emit()
	$AnimationLevel/Player.set_physics_process(false)
	cutscene.play("CutScene")

func play_appear():
	player_animation.play("Appear")

func play_explosion():
	player_animation.play("Explosion")
	explosion_sfx.play()

func play_fall():
	player_animation.play("Fall")

func play_run():
	player_animation.play("Run")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "CutScene":
		Events.game_finished.emit()
