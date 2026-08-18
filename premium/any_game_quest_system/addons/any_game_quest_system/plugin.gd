@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GaQuestManager"
const SCRIPT_PATH := "res://addons/any_game_quest_system/core/ga_quest_manager.gd"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
