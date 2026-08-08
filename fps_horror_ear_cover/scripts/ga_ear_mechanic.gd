extends Node
class_name GaEarMechanic

@export var max_hold_time: float = 5.0
@export var cooldown_duration: float = 3.0
@export var camera: Camera3D
@export var screen_rect: ColorRect
@export var shake_strength: float = 0.05
@export var heartbeat_player: AudioStreamPlayer3D
@export var breath_player: AudioStreamPlayer3D
@export var max_heart_volume_db: float = 0.0
@export var min_heart_pitch: float = 1.0
@export var max_heart_pitch: float = 1.6
@export var low_pass_min_hz: float = 400.0
@export var low_pass_max_hz: float = 20500.0
@export var left_ear_action: StringName = &"left_ear"
@export var right_ear_action: StringName = &"right_ear"
@export var audio_bus_name: String = "World"
@export var use_event_bus: bool = true

var current_hold_time: float = 0.0
var current_cooldown_time: float = 0.0
var is_holding: bool = false:
	set(value):
		is_holding = value
		if use_event_bus and GaEventBus:
			GaEventBus.ear_state_changed.emit(is_holding)

var default_camera_pos: Vector3
var world_bus_index: int = -1
var low_pass_effect: AudioEffectLowPassFilter

func _ready() -> void:
	if camera:
		default_camera_pos = camera.position
	world_bus_index = AudioServer.get_bus_index(audio_bus_name)
	if world_bus_index != -1 and AudioServer.get_bus_effect_count(world_bus_index) > 0:
		var effect = AudioServer.get_bus_effect(world_bus_index, 0)
		if effect is AudioEffectLowPassFilter:
			low_pass_effect = effect
	if heartbeat_player:
		heartbeat_player.volume_db = -80.0
	if breath_player:
		breath_player.volume_db = -80.0

func _process(delta: float) -> void:
	if current_cooldown_time > 0:
		current_cooldown_time -= delta
	if Input.is_action_pressed(left_ear_action) and Input.is_action_pressed(right_ear_action):
		if not is_holding and current_cooldown_time <= 0:
			start_mechanic()
		if is_holding:
			update_holding(delta)
	elif is_holding:
		release_mechanic()

func start_mechanic() -> void:
	is_holding = true
	if heartbeat_player and not heartbeat_player.playing:
		heartbeat_player.play()
	if breath_player and not breath_player.playing:
		breath_player.play()
	if screen_rect and screen_rect.material:
		var tween = create_tween()
		tween.tween_property(screen_rect.material, "shader_parameter/ear_value", 1.0, 0.5)

func update_holding(delta: float) -> void:
	current_hold_time += delta
	var stress_factor = clampf(current_hold_time / max_hold_time, 0.0, 2.0)
	if screen_rect and screen_rect.material:
		screen_rect.material.set_shader_parameter("center_opening", lerpf(0.15, 0.0, stress_factor))
	if camera and stress_factor > 0.3:
		apply_shake(stress_factor)
	if low_pass_effect and screen_rect and screen_rect.material:
		var current_ear_val = screen_rect.material.get_shader_parameter("ear_value")
		low_pass_effect.cutoff_hz = lerpf(low_pass_max_hz, low_pass_min_hz, current_ear_val)
	if heartbeat_player:
		heartbeat_player.volume_db = lerpf(-40.0, max_heart_volume_db, stress_factor)
		heartbeat_player.pitch_scale = lerpf(min_heart_pitch, max_heart_pitch, stress_factor)
	if breath_player:
		breath_player.volume_db = lerpf(-40.0, max_heart_volume_db, stress_factor)
	if current_hold_time >= max_hold_time:
		release_mechanic()

func apply_shake(stress: float) -> void:
	if camera:
		var offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0.0) * shake_strength * stress
		camera.position = default_camera_pos + offset

func release_mechanic() -> void:
	current_cooldown_time = cooldown_duration
	is_holding = false
	current_hold_time = 0.0
	if camera:
		camera.position = default_camera_pos
	if heartbeat_player:
		heartbeat_player.stop()
	if breath_player:
		breath_player.stop()
	if low_pass_effect:
		var audio_tween = create_tween()
		audio_tween.tween_property(low_pass_effect, "cutoff_hz", low_pass_max_hz, 0.5)
	if screen_rect and screen_rect.material:
		var mat = screen_rect.material
		var tween = create_tween().set_parallel(true)
		tween.tween_property(mat, "shader_parameter/ear_value", 0.0, 0.6)
		tween.tween_property(mat, "shader_parameter/center_opening", 0.15, 0.6)
