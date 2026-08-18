extends Node2D
class_name GaPongCourt

## Drop-in pong court with four world-boundary walls and optional ball/paddle spawn points.

signal ball_spawned(ball: GaPongBall)
signal paddle_spawned(paddle: GaPongPaddle)

@export var court_half_width: float = 576.0
@export var court_top: float = -320.0
@export var court_bottom: float = 192.0
@export var ball_scene: PackedScene
@export var paddle_scene: PackedScene
@export var auto_spawn_ball: bool = true
@export var auto_spawn_paddle: bool = true
@export var default_paddle_position: Vector2 = Vector2(0.0, 168.0)
@export var default_ball_position: Vector2 = Vector2.ZERO

@onready var _walls: Node2D = $Walls
@onready var _entities: Node2D = $Entities


func _ready() -> void:
	_apply_wall_layout()
	if auto_spawn_ball and ball_scene:
		spawn_ball(default_ball_position)
	if auto_spawn_paddle and paddle_scene:
		spawn_paddle(default_paddle_position)


func _apply_wall_layout() -> void:
	var lower := _walls.get_node_or_null("LowerWall") as StaticBody2D
	var upper := _walls.get_node_or_null("UpperWall") as StaticBody2D
	var left := _walls.get_node_or_null("LeftWall") as StaticBody2D
	var right := _walls.get_node_or_null("RightWall") as StaticBody2D
	if lower:
		lower.position = Vector2(0.0, court_bottom)
	if upper:
		upper.position = Vector2(0.0, court_top)
		upper.rotation = PI
	if left:
		left.position = Vector2(-court_half_width, 0.0)
		left.rotation = PI / 2.0
	if right:
		right.position = Vector2(court_half_width, 0.0)
		right.rotation = -PI / 2.0


func spawn_ball(position: Vector2 = Vector2.ZERO) -> GaPongBall:
	if ball_scene == null:
		push_warning("GaPongCourt: ball_scene is not assigned.")
		return null
	var ball := ball_scene.instantiate() as GaPongBall
	if ball == null:
		push_error("GaPongCourt: ball_scene must instantiate a GaPongBall.")
		return null
	_entities.add_child(ball)
	ball.global_position = global_position + position
	ball_spawned.emit(ball)
	return ball


func spawn_paddle(position: Vector2 = Vector2.ZERO) -> GaPongPaddle:
	if paddle_scene == null:
		push_warning("GaPongCourt: paddle_scene is not assigned.")
		return null
	var paddle := paddle_scene.instantiate() as GaPongPaddle
	if paddle == null:
		push_error("GaPongCourt: paddle_scene must instantiate a GaPongPaddle.")
		return null
	_entities.add_child(paddle)
	paddle.global_position = global_position + position
	paddle_spawned.emit(paddle)
	return paddle
