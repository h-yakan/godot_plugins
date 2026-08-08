extends RefCounted
class_name GaSkillCostProvider

## Game-side resource bridge. Override or assign on GaSkillController.


func can_afford(caster: Node, resource_id: StringName, amount: float) -> bool:
	return get_amount(caster, resource_id) >= amount


func spend(caster: Node, resource_id: StringName, amount: float) -> bool:
	if not can_afford(caster, resource_id, amount):
		return false
	_apply_spend(caster, resource_id, amount)
	return true


func get_amount(_caster: Node, _resource_id: StringName) -> float:
	return INF


func _apply_spend(_caster: Node, _resource_id: StringName, _amount: float) -> void:
	pass
