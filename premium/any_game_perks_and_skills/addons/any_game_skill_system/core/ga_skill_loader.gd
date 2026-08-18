extends RefCounted
class_name GaSkillLoader


static func load_skill_scene(skill_id: String, ability_root_path: String) -> PackedScene:
	var scene_path := scene_path_for(skill_id, ability_root_path)
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("GaSkillLoader: failed to load skill scene at '%s'." % scene_path)
	return scene


static func scene_path_for(skill_id: String, ability_root_path: String) -> String:
	var root := ability_root_path.rstrip("/")
	return "%s/%s/%s.tscn" % [root, skill_id, skill_id]


static func instantiate_skill(
	skill_id: String,
	ability_root_path: String,
	parent: Node,
	container_path: NodePath = NodePath("")
) -> GaSkill:
	var scene := load_skill_scene(skill_id, ability_root_path)
	if scene == null:
		return null
	return _add_skill_instance(scene.instantiate(), parent, container_path, skill_id)


static func instantiate_from_definition(
	definition: GaSkillDefinition,
	parent: Node,
	container_path: NodePath = NodePath("")
) -> GaSkill:
	if definition == null:
		return null
	var scene := definition.scene
	if scene == null:
		push_error("GaSkillLoader: definition '%s' has no scene assigned." % definition.get_id())
		return null
	var instance := scene.instantiate()
	if not instance is GaSkill:
		instance.queue_free()
		push_error("GaSkillLoader: scene for '%s' must instantiate GaSkill." % definition.get_id())
		return null
	var skill := instance as GaSkill
	skill.definition = definition
	return _add_skill_instance(skill, parent, container_path, definition.get_id())


static func _add_skill_instance(
	instance: Node,
	parent: Node,
	container_path: NodePath,
	label: String
) -> GaSkill:
	if not instance is GaSkill:
		instance.queue_free()
		push_error("GaSkillLoader: '%s' must instantiate GaSkill." % label)
		return null
	var skill := instance as GaSkill
	if container_path.is_empty():
		parent.add_child(skill)
	else:
		var container := parent.get_node_or_null(container_path)
		if container == null:
			push_error("GaSkillLoader: container path '%s' not found on '%s'." % [container_path, parent.name])
			skill.queue_free()
			return null
		container.add_child(skill)
	return skill
