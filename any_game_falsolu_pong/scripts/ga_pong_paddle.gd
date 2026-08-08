extends RigidBody2D
class_name GaPongPaddle

## Axis-locked paddle controlled by configurable input actions.

enum MoveAxis { X, Y }

@export var speed: float = 300.0
@export var move_axis: MoveAxis = MoveAxis.X
@export var input_negative: StringName = &"ui_left"
@export var input_positive: StringName = &"ui_right"


func _ready() -> void:
	add_to_group("pong_paddle")
	lock_rotation = true


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var direction := Input.get_axis(input_negative, input_positive)
	match move_axis:
		MoveAxis.X:
			if linear_velocity.y != 0.0:
				linear_velocity.y = 0.0
			if direction:
				linear_velocity.x = direction * speed
			else:
				linear_velocity.x = move_toward(linear_velocity.x, 0.0, speed)
		MoveAxis.Y:
			if linear_velocity.x != 0.0:
				linear_velocity.x = 0.0
			if direction:
				linear_velocity.y = direction * speed
			else:
				linear_velocity.y = move_toward(linear_velocity.y, 0.0, speed)
