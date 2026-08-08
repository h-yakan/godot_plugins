extends CharacterBody3D
class_name GaFpsPlayerController

@export var can_move: bool = true
@export var has_gravity: bool = true
@export var can_jump: bool = true
@export var can_sprint: bool = false
@export var can_freefly: bool = false
@export var can_look: bool = true
@export var max_health: float = 50.0
@export var look_speed: float = 0.002
@export var base_speed: float = 7.0
@export var jump_velocity: float = 4.5
@export var sprint_speed: float = 10.0
@export var freefly_speed: float = 25.0
@export var crouching_speed: float = 4.0
@export var crouching_depth: float = -0.65
@export var input_forward: StringName = &"forward"
@export var input_back: StringName = &"backward"
@export var input_left: StringName = &"left"
@export var input_right: StringName = &"right"
@export var input_jump: StringName = &"jump"
@export var input_sprint: StringName = &"sprint"
@export var input_crouch: StringName = &"crouch"
@export var input_freefly: StringName = &"freefly"
@export var head_path: NodePath = ^"Head"
@export var standing_collider_path: NodePath = ^"StandingCollider"
@export var crouching_collider_path: NodePath = ^"CrouchingCollider"
@export var standup_check_path: NodePath = ^"StandupCheck"
@export var use_event_bus: bool = true
@export var player_group: StringName = &"Player"

var _health: float = 50.0

var health: float:
	set(value):
		var clamped := clampf(value, 0.0, max_health)
		if is_equal_approx(clamped, _health):
			return
		_health = clamped
		if use_event_bus and GaEventBus:
			GaEventBus.player_health_changed.emit(_health, max_health)
		if _health <= 0.0:
			player_died.emit()
	get:
		return _health

signal player_died()

var movement_direction: Vector2 = Vector2.ZERO
var mouse_captured: bool = true
var look_rotation: Vector2
var move_speed: float = 0.0
var freeflying: bool = false

@onready var head: Node3D = get_node(head_path)
@onready var standing_collision_shape: CollisionShape3D = get_node(standing_collider_path)
@onready var crouching_collision_shape: CollisionShape3D = get_node(crouching_collider_path)
@onready var standup_check: RayCast3D = get_node(standup_check_path)

func _ready() -> void:
	add_to_group(player_group)
	_health = max_health
	capture_mouse()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	if use_event_bus and GaEventBus:
		GaEventBus.player_look_switch.connect(_on_player_look_switch)
		GaEventBus.player_move_switch.connect(_on_player_move_switch)

func _on_player_look_switch(is_release_mouse: bool = true) -> void:
	if not mouse_captured:
		capture_mouse()
	elif is_release_mouse:
		release_mouse()
	else:
		mouse_captured = false

func _on_player_move_switch(is_enabled: bool = true) -> void:
	can_move = is_enabled

func _unhandled_input(event: InputEvent) -> void:
	if mouse_captured and can_look and event is InputEventMouseMotion:
		rotate_look(event.relative)
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		freeflying = not freeflying
		standing_collision_shape.disabled = freeflying
		crouching_collision_shape.disabled = freeflying

func _physics_process(delta: float) -> void:
	if can_move:
		movement_direction = Input.get_vector(input_left, input_right, input_forward, input_back)
	_update_move_speed()
	if freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * freefly_speed * delta
		move_and_collide(motion)
		return
	if has_gravity and not is_on_floor():
		velocity += get_gravity() * delta
	if can_jump and Input.is_action_just_pressed(input_jump) and is_on_floor():
		velocity.y = jump_velocity
	if can_move:
		var move_dir := (transform.basis * Vector3(movement_direction.x, 0, movement_direction.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()

func _update_move_speed() -> void:
	if Input.is_action_pressed(input_crouch):
		move_speed = crouching_speed
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	else:
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		move_speed = sprint_speed if can_sprint and Input.is_action_pressed(input_sprint) else base_speed

func rotate_look(rot_input: Vector2) -> void:
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
