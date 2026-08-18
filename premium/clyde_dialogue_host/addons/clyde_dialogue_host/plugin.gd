@tool
extends EditorPlugin

const HOST_SCRIPT := preload("res://addons/clyde_dialogue_host/core/clyde_dialogue_host.gd")


func _enter_tree() -> void:
	add_custom_type("ClydeDialogueHost", "Control", HOST_SCRIPT, _load_icon())


func _exit_tree() -> void:
	remove_custom_type("ClydeDialogueHost")


func _load_icon() -> Texture2D:
	var icon_path := "res://addons/clyde/editor/assets/clyde.svg"
	if ResourceLoader.exists(icon_path):
		return load(icon_path) as Texture2D
	return null
