@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GaEventBus"
const SCRIPT_PATH := "res://addons/any_game_event_bus/core/scripts/ga_event_bus.gd"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
