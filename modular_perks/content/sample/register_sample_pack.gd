class_name SamplePerkPack
extends RefCounted

const BASE_PATH := "res://addons/modular_perks/content/sample/"
const CatalogScript := preload("res://addons/modular_perks/content/sample/sample_catalog.gd")


static func register(api) -> void:
	for definition in CatalogScript.build_definitions():
		api.register_definition(definition)
	api.register_effect_handler(load(BASE_PATH + "handlers/sample_resource_bonus_effect.gd").new())
	api.register_effect_handler(load(BASE_PATH + "handlers/sample_stat_multiply_effect.gd").new())
	api.register_effect_handler(load(BASE_PATH + "handlers/sample_option_pick_effect.gd").new())


static func get_content_dir() -> String:
	return BASE_PATH.path_join("perks")
