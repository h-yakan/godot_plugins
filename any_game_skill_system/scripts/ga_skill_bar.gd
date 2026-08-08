extends HBoxContainer
class_name GaSkillBar

## Binds GaSkillSlot children to skills via GaSkillController.

@export var controller_path: NodePath
@export var slot_bindings: Array[GaSkillSlotBinding] = []
@export var auto_bind_on_ready: bool = true

var _controller: GaSkillController = null


func _ready() -> void:
	if auto_bind_on_ready:
		await get_tree().process_frame
		bind_skills()


func bind_skills() -> void:
	_controller = _resolve_controller()
	if _controller == null:
		push_warning("GaSkillBar: controller_path is not set or invalid.")
		return

	if slot_bindings.is_empty():
		_bind_discovered_slots()
	else:
		_bind_from_resources()

	_connect_controller_signals()


func assign_skills(skills: Array) -> void:
	for i in range(mini(skills.size(), get_child_count())):
		_assign_slot(get_child(i), skills[i])


func _resolve_controller() -> GaSkillController:
	if not controller_path.is_empty():
		return get_node_or_null(controller_path) as GaSkillController
	return null


func _bind_discovered_slots() -> void:
	for child in get_children():
		if child is GaSkillSlot:
			var slot := child as GaSkillSlot
			if slot.skill_id.is_empty():
				continue
			var skill := _controller.get_skill(slot.skill_id)
			slot.bind_to_controller(_controller, skill)


func _bind_from_resources() -> void:
	for binding in slot_bindings:
		if binding == null or binding.skill_id.is_empty():
			continue
		if binding.slot_index < 0 or binding.slot_index >= get_child_count():
			continue
		var slot_node := get_child(binding.slot_index)
		if slot_node is GaSkillSlot:
			var slot := slot_node as GaSkillSlot
			if not binding.input_action.is_empty():
				slot.input_action = binding.input_action
			slot.skill_id = binding.skill_id
			slot.bind_to_controller(_controller, _controller.get_skill(binding.skill_id))


func _assign_slot(slot_node: Node, skill: Node) -> void:
	if slot_node is GaSkillSlot and skill is GaSkill:
		(slot_node as GaSkillSlot).bind_to_controller(_controller, skill)


func _connect_controller_signals() -> void:
	if _controller.skill_registered.is_connected(_on_skill_registered):
		return
	_controller.skill_registered.connect(_on_skill_registered)


func _on_skill_registered(skill: GaSkill) -> void:
	for child in get_children():
		if child is GaSkillSlot:
			var slot := child as GaSkillSlot
			if slot.skill_id == skill.get_id():
				slot.bind_to_controller(_controller, skill)
