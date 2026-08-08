extends Control

signal selection_completed(perk_id: String, offer: Dictionary)

const CARD_SCENE := preload("res://addons/modular_perks/ui/perk_card.tscn")

@onready var _title: Label = %Title
@onready var _cards_row: HBoxContainer = %CardsRow
@onready var _confirm_button: Button = %ConfirmButton

var _api = null
var _state = null
var _offers: Array = []
var _selection_mode: String = "default"
var _preview_locked: bool = false
var _selected_index := -1
var _cards: Array = []


func configure(api, state) -> void:
	_api = api
	_state = state


func present_offers(offers: Array, selection_mode: String = "default", preview_locked: bool = false) -> void:
	_offers = offers.duplicate(true)
	_selection_mode = selection_mode
	_preview_locked = preview_locked
	_selected_index = -1
	_rebuild_cards()
	_confirm_button.disabled = true


func _ready() -> void:
	_confirm_button.pressed.connect(_on_confirm_pressed)


func _rebuild_cards() -> void:
	for child in _cards_row.get_children():
		child.queue_free()
	_cards.clear()
	for index in _offers.size():
		var card := CARD_SCENE.instantiate()
		_cards_row.add_child(card)
		card.configure(_api)
		card.bind_offer(_offers[index])
		var captured_index := index
		card.card_clicked.connect(func() -> void:
			_select_index(captured_index)
		)
		_cards.append(card)


func _select_index(index: int) -> void:
	_selected_index = index
	for card_index in _cards.size():
		_cards[card_index].set_selected(card_index == index)
	_confirm_button.disabled = false


func _on_confirm_pressed() -> void:
	if _selected_index < 0 or _selected_index >= _offers.size():
		return
	var offer: Dictionary = _offers[_selected_index]
	var kind := String(offer.get("kind", ""))
	if kind == "reroll":
		_handle_reroll()
		return
	if offer.has("id") and String(offer.get("id", "")).begins_with("gate_"):
		_handle_gate(String(offer.get("id", "")))
		return
	var perk_id := String(offer.get("perk_id", ""))
	if perk_id == "":
		return
	selection_completed.emit(perk_id, offer)


func _handle_reroll() -> void:
	_preview_locked = true
	var rerolled := _api.roll_offers(_state, 3, true, _selection_mode)
	present_offers(rerolled, _selection_mode, true)


func _handle_gate(gate_id: String) -> void:
	var gate_offers: Array = []
	for definition in _api.resolve_gate(gate_id, _state, _selection_mode):
		gate_offers.append({
			"kind": "perk",
			"perk_id": String(definition.id),
			"perk": definition,
			"preview_only": false,
		})
	present_offers(gate_offers, _selection_mode, _preview_locked)
