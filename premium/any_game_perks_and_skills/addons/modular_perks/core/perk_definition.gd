class_name PerkDefinition
extends Resource

const _Localization := preload("res://addons/modular_perks/core/localization_bridge.gd")

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var unlock_score_required: int = 0
@export var category: String = "utility"
@export var rarity: String = "common"
@export var repeatable: bool = false
@export var session_start_only: bool = false
@export var tags: PackedStringArray = PackedStringArray()
@export var effect_data: Dictionary = {}
@export var modifiers: Dictionary = {}


func get_localization_slug() -> String:
	return String(id).strip_edges()


func get_localized_name(host = null, key_prefix: String = "perk") -> String:
	if id == "":
		return display_name
	var key := "%s.%s.name" % [key_prefix, id]
	return _Localization.translate(host, key, display_name)


func get_localized_description(host = null, key_prefix: String = "perk") -> String:
	if id == "":
		return description
	var key := "%s.%s.description" % [key_prefix, id]
	var localized := String(_Localization.translate(host, key, description)).strip_edges()
	if localized != "":
		return localized
	return description


func is_locked(unlock_score: int) -> bool:
	return unlock_score < unlock_score_required


func get_effect_kind() -> String:
	return String(effect_data.get("kind", "")).strip_edges()


func requires_target_pick() -> bool:
	return bool(effect_data.get("requires_target_pick", false))


func requires_option_pick() -> bool:
	return bool(effect_data.get("requires_option_pick", false))
