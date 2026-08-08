@tool
extends EditorPlugin

const BASE_PATH := "res://godot_plugins/any_game_skill_system/"

const GaSkillDefinitionScript := preload(BASE_PATH + "scripts/core/ga_skill_definition.gd")
const GaSkillContextScript := preload(BASE_PATH + "scripts/core/ga_skill_context.gd")
const GaSkillControllerScript := preload(BASE_PATH + "scripts/core/ga_skill_controller.gd")
const GaSkillSlotBindingScript := preload(BASE_PATH + "scripts/ui/ga_skill_slot_binding.gd")
const GaSkillScript := preload(BASE_PATH + "scripts/ga_skill.gd")
const GaSkillHostScript := preload(BASE_PATH + "scripts/ga_skill_host.gd")
const GaSkillBarScript := preload(BASE_PATH + "scripts/ga_skill_bar.gd")
const GaSkillSlotScript := preload(BASE_PATH + "scripts/ga_skill_slot.gd")
const GaSkillTooltipScript := preload(BASE_PATH + "scripts/ga_skill_tooltip.gd")


func _enter_tree() -> void:
	add_custom_type("GaSkillDefinition", "Resource", GaSkillDefinitionScript, _icon("Resource"))
	add_custom_type("GaSkillSlotBinding", "Resource", GaSkillSlotBindingScript, _icon("Resource"))
	add_custom_type("GaSkill", "Node", GaSkillScript, _icon("Node"))
	add_custom_type("GaSkillController", "Node", GaSkillControllerScript, _icon("Node"))
	add_custom_type("GaSkillHost", "Node", GaSkillHostScript, _icon("Node"))
	add_custom_type("GaSkillBar", "HBoxContainer", GaSkillBarScript, _icon("HBoxContainer"))
	add_custom_type("GaSkillSlot", "TextureButton", GaSkillSlotScript, _icon("TextureButton"))
	add_custom_type("GaSkillTooltip", "PanelContainer", GaSkillTooltipScript, _icon("PanelContainer"))


func _exit_tree() -> void:
	remove_custom_type("GaSkillDefinition")
	remove_custom_type("GaSkillSlotBinding")
	remove_custom_type("GaSkill")
	remove_custom_type("GaSkillController")
	remove_custom_type("GaSkillHost")
	remove_custom_type("GaSkillBar")
	remove_custom_type("GaSkillSlot")
	remove_custom_type("GaSkillTooltip")


func _icon(type_name: String) -> Texture2D:
	return get_editor_theme_icon(type_name)
