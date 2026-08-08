extends StaticBody3D
class_name GaInteractableTV

@export var camera_place_path: NodePath = ^"CameraPlace"
@export var screen_mesh_path: NodePath = ^"Screen"
@export var screen_material: Material
@export var media_content_path: String = ""
@export var stream_target_size: int = 320
@export var use_event_bus: bool = true

var player_is_watching_tv: bool = false
var camera_old_pos: Transform3D
var media_content: SubViewport
var original_mat: Material
var quitting_tv: bool = false
var active_tween: Tween

@onready var camera := get_viewport().get_camera_3d()
@onready var tv_target_pos: Node3D = get_node_or_null(camera_place_path)
@onready var screen: MeshInstance3D = get_node_or_null(screen_mesh_path)

func _ready() -> void:
	if screen:
		original_mat = screen.get_active_material(0)
	disable_tv()
	if not media_content_path.is_empty():
		var game = load(media_content_path)
		if game:
			media_content = game.instantiate()
			add_child(media_content)
			disable_tv()

func interact() -> void:
	play_tv()

func _unhandled_input(event: InputEvent) -> void:
	if quitting_tv and event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		return
	if player_is_watching_tv:
		if event.is_action_pressed("secondary_interact") or event.is_action_pressed("pause"):
			finish_tv()
			get_viewport().set_input_as_handled()
		elif media_content:
			media_content.push_input(event)

func play_tv() -> void:
	if not camera or not tv_target_pos:
		return
	player_is_watching_tv = true
	camera_old_pos = camera.global_transform
	camera.top_level = true
	if use_event_bus and GaEventBus:
		GaEventBus.player_move_switch.emit(false)
		GaEventBus.player_look_switch.emit(false)
		GaEventBus.toggle_ui.emit()
	var tween := create_tween()
	tween.tween_property(camera, "global_transform", tv_target_pos.global_transform, 1.0)
	enable_tv()

func finish_tv() -> void:
	if active_tween and active_tween.is_running():
		return
	quitting_tv = true
	active_tween = create_tween()
	active_tween.tween_property(camera, "global_transform", camera_old_pos, 1.0)
	active_tween.tween_callback(func():
		quitting_tv = false
		player_is_watching_tv = false
		camera.top_level = false
		if use_event_bus and GaEventBus:
			GaEventBus.player_move_switch.emit(true)
			GaEventBus.player_look_switch.emit(true)
			GaEventBus.toggle_ui.emit()
		disable_tv()
	).set_delay(1.0)

func disable_tv() -> void:
	if media_content:
		media_content.render_target_update_mode = SubViewport.UPDATE_DISABLED
		media_content.process_mode = Node.PROCESS_MODE_DISABLED
	if screen and original_mat:
		screen.set_material_override(original_mat)

func enable_tv() -> void:
	if media_content and screen and screen_material:
		media_content.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		media_content.process_mode = Node.PROCESS_MODE_INHERIT
		var tex = media_content.get_texture()
		screen.set_material_override(screen_material)
		if screen_material is StandardMaterial3D:
			screen_material.albedo_texture = tex
			screen_material.emission_texture = tex
