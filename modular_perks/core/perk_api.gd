class_name PerkAPI
extends RefCounted

const ConfigScript := preload("res://addons/modular_perks/core/perk_config.gd")
const RegistryScript := preload("res://addons/modular_perks/core/perk_registry.gd")
const DraftScript := preload("res://addons/modular_perks/core/perk_draft_service.gd")
const EffectBusScript := preload("res://addons/modular_perks/effects/perk_effect_bus.gd")
const NullHostScript := preload("res://addons/modular_perks/host/null_perk_host.gd")

var config
var registry
var draft
var effects
var host


func _init(initial_host = null, initial_config = null) -> void:
	config = initial_config if initial_config != null else ConfigScript.new()
	host = initial_host if initial_host != null else NullHostScript.new()
	registry = RegistryScript.new(config)
	draft = DraftScript.new(registry, config)
	effects = EffectBusScript.new()


func set_host(next_host) -> void:
	host = next_host if next_host != null else NullHostScript.new()


func configure(next_config) -> void:
	config = next_config.duplicate_config()
	registry.configure(config)
	draft = DraftScript.new(registry, config)


func register_definition(definition) -> void:
	registry.register_definition(definition)


func register_pack_from_dir(content_dir: String) -> int:
	return registry.register_pack_from_dir(content_dir)


func register_effect_handler(handler) -> void:
	effects.register_handler(handler)


func get_unlock_score() -> int:
	return int(host.get_unlock_score())


func roll_offers(
	state,
	count: int = 3,
	preview_locked: bool = false,
	selection_mode: String = "default"
) -> Array:
	return draft.roll_selection_offers(
		get_unlock_score(),
		state,
		count,
		preview_locked,
		selection_mode
	)


func resolve_gate(
	gate_id: String,
	state,
	selection_mode: String = "default"
) -> Array:
	return draft.resolve_gate(gate_id, get_unlock_score(), state, selection_mode)


func apply_pick(
	state,
	perk_id: String,
	preview_only: bool = false,
	context: Dictionary = {}
) -> void:
	draft.apply_pick(state, perk_id, preview_only)
	var definition = registry.get_perk(perk_id)
	if definition != null:
		effects.apply_for_definition(definition, state, host, context)
	host.on_pick_applied(perk_id, state, context)


func requires_target_pick(perk_id: String) -> bool:
	var definition = registry.get_perk(perk_id)
	return definition != null and bool(definition.requires_target_pick())


func requires_option_pick(perk_id: String) -> bool:
	var definition = registry.get_perk(perk_id)
	return definition != null and bool(definition.requires_option_pick())


func get_localized_name(definition) -> String:
	return String(definition.get_localized_name(host, String(config.localization_key_prefix)))


func get_localized_description(definition) -> String:
	return String(definition.get_localized_description(host, String(config.localization_key_prefix)))


func get_category_color(category: String) -> Color:
	return config.get_category_color(category)


func get_rarity_color(rarity: String) -> Color:
	return config.get_rarity_color(rarity)


func query_effect(kind: String, state, context: Dictionary = {}) -> Array:
	return effects.query_active(state.active_ids, registry, state, host, kind, context)
