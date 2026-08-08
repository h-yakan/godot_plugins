extends Control

signal flow_finished(confirmed: bool, context: Dictionary)

@onready var _title: Label = %Title
@onready var _list: ItemList = %EntityList
@onready var _confirm_button: Button = %ConfirmButton
@onready var _cancel_button: Button = %CancelButton

var _entities: Array[Dictionary] = []
var _context: Dictionary = {}


func present(title_text: String, entities: Array[Dictionary], context: Dictionary = {}) -> void:
	_title.text = title_text
	_entities = entities.duplicate(true)
	_context = context.duplicate(true)
	_list.clear()
	for entity in _entities:
		var label := String(entity.get("label", entity.get("id", "Entity")))
		_list.add_item(label)
	_confirm_button.disabled = _entities.is_empty()


func _ready() -> void:
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)


func _on_confirm_pressed() -> void:
	var selected := _list.get_selected_items()
	if selected.is_empty():
		return
	var entity := _entities[selected[0]]
	var result_context := _context.duplicate(true)
	result_context["entity_id"] = String(entity.get("id", ""))
	result_context["entity"] = entity.duplicate(true)
	flow_finished.emit(true, result_context)


func _on_cancel_pressed() -> void:
	flow_finished.emit(false, {})
