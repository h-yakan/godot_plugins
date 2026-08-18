class_name NullPerkHost
extends "res://addons/modular_perks/host/perk_host.gd"

var unlock_score: int = 9999
var target_entities: Array[Dictionary] = []
var option_choices: Array[Dictionary] = []
var applied_picks: Array[String] = []
var resource_bonuses: Array[Dictionary] = []
var stat_multipliers: Array[Dictionary] = []
var option_applications: Array[Dictionary] = []


func get_unlock_score() -> int:
	return unlock_score


func list_target_entities(_context: Dictionary) -> Array[Dictionary]:
	return target_entities.duplicate(true)


func list_option_choices(_context: Dictionary) -> Array[Dictionary]:
	return option_choices.duplicate(true)


func on_pick_applied(perk_id: String, _state, _context: Dictionary = {}) -> void:
	applied_picks.append(perk_id)


func apply_resource_bonus(resource_id: String, amount: int, context: Dictionary = {}) -> void:
	resource_bonuses.append({
		"resource_id": resource_id,
		"amount": amount,
		"context": context.duplicate(true),
	})


func apply_stat_multiplier(
	entity_id: String,
	stat_id: String,
	multiplier: float,
	context: Dictionary = {}
) -> void:
	stat_multipliers.append({
		"entity_id": entity_id,
		"stat_id": stat_id,
		"multiplier": multiplier,
		"context": context.duplicate(true),
	})


func apply_option_choice(option_id: String, context: Dictionary = {}) -> void:
	option_applications.append({
		"option_id": option_id,
		"context": context.duplicate(true),
	})
