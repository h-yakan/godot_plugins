extends Node
class_name GaEyeBlink

const _EventBus := preload("res://addons/fps_horror_eye_blink/core/ga_event_bus_client.gd")

@export var eye_lids: ColorRect
@export var blackout_rect: ColorRect
@export var vein_textures: Array[Texture2D] = []
@export var blink_close_action: StringName = &"blinkclose"
@export var blink_open_action: StringName = &"blinkopen"
@export var player_path: NodePath = ^".."
@export var can_blink_property: String = "can_blink"
@export var use_event_bus: bool = true
@export var pause_when_dialogue_overlay: bool = true
@export_range(0.0, 1.5) var target_lid_value: float = 0.0
@export var smooth_speed: float = 8.0
@export var blink_step_amount: float = 0.34

var current_lid_value: float = 0.0
var texture_index: int = 0
var is_eyes_closed: bool = true
var _player: Node

func _ready() -> void:
	_player = get_node_or_null(player_path)
	if blackout_rect:
		blackout_rect.color.a = 0.0
	update_eye_visuals()

func _can_blink() -> bool:
	if _player and _player.get(can_blink_property) != null:
		return bool(_player.get(can_blink_property))
	return true

func _dialogue_paused() -> bool:
	if not pause_when_dialogue_overlay or not is_inside_tree():
		return false
	var mgr := get_tree().root.get_node_or_null("GaDialogueManager")
	return mgr != null and bool(mgr.get("dialogue_paused_by_overlay"))

func _process(delta: float) -> void:
	if not _can_blink():
		return
	if Input.is_action_just_pressed(blink_close_action) and not _dialogue_paused():
		target_lid_value = clampf(target_lid_value + blink_step_amount, 0.0, 1.4)
	elif Input.is_action_just_pressed(blink_open_action) and not _dialogue_paused():
		target_lid_value = clampf(target_lid_value - blink_step_amount, 0.0, 1.4)
	current_lid_value = lerpf(current_lid_value, target_lid_value, delta * smooth_speed)
	update_eye_visuals()

func trigger_afterimage_effect() -> void:
	if eye_lids and eye_lids.material:
		if vein_textures.size() > 0:
			var next_texture = vein_textures[texture_index]
			eye_lids.material.set_shader_parameter("vein_texture", next_texture)
			texture_index = (texture_index + 1) % vein_textures.size()
		var tween = create_tween()
		eye_lids.material.set_shader_parameter("afterimage_intensity", 0.8)
		tween.tween_method(set_afterimage_value, 0.8, 0.0, 0.3)

func set_afterimage_value(val: float) -> void:
	if eye_lids and eye_lids.material:
		eye_lids.material.set_shader_parameter("afterimage_intensity", val)

func update_eye_visuals() -> void:
	var shader_val = minf(current_lid_value, 1.0)
	if eye_lids and eye_lids.material:
		eye_lids.material.set_shader_parameter("lid_value", shader_val)
	if blackout_rect:
		if current_lid_value > 1.0:
			blackout_rect.color.a = clampf((current_lid_value - 1.0) * 3.0, 0.0, 1.0)
		else:
			blackout_rect.color.a = 0.0
	if not is_eyes_closed and current_lid_value >= 0.98:
		is_eyes_closed = true
		_EventBus.emit(self, &"eyes_toggle", [], use_event_bus)
		_EventBus.emit(self, &"eyes_closed", [], use_event_bus)
		trigger_afterimage_effect()
	elif is_eyes_closed and current_lid_value < 0.98:
		is_eyes_closed = false
		_EventBus.emit(self, &"eyes_toggle", [], use_event_bus)
