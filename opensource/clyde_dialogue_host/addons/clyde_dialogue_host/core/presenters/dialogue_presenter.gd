class_name DialoguePresenter
extends Node

## Abstract UI adapter for ClydeDialogueHost.
## Override show_line / show_options or connect to option_selected from custom UI.

signal option_selected(index: int, text: String)


func setup(_host: ClydeDialogueHost) -> void:
	pass


func set_dialogue_visible(active: bool) -> void:
	visible = active


func clear() -> void:
	pass


func show_line(_speaker: String, _text: String) -> void:
	push_warning("DialoguePresenter: show_line not implemented on %s" % get_class())


func show_options(_title: String, _options: Array) -> void:
	push_warning("DialoguePresenter: show_options not implemented on %s" % get_class())
