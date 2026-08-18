extends GaSkillCostProvider
class_name GaSimpleManaProvider

## Reference cost provider storing mana on the caster node.

@export var resource_property: StringName = &"mana"


func get_amount(caster: Node, resource_id: StringName) -> float:
	if resource_id != &"mana" or caster == null:
		return INF
	if resource_property in caster:
		return float(caster.get(resource_property))
	return 0.0


func _apply_spend(caster: Node, resource_id: StringName, amount: float) -> void:
	if resource_id != &"mana" or caster == null:
		return
	if resource_property in caster:
		caster.set(resource_property, get_amount(caster, resource_id) - amount)
