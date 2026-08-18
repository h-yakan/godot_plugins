extends GaSkill
class_name GaSpamPulse

## Sample spammable skill: no cooldown, no cost.


func _do_activate(context: GaSkillContext) -> bool:
	context.data["pulse_count"] = context.data.get("pulse_count", 0) + 1
	return true
