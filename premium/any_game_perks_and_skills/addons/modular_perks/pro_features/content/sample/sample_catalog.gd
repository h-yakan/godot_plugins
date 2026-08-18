class_name SamplePerkCatalog
extends RefCounted

const DefinitionScript := preload("res://addons/modular_perks/core/perk_definition.gd")


static func build_definitions() -> Array:
	var entries: Array[Dictionary] = [
		{
			"id": "sample_keen_eye",
			"display_name": "Keen Eye",
			"description": "Gain a small resource bonus when picked.",
			"unlock_score_required": 0,
			"category": "utility",
			"rarity": "common",
			"effect_data": {"kind": "resource_bonus", "resource_id": "insight", "amount": 5},
		},
		{
			"id": "sample_quick_step",
			"display_name": "Quick Step",
			"description": "Multiply a target entity stat after you choose a target.",
			"unlock_score_required": 100,
			"category": "combat",
			"rarity": "uncommon",
			"effect_data": {
				"kind": "stat_multiply",
				"stat_id": "speed",
				"multiplier": 1.25,
				"requires_target_pick": true,
			},
		},
		{
			"id": "sample_trade_token",
			"display_name": "Trade Token",
			"description": "Repeatable economy perk that grants extra currency.",
			"unlock_score_required": 200,
			"category": "economy",
			"rarity": "rare",
			"repeatable": true,
			"effect_data": {"kind": "resource_bonus", "resource_id": "credits", "amount": 10},
		},
		{
			"id": "sample_opening_gift",
			"display_name": "Opening Gift",
			"description": "Only available during session start selection.",
			"unlock_score_required": 0,
			"category": "utility",
			"rarity": "epic",
			"session_start_only": true,
			"effect_data": {"kind": "resource_bonus", "resource_id": "supplies", "amount": 20},
		},
		{
			"id": "sample_focus_choice",
			"display_name": "Focus Choice",
			"description": "Pick one of several options provided by the host.",
			"unlock_score_required": 150,
			"category": "utility",
			"rarity": "rare",
			"effect_data": {
				"kind": "option_pick",
				"option_group": "focus",
				"requires_option_pick": true,
			},
		},
	]
	var definitions: Array = []
	for entry in entries:
		definitions.append(_build_definition(entry))
	return definitions


static func _build_definition(entry: Dictionary):
	var definition = DefinitionScript.new()
	definition.id = String(entry.get("id", ""))
	definition.display_name = String(entry.get("display_name", ""))
	definition.description = String(entry.get("description", ""))
	definition.unlock_score_required = int(entry.get("unlock_score_required", 0))
	definition.category = String(entry.get("category", "utility"))
	definition.rarity = String(entry.get("rarity", "common"))
	definition.repeatable = bool(entry.get("repeatable", false))
	definition.session_start_only = bool(entry.get("session_start_only", false))
	if entry.has("effect_data"):
		definition.effect_data = (entry.get("effect_data", {}) as Dictionary).duplicate(true)
	if entry.has("modifiers"):
		definition.modifiers = (entry.get("modifiers", {}) as Dictionary).duplicate(true)
	return definition
