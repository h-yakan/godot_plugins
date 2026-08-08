extends "res://godot_plugins/modular_perks/effects/perk_effect.gd"


func get_kind() -> String:
	return "option_pick"


func apply(
	definition,
	state,
	host,
	context: Dictionary = {}
) -> void:
	var option_id := String(context.get("option_id", ""))
	if option_id == "":
		return
	host.apply_option_choice(option_id, context)
	state.record_instance({
		"perk_id": definition.id,
		"option_id": option_id,
	})


func query(
	definition,
	_state,
	_host,
	_context: Dictionary = {}
) -> Variant:
	return definition.effect_data.get("option_group", "")
