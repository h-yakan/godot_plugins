extends RigidBody3D
class_name GaGrabbable

@export var collision_sound_effect: AudioStream
@export var player_hand_reference: NodePath
@export var player_group: StringName = &"Player"
@export var follow_strength: float = 3.0
@export var throw_strength: float = 6.0
@export var contact_velocity_threshold: float = 1.0
@export var throw_cooldown: float = 0.5
@export var interact_action: StringName = &"interact"
@export var secondary_interact_action: StringName = &"secondary_interact"

var object_ref: RigidBody3D
var collision_audio_player: AudioStreamPlayer3D
var last_velocity: Vector3 = Vector3.ZERO
var is_holding: bool = false
var _hand_node: Node3D
var _player_node: CollisionObject3D
var _throw_cooldown_active: bool = false

func _ready() -> void:
	object_ref = self
	_player_node = get_tree().get_first_node_in_group(player_group)
	if collision_sound_effect:
		collision_audio_player = AudioStreamPlayer3D.new()
		collision_audio_player.stream = collision_sound_effect
		add_child(collision_audio_player)
	object_ref.body_entered.connect(_on_body_entered)
	object_ref.contact_monitor = true
	object_ref.max_contacts_reported = 1
	_resolve_hand_reference()

func _resolve_hand_reference() -> void:
	if player_hand_reference.is_empty():
		var player = _player_node
		if player:
			_hand_node = player.get_node_or_null("Head/Eyes/Camera3D") as Node3D
	else:
		_hand_node = get_node_or_null(player_hand_reference) as Node3D
	if not _hand_node:
		_hand_node = get_viewport().get_camera_3d() as Node3D

func _get_hand_position() -> Vector3:
	if _hand_node:
		return _hand_node.global_position + _hand_node.global_transform.basis.z * -0.5
	return Vector3.ZERO

func _physics_process(_delta: float) -> void:
	if not object_ref:
		return
	last_velocity = object_ref.linear_velocity
	if is_holding and not _throw_cooldown_active:
		var to_hand := _get_hand_position() - object_ref.global_position
		object_ref.linear_velocity = to_hand * (follow_strength / object_ref.mass)

func _unhandled_input(event: InputEvent) -> void:
	if is_holding:
		if event.is_action_pressed(interact_action):
			call_deferred("grab")
			get_viewport().set_input_as_handled()
		if event.is_action_pressed(secondary_interact_action):
			secondary_interact()
			get_viewport().set_input_as_handled()

func grab() -> void:
	if not object_ref or _throw_cooldown_active:
		return
	if is_holding:
		_release()
	else:
		_grab()

func _grab() -> void:
	if _player_node and is_instance_valid(_player_node):
		add_collision_exception_with(_player_node)
	is_holding = true

func _release() -> void:
	if _player_node and is_instance_valid(_player_node):
		remove_collision_exception_with(_player_node)
	is_holding = false

func secondary_interact() -> void:
	if not object_ref or not is_holding or _throw_cooldown_active:
		return
	var dir := -_hand_node.global_transform.basis.z.normalized() if _hand_node else Vector3.FORWARD
	object_ref.linear_velocity = dir * (throw_strength / object_ref.mass)
	_release()
	_throw_cooldown_active = true
	await get_tree().create_timer(throw_cooldown).timeout
	_throw_cooldown_active = false

func _on_body_entered(_body: Node) -> void:
	var impact := (last_velocity - object_ref.linear_velocity).length()
	if impact > contact_velocity_threshold and collision_audio_player and collision_sound_effect:
		collision_audio_player.play()
