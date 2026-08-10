extends Control

signal selection_completed(perk_id: String, offer: Dictionary)

const CARD_SCENE := preload("res://addons/modular_perks/ui/perk_card.tscn")

enum CardsLayout { HORIZONTAL, VERTICAL }

## Default layout when the scene's %CardsRow is missing or needs replacement.
@export var cards_layout: CardsLayout = CardsLayout.HORIZONTAL
@export var title_text: String = "Choose a perk"
@export var subtitle_text: String = "Pick one perk"
@export var confirm_text: String = "Confirm"
@export var card_min_size_horizontal: Vector2 = Vector2(220, 280)
@export var card_min_size_vertical: Vector2 = Vector2(0, 180)

@onready var _title: Label = %Title
@onready var _confirm_button: Button = %ConfirmButton

var _subtitle: Label = null
var _cards_row: Container = null
var _api: PerkAPI = null
var _state = null
var _offers: Array = []
var _selection_mode: String = "default"
var _preview_locked: bool = false
var _selected_index: int = -1
var _cards: Array = []
var _exit_busy: bool = false


func configure(api: PerkAPI, state) -> void:
	_api = api
	_state = state
	_style_chrome()


func present_offers(offers: Array, selection_mode: String = "default", preview_locked: bool = false) -> void:
	_offers = offers.duplicate(true)
	_selection_mode = selection_mode
	_preview_locked = preview_locked
	_selected_index = -1
	_rebuild_cards()
	_confirm_button.disabled = true
	_style_chrome()


## Switch offer row between horizontal (HBox) and vertical (VBox) without changing the scene file.
func set_cards_layout(layout: CardsLayout) -> void:
	if cards_layout == layout and _cards_row != null and _layout_matches_container(layout, _cards_row):
		return
	cards_layout = layout
	_ensure_cards_row()
	if not _offers.is_empty():
		_rebuild_cards()


func _ready() -> void:
	_subtitle = get_node_or_null("%Subtitle") as Label
	_sync_layout_from_scene()
	_ensure_cards_row()
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_style_chrome()
	# Optional host-specific slots — hide until the game wires them.
	for path in ["%RerollFree", "%RerollNc", "%RerollAd"]:
		var btn := get_node_or_null(path) as Button
		if btn:
			btn.visible = false


func _sync_layout_from_scene() -> void:
	var existing := get_node_or_null("%CardsRow") as Container
	if existing is VBoxContainer:
		cards_layout = CardsLayout.VERTICAL
	elif existing is HBoxContainer:
		cards_layout = CardsLayout.HORIZONTAL


func _style_chrome() -> void:
	if _title:
		_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_title.text = _tr("perk.ui.selection_title", title_text)
	if _subtitle:
		_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_subtitle.text = _tr("perk.ui.selection_subtitle", subtitle_text)
	if _confirm_button:
		_confirm_button.text = _tr("perk.ui.confirm", confirm_text)


func _ensure_cards_row() -> void:
	var existing := get_node_or_null("%CardsRow") as Container
	if existing != null and _layout_matches_container(cards_layout, existing):
		_cards_row = existing
		return

	var parent: Node = null
	var index: int = -1
	if existing != null:
		parent = existing.get_parent()
		index = existing.get_index()
		# Preserve children by reparenting after swap; clearer to clear and rebuild.
		for child in existing.get_children():
			child.queue_free()
		existing.name = "CardsRow_Old"
		existing.queue_free()
	else:
		parent = get_node_or_null("Center/Panel")
		if parent == null:
			parent = get_node_or_null("Safe/Panel")
		if parent == null:
			parent = self
		index = maxi(parent.get_child_count() - 1, 0)

	var row: Container
	if cards_layout == CardsLayout.VERTICAL:
		row = VBoxContainer.new()
	else:
		row = HBoxContainer.new()
	row.name = "CardsRow"
	row.unique_name_in_owner = true
	row.set("theme_override_constants/separation", 12)
	row.set("alignment", BoxContainer.ALIGNMENT_CENTER)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(row)
	if index >= 0:
		parent.move_child(row, mini(index, parent.get_child_count() - 1))
	_cards_row = row


