extends Control
class_name GaReadNoteUI

const _EventBus := preload("res://addons/any_game_notes_documents/core/ga_event_bus_client.gd")

@export var rich_text_path: NodePath = ^"RichTextLabel"
@export var close_actions: Array[StringName] = [&"interact", &"pause"]

var reading: bool = false
@onready var rich_text_label: RichTextLabel = get_node_or_null(rich_text_path)

func _ready() -> void:
	hide()
	_EventBus.listen(self, &"show_note", show_text)

func show_text(text: String) -> void:
	if rich_text_label:
		rich_text_label.text = text
	show()
	if reading:
		return
	_EventBus.emit(self, &"toggle_ui")
	_EventBus.emit(self, &"player_look_switch", [false])
	_EventBus.emit(self, &"player_move_switch", [false])
	reading = true

func _input(event: InputEvent) -> void:
	if not reading:
		return
	for action in close_actions:
		if event.is_action_pressed(action):
			_close()
			get_viewport().set_input_as_handled()
			return

func _close() -> void:
	_EventBus.emit(self, &"toggle_ui")
	_EventBus.emit(self, &"player_look_switch", [true])
	_EventBus.emit(self, &"player_move_switch", [true])
	hide()
	reading = false
