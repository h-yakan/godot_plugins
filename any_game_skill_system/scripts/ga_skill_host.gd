extends Node
class_name GaSkillHost

## Generic skill mount. Pair with GaSkillController for registration and activation.

signal skills_changed

@export var slot_container_paths: Array[NodePath] = [NodePath("Slots")]
@export var tick_skills: bool = false
@export var skill_content_root: String = "res://godot_plugins/any_game_skill_system/content/sample"
@export var controller_path: NodePath = NodePath("GaSkillController")
@export var auto_register_on_ready: bool = true

var _controller: GaSkillController = null


func _ready() -> void:
	_controller = get_node_or_null(controller_path) as GaSkillController
	if _controller == null:
		push_warning("GaSkillHost: GaSkillController not found at '%s'." % controller_path)
		return
	if auto_register_on_ready:
		register_mounted_skills()


func get_controller() -> GaSkillController:
	return _controller


func register_mounted_skills() -> void:
	if _controller == null:
		return
	for skill in get_all_skills():
		_controller.register_skill(skill)
	skills_changed.emit()


func get_skills_in_container(container_path: NodePath) -> Array[GaSkill]:
	var result: Array[GaSkill] = []
	if container_path.is_empty():
		return result
	var container := get_node_or_null(container_path)
	if container == null:
		return result
	for child in container.get_children():
		if child is GaSkill:
			result.append(child)
	return result


func get_all_skills() -> Array[GaSkill]:
	var skills: Array[GaSkill] = []
	for container_path in slot_container_paths:
		skills.append_array(get_skills_in_container(container_path))
	return skills


func get_skills_by_category(category: StringName) -> Array[GaSkill]:
	var result: Array[GaSkill] = []
	for skill in get_all_skills():
		if skill.definition and skill.definition.slot_category == category:
			result.append(skill)
	return result


func load_skill(
	skill_id: String,
	container_path: NodePath = NodePath("Slots"),
	ability_root_path: String = ""
) -> GaSkill:
	var root := ability_root_path if not ability_root_path.is_empty() else skill_content_root
	var skill := GaSkillLoader.instantiate_skill(skill_id, root, self, container_path)
	if skill and _controller:
		_controller.register_skill(skill)
		skills_changed.emit()
	return skill


func load_skill_from_definition(
	definition: GaSkillDefinition,
	container_path: NodePath = NodePath("Slots")
) -> GaSkill:
	if _controller == null:
		push_warning("GaSkillHost: cannot load skill without controller.")
		return null
	var skill := _controller.instantiate_and_register(definition, self, container_path)
	skills_changed.emit()
	return skill


func _physics_process(delta: float) -> void:
	var context := _controller.get_context() if _controller else GaSkillContext.new()
	for skill in get_all_skills():
		if tick_skills or skill.should_tick():
			skill.process_skill(delta, context)
