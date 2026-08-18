# PT (Silent Hills) style camera shake.
# Light idle sway plus optional trauma (hit / land) that increases shake.
# Applied shake is smoothed for a more organic feel.
extends Node3D
class_name GaCameraShake

@export_group("Smoothing")
@export var shake_smooth_speed: float = 12.0  ## How quickly the camera catches the target shake. Lower is smoother.

@export_group("Idle Shake")
@export var idle_enabled: bool = true
@export var idle_rotation_amount: float = 0.015
@export var idle_position_amount: float = 0.004
@export var idle_noise_speed: float = 0.25
@export var idle_noise_scale: float = 0.8

@export_group("Trauma")
@export var trauma_decay: float = 1.2
@export var trauma_rotation_mult: float = 3.0
@export var trauma_position_mult: float = 0.012

@export_group("Movement")
@export var movement_boost_enabled: bool = true
@export var movement_rotation_boost: float = 0.06
@export var movement_position_boost: float = 0.0012

@export_group("Running Camera Tilt")
@export var running_tilt_enabled: bool = true
@export var running_tilt_pitch_deg: float = 4.0   ## Pitch while running forward/back (degrees).
@export var running_tilt_roll_deg: float = 5.0    ## Roll while strafing (degrees).
@export var running_tilt_smooth: float = 6.0      ## Tilt blend speed.

@export_group("Head Bob")
@export var step_bob_enabled: bool = true
@export var step_bob_vertical: float = 0.008
@export var step_bob_lateral: float = 0.004
@export var step_bob_roll: float = 0.01
@export var steps_per_meter: float = 2.2
@export var step_smooth: float = 10.0
@export var step_bob_speed_scale: bool = true    ## Scale amplitude with move speed.

var _rest_position: Vector3
var _rest_rotation: Vector3
var _noise: FastNoiseLite
var _noise_time: float = 0.0
var _trauma: float = 0.0
var _player: CharacterBody3D
var _step_phase: float = 0.0
var _step_bob_offset: Vector3
var _step_bob_rotation: float = 0.0
## Soft blend for running tilt
var _running_tilt_pitch: float = 0.0
var _running_tilt_roll: float = 0.0
## Smooth applied shake across frames
var _smoothed_rot_shake: Vector3 = Vector3.ZERO
var _smoothed_pos_shake: Vector3 = Vector3.ZERO

func _ready() -> void:
	_rest_position = position
	_rest_rotation = rotation
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 0.25  # Slower change = smoother shake
	_noise.fractal_octaves = 2
	_noise.fractal_lacunarity = 1.2
	_noise.seed = randi()
	# Player reference (Head -> controller)
	var head = get_parent()
	if head and head.get_parent() is CharacterBody3D:
		_player = head.get_parent() as CharacterBody3D
	if GaEventBus:
		GaEventBus.camera_shake_trauma.connect(_on_trauma_signal)

