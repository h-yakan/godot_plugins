@tool
extends EditorPlugin

const BASE_PATH := "res://addons/modular_perks/"
const PerkDefinitionScript := preload(BASE_PATH + "core/perk_definition.gd")
const PerkConfigScript := preload(BASE_PATH + "core/perk_config.gd")


func _enter_tree() -> void:
	add_custom_type("PerkDefinition", "Resource", PerkDefinitionScript, get_editor_icon())
	add_custom_type("PerkConfig", "Resource", PerkConfigScript, get_editor_icon())


func _exit_tree() -> void:
	remove_custom_type("PerkDefinition")
	remove_custom_type("PerkConfig")


func get_editor_icon() -> Texture2D:
	return get_editor_theme_icon("Resource")


func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass
