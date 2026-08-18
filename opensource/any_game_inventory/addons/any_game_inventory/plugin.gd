@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GaInventoryManager"
const SCRIPT_PATH := "res://addons/any_game_inventory/core/ga_inventory_manager.gd"

func _enter_tree() -> void:
	if not Engine.has_meta("_ga_funnel_Any Game Inventory"):
		Engine.set_meta("_ga_funnel_Any Game Inventory", true)
		print_rich("[color=green][Any Game Inventory] Lite initialized.[/color] Need advanced features? Check out the Pro version: [url=https://hyakan.itch.io]Link[/url]")
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
