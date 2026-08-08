class_name PerkConfig
extends Resource

const DEFAULT_CATEGORY_UTILITY := "utility"
const DEFAULT_CATEGORY_COMBAT := "combat"
const DEFAULT_CATEGORY_ECONOMY := "economy"

const DEFAULT_RARITY_COMMON := "common"
const DEFAULT_RARITY_UNCOMMON := "uncommon"
const DEFAULT_RARITY_RARE := "rare"
const DEFAULT_RARITY_EPIC := "epic"

@export var offer_weight_perk: float = 0.85
@export var offer_weight_gate: float = 0.10
@export var offer_weight_reroll: float = 0.05
@export var gate_min_available: int = 3
@export var localization_key_prefix: String = "perk"
@export var categories: PackedStringArray = PackedStringArray([
	DEFAULT_CATEGORY_UTILITY,
	DEFAULT_CATEGORY_COMBAT,
	DEFAULT_CATEGORY_ECONOMY,
])
@export var category_colors: Dictionary = {
	DEFAULT_CATEGORY_UTILITY: Color(0.42, 0.62, 0.98),
	DEFAULT_CATEGORY_COMBAT: Color(0.95, 0.38, 0.38),
	DEFAULT_CATEGORY_ECONOMY: Color(0.45, 0.92, 0.55),
}
@export var rarity_colors: Dictionary = {
	DEFAULT_RARITY_COMMON: Color("#9AA3B2"),
	DEFAULT_RARITY_UNCOMMON: Color("#5CB85C"),
	DEFAULT_RARITY_RARE: Color("#4DA6FF"),
	DEFAULT_RARITY_EPIC: Color("#C77DFF"),
}
var gates: Array = [
	{"id": "gate_utility", "category": DEFAULT_CATEGORY_UTILITY},
	{"id": "gate_combat", "category": DEFAULT_CATEGORY_COMBAT},
	{"id": "gate_economy", "category": DEFAULT_CATEGORY_ECONOMY},
]


func duplicate_config():
	var copy = preload("res://godot_plugins/modular_perks/core/perk_config.gd").new()
	copy.offer_weight_perk = offer_weight_perk
	copy.offer_weight_gate = offer_weight_gate
	copy.offer_weight_reroll = offer_weight_reroll
	copy.gate_min_available = gate_min_available
	copy.localization_key_prefix = localization_key_prefix
	copy.categories = categories.duplicate()
	copy.category_colors = category_colors.duplicate(true)
	copy.rarity_colors = rarity_colors.duplicate(true)
	copy.gates = gates.duplicate(true)
	return copy


func get_category_color(category: String) -> Color:
	return category_colors.get(String(category), Color(0.7, 0.7, 0.7, 1.0))


func get_rarity_color(rarity: String) -> Color:
	var raw = rarity_colors.get(String(rarity), "#8892A3")
	if raw is Color:
		return raw
	return Color(String(raw))


func get_gate_category(gate_id: String) -> String:
	for gate in gates:
		if String(gate.get("id", "")) == String(gate_id):
			return String(gate.get("category", ""))
	return ""


func get_category_gates() -> Array:
	var result: Array = []
	for gate in gates:
		result.append((gate as Dictionary).duplicate(true))
	return result
