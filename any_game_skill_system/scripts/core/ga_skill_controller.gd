extends Node
class_name GaSkillController

## Orchestrates registration, casting, toggling, and resource costs for all skill archetypes.

signal skill_registered(skill: GaSkill)
signal skill_unregistered(skill: GaSkill)
signal skill_activation_requested(skill: GaSkill, result: GaSkill.ActivationResult)
signal skill_activated(skill: GaSkill, context: GaSkillContext)
signal skill_deactivated(skill: GaSkill, context: GaSkillContext)
signal skill_toggled_on(skill: GaSkill, context: GaSkillContext)
signal skill_toggled_off(skill: GaSkill, context: GaSkillContext)
signal skill_passive_applied(skill: GaSkill, context: GaSkillContext)
signal skill_cooldown_started(skill: GaSkill, duration: float)
signal skill_cooldown_finished(skill: GaSkill)
signal skill_cost_spent(skill: GaSkill, resource_id: StringName, amount: float)
signal skill_cost_insufficient(skill: GaSkill, resource_id: StringName, amount: float)

@export var caster_path: NodePath
@export var auto_discover_skills: bool = true
@export var discovery_root_path: NodePath = NodePath("..")

var registry: GaSkillRegistry = GaSkillRegistry.new()
var cost_provider: GaSkillCostProvider = null

var _skills_by_id: Dictionary = {}
var _context: GaSkillContext = GaSkillContext.new()


func _ready() -> void:
	_refresh_context()
	if auto_discover_skills:
		var root := get_node_or_null(discovery_root_path)
		if root:
			discover_skills(root)


func get_caster() -> Node:
	if not caster_path.is_empty():
		return get_node_or_null(caster_path)
	return get_parent()


func get_context() -> GaSkillContext:
	return _context


func set_cost_provider(provider: GaSkillCostProvider) -> void:
	cost_provider = provider
	_refresh_context()


func refresh_context(target: Node = null) -> void:
	_refresh_context(target)


func register_definition(definition: GaSkillDefinition) -> void:
	registry.register_definition(definition)


func register_definitions_from_directory(content_dir: String) -> int:
	return registry.register_directory(content_dir)


func discover_skills(root: Node) -> void:
	for child in root.get_children():
		if child is GaSkill:
			register_skill(child as GaSkill)
		discover_skills(child)


func register_skill(skill: GaSkill) -> void:
	if skill == null:
		return
	_refresh_context()
	skill.setup(_context)
	var skill_id := skill.get_id()
	if skill_id.is_empty():
		push_warning("GaSkillController: skill '%s' has empty id." % skill.name)
		return
	if _skills_by_id.has(skill_id):
		unregister_skill(_skills_by_id[skill_id])
	_skills_by_id[skill_id] = skill
	_connect_skill(skill)
	skill.on_registered(_context)
	skill_registered.emit(skill)


func unregister_skill(skill: GaSkill) -> void:
	if skill == null:
		return
	var skill_id := skill.get_id()
	if not _skills_by_id.has(skill_id):
		return
	if skill.is_toggled_on():
		skill.try_deactivate(_context)
	_disconnect_skill(skill)
	_skills_by_id.erase(skill_id)
	skill_unregistered.emit(skill)


func get_skill(skill_id: String) -> GaSkill:
	return _skills_by_id.get(skill_id.strip_edges())


func get_all_skills() -> Array[GaSkill]:
	var result: Array[GaSkill] = []
	for skill in _skills_by_id.values():
		result.append(skill)
	return result


func get_castable_skills() -> Array[GaSkill]:
	var result: Array[GaSkill] = []
	for skill in _skills_by_id.values():
		if skill.is_castable():
			result.append(skill)
	return result


func request_activation(skill_id: String, target: Node = null) -> GaSkill.ActivationResult:
	var skill := get_skill(skill_id)
	if skill == null:
		return GaSkill.ActivationResult.NOT_FOUND
	return request_activation_for_skill(skill, target)


func request_activation_for_skill(skill: GaSkill, target: Node = null) -> GaSkill.ActivationResult:
	if skill == null:
		return GaSkill.ActivationResult.NOT_FOUND
	if target:
		_refresh_context(target)
	var result := skill.try_activate(_context)
	skill_activation_requested.emit(skill, result)
	if result == GaSkill.ActivationResult.SUCCESS:
		match skill.get_kind():
			GaSkillKinds.Kind.TOGGLE:
				if skill.is_toggled_on():
					skill_activated.emit(skill, _context)
				else:
					skill_deactivated.emit(skill, _context)
			GaSkillKinds.Kind.ACTIVE:
				skill_activated.emit(skill, _context)
	return result


func request_deactivation(skill_id: String) -> GaSkill.ActivationResult:
	var skill := get_skill(skill_id)
	if skill == null:
		return GaSkill.ActivationResult.NOT_FOUND
	return request_deactivation_for_skill(skill)


func request_deactivation_for_skill(skill: GaSkill) -> GaSkill.ActivationResult:
	if skill == null:
		return GaSkill.ActivationResult.NOT_FOUND
	var result := skill.try_deactivate(_context)
	if result == GaSkill.ActivationResult.SUCCESS:
		skill_deactivated.emit(skill, _context)
		skill_toggled_off.emit(skill, _context)
	return result


func instantiate_and_register(
	definition: GaSkillDefinition,
	parent: Node,
	container_path: NodePath = NodePath("")
) -> GaSkill:
	var skill := GaSkillLoader.instantiate_from_definition(definition, parent, container_path)
	if skill:
		register_skill(skill)
	return skill


func _refresh_context(target: Node = null) -> void:
	_context = GaSkillContext.from_caster(get_caster(), target)
	_context.cost_provider = cost_provider


func _connect_skill(skill: GaSkill) -> void:
	if skill.has_meta("_ga_skill_controller_connected"):
		return
	skill.set_meta("_ga_skill_controller_connected", true)
	skill.cooldown_started.connect(func(duration: float) -> void:
		skill_cooldown_started.emit(skill, duration)
	)
	skill.cooldown_finished.connect(func() -> void:
		skill_cooldown_finished.emit(skill)
	)
	skill.toggled_on.connect(func(context: GaSkillContext) -> void:
		skill_toggled_on.emit(skill, context)
	)
	skill.toggled_off.connect(func(context: GaSkillContext) -> void:
		skill_toggled_off.emit(skill, context)
	)
	skill.passive_applied.connect(func(context: GaSkillContext) -> void:
		skill_passive_applied.emit(skill, context)
	)
	skill.cost_spent.connect(func(resource_id: StringName, amount: float) -> void:
		skill_cost_spent.emit(skill, resource_id, amount)
	)
	skill.cost_insufficient.connect(func(resource_id: StringName, amount: float) -> void:
		skill_cost_insufficient.emit(skill, resource_id, amount)
	)


func _disconnect_skill(skill: GaSkill) -> void:
	if not skill.has_meta("_ga_skill_controller_connected"):
		return
	skill.remove_meta("_ga_skill_controller_connected")
