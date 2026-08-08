extends "res://addons/modular_perks/effects/perk_effect.gd"


func get_kind() -> String:
	return "stat_multiply"


func apply(
	definition,
	state,
	host,
	context: Dictionary = {}
) -> void:
	var entity_id := String(context.get("entity_id", ""))
	var stat_id := String(context.get("stat_id", definition.effect_data.get("stat_id", "power")))
	var multiplier := float(context.get("multiplier", definition.effect_data.get("multiplier", 1.0)))
	if entity_id == "" or multiplier <= 0.0:
		return
	host.apply_stat_multiplier(entity_id, stat_id, multiplier, context)
	state.record_instance({
		"perk_id": definition.id,
		"entity_id": entity_id,
		"stat_id": stat_id,
		"multiplier": multiplier,
	})


func query(
	definition,
	_state,
	_host,
	_context: Dictionary = {}
) -> Variant:
	return float(definition.effect_data.get("multiplier", 1.0))
