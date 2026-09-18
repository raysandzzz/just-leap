extends AnimatableBody2D

@export var rise_distance: float = 80.0
@export var elev_speed: float = 100.0

@onready var elev_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector: Area2D = $Detector

var _initial_y: float = 0.0
var _move_tween: Tween

func _ready() -> void:
	_initial_y = position.y
	# Connect signals from the child Area2D detector
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		var target_y: float = _initial_y - rise_distance
		_move_to_y(target_y)
		elev_animation.play("On")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		_move_to_y(_initial_y)
		elev_animation.play("Off")

func _move_to_y(target_position: float) -> void:
	var distance: float = abs(target_position - position.y)
	if elev_speed <= 0.0 or distance <= 0.0:
		return
	
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
		
	var duration: float = distance / elev_speed
	_move_tween = create_tween()
	# AnimatableBody2D coordinates physics movement seamlessly with tweens
	_move_tween.tween_property(self, "position:y", target_position, duration)
