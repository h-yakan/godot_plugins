class_name PerkHost
extends RefCounted

## Implement in your game to connect domain systems to the perk framework.


func get_unlock_score() -> int:
	return 0


func translate(key: String, fallback: String) -> String:
	return fallback


func list_target_entities(context: Dictionary) -> Array:
	return []


func list_option_choices(context: Dictionary) -> Array:
	return []


func on_pick_applied(perk_id: String, state, context: Dictionary = {}) -> void:
	pass


func apply_resource_bonus(resource_id: String, amount: int, context: Dictionary = {}) -> void:
	pass


func apply_stat_multiplier(
	entity_id: String,
	stat_id: String,
	multiplier: float,
	context: Dictionary = {}
) -> void:
	pass


func apply_option_choice(option_id: String, context: Dictionary = {}) -> void:
	pass
