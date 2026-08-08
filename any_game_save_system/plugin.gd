@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GaSaveManager"
const SCRIPT_PATH := "res://godot_plugins/any_game_save_system/scripts/ga_save_manager.gd"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
