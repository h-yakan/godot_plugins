class_name PerkModuleLoader
extends RefCounted

const BASE := "res://addons/modular_perks/"


static func preload_all() -> void:
	preload(BASE + "core/perk_config.gd")
	preload(BASE + "core/localization_bridge.gd")
	preload(BASE + "host/perk_host.gd")
	preload(BASE + "host/null_perk_host.gd")
	preload(BASE + "core/perk_definition.gd")
	preload(BASE + "core/perk_run_state.gd")
	preload(BASE + "core/perk_registry.gd")
	preload(BASE + "core/perk_draft_service.gd")
	preload(BASE + "effects/perk_effect.gd")
	preload(BASE + "effects/perk_effect_bus.gd")
	preload(BASE + "core/perk_api.gd")
	preload(BASE + "pro_features/content/sample/handlers/sample_resource_bonus_effect.gd")
	preload(BASE + "pro_features/content/sample/handlers/sample_stat_multiply_effect.gd")
	preload(BASE + "pro_features/content/sample/handlers/sample_option_pick_effect.gd")
	preload(BASE + "pro_features/content/sample/sample_catalog.gd")
	preload(BASE + "pro_features/content/sample/register_sample_pack.gd")


static func create_api(host: Variant = null) -> Object:
	preload_all()
	var api_script: GDScript = load(BASE + "core/perk_api.gd")
	if host == null:
		return api_script.new()
	return api_script.new(host)


static func create_run_state() -> Object:
	preload_all()
	var state_script: GDScript = load(BASE + "core/perk_run_state.gd")
	return state_script.new()


static func create_null_host() -> Object:
	preload_all()
	var host_script: GDScript = load(BASE + "host/null_perk_host.gd")
	return host_script.new()


static func register_sample_pack(api: Object) -> void:
	preload_all()
	var pack_script: GDScript = load(BASE + "pro_features/content/sample/register_sample_pack.gd")
	pack_script.register(api)


static func sample_content_dir() -> String:
	return BASE + "pro_features/content/sample/perks"
