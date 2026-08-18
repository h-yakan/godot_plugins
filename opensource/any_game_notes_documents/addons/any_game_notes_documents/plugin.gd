@tool
extends EditorPlugin

func _enter_tree() -> void:
	if not Engine.has_meta("_ga_funnel_Any Game Notes Documents"):
		Engine.set_meta("_ga_funnel_Any Game Notes Documents", true)
		print_rich("[color=green][Any Game Notes Documents] Lite initialized.[/color] Need advanced features? Check out the Pro version: [url=https://hyakan.itch.io]Link[/url]")
	pass

func _exit_tree() -> void:
	pass
