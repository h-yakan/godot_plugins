extends GaSkill
class_name GaToggleShield

## Sample toggle: damage reduction while active, ticks optionally.


@export var damage_reduction: float = 0.25

var _active: bool = false


func _do_activate(context: GaSkillContext) -> bool:
	_active = true
	context.data["damage_reduction"] = damage_reduction
	return true


func _do_deactivate(context: GaSkillContext) -> bool:
	_active = false
	context.data.erase("damage_reduction")
	return true


func _process_skill(delta: float, context: GaSkillContext) -> void:
	if not _active:
		return
	context.data["shield_uptime"] = context.data.get("shield_uptime", 0.0) + delta
