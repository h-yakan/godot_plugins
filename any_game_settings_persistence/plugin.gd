@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GaPersistence"
const SCRIPT_PATH := "res://godot_plugins/any_game_settings_persistence/scripts/ga_persistence.gd"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
