extends GaSkill
class_name GaAlwaysAura

## Sample always-active aura: runs from register and ticks while active.


@export var dps: float = 2.0


func _do_activate(context: GaSkillContext) -> bool:
	context.data["aura_active"] = true
	return true


func _process_skill(delta: float, context: GaSkillContext) -> void:
	if not context.data.get("aura_active", false):
		return
	context.data["aura_damage"] = context.data.get("aura_damage", 0.0) + dps * delta