func _process(delta: float) -> void:
	# Skip shake while TV/dialogue owns the camera
	var cam := get_viewport().get_camera_3d()
	if cam and cam.top_level:
		return

	_noise_time += delta * idle_noise_speed
	_trauma = move_toward(_trauma, 0.0, trauma_decay * delta)

	var rot_shake := Vector3.ZERO
	var pos_shake := Vector3.ZERO

	# Idle (constant organic sway)
	if idle_enabled:
		rot_shake.x = _sample_noise(0.0, _noise_time) * idle_rotation_amount
		rot_shake.y = _sample_noise(10.0, _noise_time) * idle_rotation_amount
		rot_shake.z = _sample_noise(20.0, _noise_time) * idle_rotation_amount * 0.6
		pos_shake.x = _sample_noise(30.0, _noise_time) * idle_position_amount
		pos_shake.y = _sample_noise(40.0, _noise_time) * idle_position_amount
		pos_shake.z = _sample_noise(50.0, _noise_time) * idle_position_amount

	# Shake that grows with movement
	var horz_speed: float = 0.0
	if _player:
		var vel := _player.velocity
		horz_speed = Vector2(vel.x, vel.z).length()
		if movement_boost_enabled:
			var t := clampf(horz_speed / maxf(_player.sprint_speed if _player.can_sprint else _player.base_speed, 0.01), 0.0, 1.0)
			rot_shake += Vector3(
				_sample_noise(60.0, _noise_time) * movement_rotation_boost * t,
				_sample_noise(70.0, _noise_time) * movement_rotation_boost * t,
				_sample_noise(80.0, _noise_time) * movement_rotation_boost * t * 0.5
			)
			pos_shake += Vector3(
				_sample_noise(90.0, _noise_time) * movement_position_boost * t,
				_sample_noise(100.0, _noise_time) * movement_position_boost * t,
				0.0
			)

		# Running camera tilt — directional pitch/roll from velocity dot products
		if running_tilt_enabled and horz_speed > 0.5:
			var vel_h := Vector3(vel.x, 0.0, vel.z)
			var vel_len := vel_h.length()
			if vel_len > 0.01:
				var vel_dir := vel_h / vel_len
				var basis := _player.global_transform.basis
				var forward_h := Vector3(-basis.z.x, 0.0, -basis.z.z)
				var right_h := Vector3(basis.x.x, 0.0, basis.x.z)
				if forward_h.length_squared() > 0.001:
					forward_h = forward_h.normalized()
				if right_h.length_squared() > 0.001:
					right_h = right_h.normalized()
				var max_speed := maxf(_player.sprint_speed if _player.can_sprint else _player.base_speed, 0.01)
				var speed_t := clampf(horz_speed / max_speed, 0.0, 1.0)
				var dot_forward := forward_h.dot(vel_dir)
				var dot_right := right_h.dot(vel_dir)
				var target_pitch_rad := deg_to_rad(dot_forward * running_tilt_pitch_deg * speed_t)
				var target_roll_rad := deg_to_rad(-dot_right * running_tilt_roll_deg * speed_t)
				_running_tilt_pitch = lerpf(_running_tilt_pitch, target_pitch_rad, running_tilt_smooth * delta)
				_running_tilt_roll = lerpf(_running_tilt_roll, target_roll_rad, running_tilt_smooth * delta)
			else:
				_running_tilt_pitch = lerpf(_running_tilt_pitch, 0.0, running_tilt_smooth * delta)
				_running_tilt_roll = lerpf(_running_tilt_roll, 0.0, running_tilt_smooth * delta)
		else:
			_running_tilt_pitch = lerpf(_running_tilt_pitch, 0.0, running_tilt_smooth * delta)
			_running_tilt_roll = lerpf(_running_tilt_roll, 0.0, running_tilt_smooth * delta)
		rot_shake.x += _running_tilt_pitch
		rot_shake.z += _running_tilt_roll

	# Head bob — speed-scaled sine, grounded only
	if step_bob_enabled and _player:
		if _player.is_on_floor():
			var step_rate := horz_speed * steps_per_meter
			if step_rate > 0.3:
				_step_phase += delta * step_rate * TAU
				if _step_phase >= TAU:
					_step_phase -= TAU
				elif _step_phase < 0.0:
					_step_phase += TAU
				var amp := 1.0
				if step_bob_speed_scale and _player:
					var max_speed := maxf(_player.sprint_speed if _player.can_sprint else _player.base_speed, 0.01)
					amp = clampf(horz_speed / max_speed, 0.3, 1.0)
				var target_pos := Vector3(
					sin(_step_phase * 2.0) * step_bob_lateral * amp,
					-sin(_step_phase) * step_bob_vertical * amp,
					0.0
				)
				var target_roll := sin(_step_phase * 2.0) * step_bob_roll * amp
				_step_bob_offset = _step_bob_offset.lerp(target_pos, step_smooth * delta)
				_step_bob_rotation = lerpf(_step_bob_rotation, target_roll, step_smooth * delta)
			else:
				_step_bob_offset = _step_bob_offset.lerp(Vector3.ZERO, step_smooth * delta)
				_step_bob_rotation = lerpf(_step_bob_rotation, 0.0, step_smooth * delta)
		else:
			_step_bob_offset = _step_bob_offset.lerp(Vector3.ZERO, step_smooth * delta)
			_step_bob_rotation = lerpf(_step_bob_rotation, 0.0, step_smooth * delta)
		pos_shake += _step_bob_offset
		rot_shake.z += _step_bob_rotation

	# Trauma (one-shot; trauma² for a decaying tail)
	var trauma_mult := _trauma * _trauma
	rot_shake += Vector3(
		_sample_noise(110.0, _noise_time) * trauma_rotation_mult * trauma_mult,
		_sample_noise(120.0, _noise_time) * trauma_rotation_mult * trauma_mult,
		_sample_noise(130.0, _noise_time) * trauma_rotation_mult * trauma_mult * 0.7
	)
	pos_shake += Vector3(
		_sample_noise(140.0, _noise_time) * trauma_position_mult * trauma_mult,
		_sample_noise(150.0, _noise_time) * trauma_position_mult * trauma_mult,
		_sample_noise(160.0, _noise_time) * trauma_position_mult * trauma_mult * 0.5
	)

	# Smooth between frames so shake does not pop
	var smooth_factor := clampf(shake_smooth_speed * delta, 0.0, 1.0)
	_smoothed_pos_shake = _smoothed_pos_shake.lerp(pos_shake, smooth_factor)
	_smoothed_rot_shake = _smoothed_rot_shake.lerp(rot_shake, smooth_factor)

	position = _rest_position + _smoothed_pos_shake
	rotation = _rest_rotation + _smoothed_rot_shake

func _sample_noise(offset: float, t: float) -> float:
	# 3D sample along time for smoother motion (t, t*0.7, offset)
	return _noise.get_noise_3d(offset, t * 0.5, offset * 0.5)

## Add a one-shot shake (0 = none, 1 = max).
## Example: add_trauma(0.5) — hit, land, scare beat.
## Alternative: GaEventBus.camera_shake_trauma.emit(0.5)
func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)

func _on_trauma_signal(amount: float) -> void:
	add_trauma(amount)
