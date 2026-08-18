extends RefCounted
class_name GaSkillContext

## Per-activation context passed into skills. Games extend via `data`.

var caster: Node = null
var target: Node = null
var world: Node = null
var cost_provider: GaSkillCostProvider = null
var data: Dictionary = {}


static func from_caster(caster_node: Node, target_node: Node = null) -> GaSkillContext:
	var context := GaSkillContext.new()
	context.caster = caster_node
	context.target = target_node
	if caster_node and caster_node.is_inside_tree():
		context.world = caster_node.get_tree().current_scene
	return context


func with_data(key: StringName, value: Variant) -> GaSkillContext:
	data[key] = value
	return self


func get_data(key: StringName, default: Variant = null) -> Variant:
	return data.get(key, default)
