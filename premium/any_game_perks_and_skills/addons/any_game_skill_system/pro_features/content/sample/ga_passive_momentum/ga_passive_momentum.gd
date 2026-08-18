extends GaSkill
class_name GaPassiveMomentum

## Sample passive: applied once on register.


func _apply_passive(context: GaSkillContext) -> bool:
	if context.caster:
		context.data["move_speed_bonus"] = context.data.get("move_speed_bonus", 0.0) + 0.1
	return true
