extends "res://addons/modular_perks/effects/perk_effect.gd"


func get_kind() -> String:
	return "resource_bonus"


func apply(
	definition,
	state,
	host,
	context: Dictionary = {}
) -> void:
	var resource_id := String(definition.effect_data.get("resource_id", "gold"))
	var amount := int(definition.effect_data.get("amount", 0))
	if amount == 0:
		return
	host.apply_resource_bonus(resource_id, amount, context)
	state.record_instance({
		"perk_id": definition.id,
		"resource_id": resource_id,
		"amount": amount,
	})


func query(
	definition,
	_state,
	_host,
	_context: Dictionary = {}
) -> Variant:
	return int(definition.effect_data.get("amount", 0))