func _layout_matches_container(layout: CardsLayout, container: Container) -> bool:
	if layout == CardsLayout.VERTICAL:
		return container is VBoxContainer
	return container is HBoxContainer


func _is_vertical_layout() -> bool:
	return _cards_row is VBoxContainer or cards_layout == CardsLayout.VERTICAL


func _rebuild_cards() -> void:
	_ensure_cards_row()
	for child in _cards_row.get_children():
		child.queue_free()
	_cards.clear()
	var vertical := _is_vertical_layout()
	var min_size := card_min_size_vertical if vertical else card_min_size_horizontal
	for index in _offers.size():
		var card: Node = CARD_SCENE.instantiate()
		_cards_row.add_child(card)
		if card is Control:
			var c := card as Control
			c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			c.size_flags_vertical = Control.SIZE_EXPAND_FILL
			c.custom_minimum_size = min_size
			# Hidden until entrance plays (avoids one-frame pop).
			c.modulate = Color(1, 1, 1, 0)
			c.scale = Vector2(0.12, 0.12)
		card.configure(_api)
		card.bind_offer(_offers[index])
		var captured_index: int = index
		card.card_clicked.connect(func() -> void:
			_select_index(captured_index)
		)
		_cards.append(card)
	_play_card_entrances.call_deferred()


func _play_card_entrances() -> void:
	# Wait a layout pass so pivot/size are valid while the run tree is paused.
	await get_tree().create_timer(0.0, true, true, true).timeout
	for index in _cards.size():
		var card: Node = _cards[index]
		if is_instance_valid(card) and card.has_method("play_entrance"):
			card.play_entrance(index)


func _play_card_exits() -> void:
	var last_tween: Tween = null
	for index in _cards.size():
		var card: Node = _cards[index]
		if is_instance_valid(card) and card.has_method("play_exit"):
			last_tween = card.play_exit(index)
	if last_tween:
		await last_tween.finished


func _select_index(index: int) -> void:
	if _exit_busy:
		return
	_selected_index = index
	for card_index in _cards.size():
		_cards[card_index].set_selected(card_index == index)
	_confirm_button.disabled = false


func _on_confirm_pressed() -> void:
	if _exit_busy:
		return
	if _selected_index < 0 or _selected_index >= _offers.size():
		return
	var offer: Dictionary = _offers[_selected_index]
	var kind: String = String(offer.get("kind", ""))
	if kind == "reroll":
		_handle_reroll()
		return
	if offer.has("id") and String(offer.get("id", "")).begins_with("gate_"):
		_handle_gate(String(offer.get("id", "")))
		return
	var perk_id: String = String(offer.get("perk_id", ""))
	if perk_id == "":
		return
	_exit_busy = true
	_confirm_button.disabled = true
	await _play_card_exits()
	selection_completed.emit(perk_id, offer)


func _handle_reroll() -> void:
	_exit_busy = true
	_confirm_button.disabled = true
	await _play_card_exits()
	_exit_busy = false
	_preview_locked = true
	var rerolled: Array = _api.roll_offers(_state, 3, true, _selection_mode)
	present_offers(rerolled, _selection_mode, true)


func _handle_gate(gate_id: String) -> void:
	_exit_busy = true
	_confirm_button.disabled = true
	await _play_card_exits()
	_exit_busy = false
	var gate_offers: Array = []
	for definition in _api.resolve_gate(gate_id, _state, _selection_mode):
		gate_offers.append({
			"kind": "perk",
			"perk_id": String(definition.id),
			"perk": definition,
			"preview_only": false,
		})
	present_offers(gate_offers, _selection_mode, _preview_locked)


func _tr(key: String, fallback: String) -> String:
	if _api != null and _api.host != null and _api.host.has_method("translate"):
		return String(_api.host.translate(key, fallback))
	return fallback
