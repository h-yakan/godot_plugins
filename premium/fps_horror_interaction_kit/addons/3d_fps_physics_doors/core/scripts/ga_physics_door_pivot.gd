extends Node3D
class_name GaPhysicsDoorPivot

const _EventBus := preload("res://addons/3d_fps_physics_doors/core/ga_event_bus_client.gd")

@export var sensitivity: float = 0.0055
@export var max_angle: float = 1.8
@export var min_angle: float = 0.0
@export var friction: float = 11.0
@export var auto_open_threshold: float = 0.3
@export var auto_close_threshold: float = 0.7
@export var auto_speed: float = 2.5
@export var player_group: StringName = &"Player"
@export var use_event_bus: bool = true

var is_pushing := false
var current_open_amount: float = 0.0
var initial_rotation_y: float = 0.0
var velocity: float = 0.0
var side_multiplier: float = 1.0
var is_auto_moving: bool = false
var auto_target_angle: float = 0.0
@onready var in_door: GaPhysicsDoor = get_parent() as GaPhysicsDoor

func _ready() -> void:
	initial_rotation_y = rotation.y

func set_open_amount(amount: float) -> void:
	current_open_amount = clampf(amount, min_angle, max_angle)
	rotation.y = initial_rotation_y + current_open_amount

func interact() -> void:
	if in_door and in_door.is_locked:
		_EventBus.emit(self, &"show_warning", ["Door locked", 2.0], use_event_bus)
		return
	is_pushing = not is_pushing
	if is_pushing:
		var player = get_tree().get_first_node_in_group(player_group)
		_EventBus.emit(self, &"player_look_switch", [false], use_event_bus)
		if player:
			var direction_to_player = (player.global_position - global_position).normalized()
			var door_forward = global_transform.basis.z
			side_multiplier = -1.0 if door_forward.dot(direction_to_player) > 0 else 1.0
	else:
		_EventBus.emit(self, &"player_look_switch", [true], use_event_bus)

func _process(delta: float) -> void:
	if is_auto_moving:
		var diff := auto_target_angle - current_open_amount
		if abs(diff) < 0.01:
			current_open_amount = auto_target_angle
			is_auto_moving = false
			velocity = 0.0
			_EventBus.emit(self, &"player_look_switch", [true], use_event_bus)
		else:
			current_open_amount += sign(diff) * auto_speed * delta
			current_open_amount = clampf(current_open_amount, min_angle, max_angle)
		rotation.y = initial_rotation_y + current_open_amount
		return
	velocity = lerp(velocity, 0.0, friction * delta)
	if abs(velocity) < 0.0001:
		velocity = 0.0
	var previous_open_amount := current_open_amount
	if velocity != 0.0:
		current_open_amount += velocity
		current_open_amount = clampf(current_open_amount, min_angle, max_angle)
		if current_open_amount <= min_angle or current_open_amount >= max_angle:
			velocity = 0.0
		rotation.y = initial_rotation_y + current_open_amount
	if is_pushing:
		var open_fraction := 0.0
		if max_angle != min_angle:
			open_fraction = (current_open_amount - min_angle) / (max_angle - min_angle)
		var delta_open := current_open_amount - previous_open_amount
		if delta_open > 0.0 and open_fraction >= auto_open_threshold:
			is_pushing = false
			is_auto_moving = true
			auto_target_angle = max_angle
			velocity = 0.0
			if in_door:
				in_door.is_open = true
		elif delta_open < 0.0 and open_fraction <= auto_close_threshold:
			is_pushing = false
			is_auto_moving = true
			auto_target_angle = min_angle
			velocity = 0.0
			if in_door:
				in_door.is_open = false

func _input(event: InputEvent) -> void:
	if is_pushing and event is InputEventMouseMotion:
		velocity = event.relative.y * sensitivity * side_multiplier
	if is_pushing and (event.is_action_pressed("interact") or event.is_action_pressed("secondary_interact")):
		interact()
		get_viewport().set_input_as_handled()
