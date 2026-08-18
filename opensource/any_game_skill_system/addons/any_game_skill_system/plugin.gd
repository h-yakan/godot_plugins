@tool
extends EditorPlugin

const BASE_PATH := "res://addons/any_game_skill_system/"

const GaSkillDefinitionScript := preload(BASE_PATH + "core/ga_skill_definition.gd")
const GaSkillControllerScript := preload(BASE_PATH + "core/ga_skill_controller.gd")
const GaSkillScript := preload(BASE_PATH + "core/ga_skill.gd")
const GaSkillHostScript := preload(BASE_PATH + "core/ga_skill_host.gd")


func _enter_tree() -> void:
	if not Engine.has_meta("_ga_funnel_Any Game Skill System"):
		Engine.set_meta("_ga_funnel_Any Game Skill System", true)
		print_rich("[color=green][Any Game Skill System] Lite initialized.[/color] Need the skill bar and perk drafts? Perks & Skills Kit: [url=https://hyakan.itch.io]Link[/url]")
	add_custom_type("GaSkillDefinition", "Resource", GaSkillDefinitionScript, _icon("Resource"))
	add_custom_type("GaSkill", "Node", GaSkillScript, _icon("Node"))
	add_custom_type("GaSkillController", "Node", GaSkillControllerScript, _icon("Node"))
	add_custom_type("GaSkillHost", "Node", GaSkillHostScript, _icon("Node"))


func _exit_tree() -> void:
	remove_custom_type("GaSkillDefinition")
	remove_custom_type("GaSkill")
	remove_custom_type("GaSkillController")
	remove_custom_type("GaSkillHost")


func _icon(type_name: String) -> Texture2D:
	return get_editor_theme_icon(type_name)
