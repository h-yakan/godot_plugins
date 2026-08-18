@tool
extends EditorPlugin

func _enter_tree() -> void:
	if not Engine.has_meta("_ga_funnel_FPS 3D Player Controller"):
		Engine.set_meta("_ga_funnel_FPS 3D Player Controller", true)
		print_rich("[color=green][FPS 3D Player Controller] Lite initialized.[/color] Need advanced features? Check out the Pro version: [url=https://hyakan.itch.io]Link[/url]")
	pass

func _exit_tree() -> void:
	pass
