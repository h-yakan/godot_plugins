extends Control
class_name GaReadNoteUI

@export var rich_text_path: NodePath = ^"RichTextLabel"
@export var close_actions: Array[StringName] = [&"interact", &"pause"]

var reading: bool = false
@onready var rich_text_label: RichTextLabel = get_node_or_null(rich_text_path)

func _ready() -> void:
	hide()
	if GaEventBus:
		GaEventBus.show_note.connect(show_text)

func show_text(text: String) -> void:
	show()
	if rich_text_label:
		rich_text_label.text = text
	if GaEventBus:
		GaEventBus.toggle_ui.emit()
		GaEventBus.player_look_switch.emit(false)
		GaEventBus.player_move_switch.emit(false)
	reading = true

func _unhandled_input(event: InputEvent) -> void:
	if not reading:
		return
	for action in close_actions:
		if event.is_action_pressed(action):
			_close()
			get_viewport().set_input_as_handled()
			return

func _close() -> void:
	if GaEventBus:
		GaEventBus.toggle_ui.emit()
		GaEventBus.player_look_switch.emit(true)
		GaEventBus.player_move_switch.emit(true)
	hide()
	reading = false
