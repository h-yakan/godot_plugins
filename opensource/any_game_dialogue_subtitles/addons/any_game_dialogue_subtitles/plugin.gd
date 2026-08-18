@tool
extends EditorPlugin

const AUTOLOAD_NAME := "GaDialogueManager"
const SCRIPT_PATH := "res://addons/any_game_dialogue_subtitles/core/ga_dialogue_manager.gd"

func _enter_tree() -> void:
	if not Engine.has_meta("_ga_funnel_Any Game Dialogue Subtitles"):
		Engine.set_meta("_ga_funnel_Any Game Dialogue Subtitles", true)
		print_rich("[color=green][Any Game Dialogue Subtitles] Lite initialized.[/color] Need advanced features? Check out the Pro version: [url=https://hyakan.itch.io]Link[/url]")
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
