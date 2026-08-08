extends RigidBody2D
class_name GaPongBall

## Pong ball with speed ramp and falsolu (Magnus/spin) curve physics.

signal ball_hit_paddle(paddle: Node)
signal ball_hit_wall(wall: Node)
signal ball_launched(velocity: Vector2)

const PADDLE_GROUP := &"pong_paddle"

@export var initial_ball_speed: float = 350.0
@export var speed_multiplier: float = 1.1
@export var max_ball_speed: float = 450.0
@export var multiplier_angular_velocity: float = 0.1
@export var curve_multiplier: float = 25.0
@export var max_curve_angle: int = 30

var current_velocity: Vector2


func _ready() -> void:
	add_to_group("pong_ball")
	start_ball()


func _physics_process(_delta: float) -> void:
	if angular_velocity == 0.0 or linear_velocity.length() == 0.0:
		return
	if linear_velocity.y == 0.0:
		linear_velocity.y = 50.0
	var perp := linear_velocity.normalized().rotated(sign(angular_velocity) * PI / 2.0)
	var magnus_force := perp * absf(angular_velocity) * curve_multiplier
	apply_central_force(magnus_force)


func _on_body_exited(body: Node) -> void:
	var new_velocity := linear_velocity * speed_multiplier
	if new_velocity.length() <= max_ball_speed:
		linear_velocity = new_velocity

	if body.is_in_group(PADDLE_GROUP):
		ball_hit_paddle.emit(body)
		_apply_spin_from_paddle(body)
	else:
		ball_hit_wall.emit(body)
		angular_velocity = 0.0


func _apply_spin_from_paddle(paddle: Node) -> void:
	if not paddle is RigidBody2D:
		return
	var paddle_body := paddle as RigidBody2D
	var angle := -rad_to_deg(linear_velocity.angle())
	var paddle_angle := rad_to_deg(paddle_body.linear_velocity.angle())
	var is_curve := true
	if angle < max_curve_angle or (angle < 180.0 and angle > 180.0 - max_curve_angle):
		if paddle_body.linear_velocity.length() != 0.0:
			if paddle_angle > 0.0 and angle > 90.0:
				is_curve = false
			if paddle_angle == 0.0 and angle < 90.0:
				is_curve = false
	if is_curve:
		angular_velocity = paddle_body.linear_velocity.x * multiplier_angular_velocity


func start_ball() -> void:
	randomize()
	var direction := Vector2(
		[-1.0, 1.0][randi() % 2],
		[-0.8, 0.8][randi() % 2]
	).normalized()
	current_velocity = direction * initial_ball_speed
	linear_velocity = current_velocity
	ball_launched.emit(current_velocity)
