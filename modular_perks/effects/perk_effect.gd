class_name PerkEffect
extends RefCounted

## Override in content packs or host adapters.


func supports(definition, _context: Dictionary = {}) -> bool:
	if definition == null:
		return false
	var kind := String(definition.get_effect_kind()).strip_edges()
	return kind != "" and kind == get_kind()


func get_kind() -> String:
	return ""


func query(
	_definition,
	_state,
	_host,
	_context: Dictionary = {}
) -> Variant:
	return null


func apply(
	definition,
	state,
	host,
	context: Dictionary = {}
) -> void:
	pass
