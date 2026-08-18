@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GaSaveManager"
const SCRIPT_PATH := "res://addons/any_game_save_system/core/ga_save_manager.gd"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
