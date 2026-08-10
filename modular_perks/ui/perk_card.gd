extends PanelContainer

signal card_clicked

const ENTRANCE_STAGGER_SEC := 0.16
const ENTRANCE_GROW_SEC := 0.55
const ENTRANCE_FLIP_SEC := 0.38
const ENTRANCE_START_SCALE := 0.12
const ENTRANCE_FLIP_EDGE := 0.04

const _PANEL_BG := Color(0.12, 0.14, 0.18, 0.95)
const _PANEL_RADIUS := 6
const _TEXT_PRIMARY := Color(0.92, 0.94, 0.97)
const _TEXT_DIM := Color(0.55, 0.62, 0.70)
const _TEXT_ACCENT := Color(0.95, 0.82, 0.25)
const _FONT_TITLE := 22
const _FONT_BODY := 16
const _FONT_CAPTION := 14

@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel
@onready var _description: RichTextLabel = %Description
@onready var _category_bar: ColorRect = %CategoryBar
@onready var _preview_banner: Label = %PreviewBanner

var _api: PerkAPI = null
var _offer: Dictionary = {}
var _selected: bool = false
var _entrance_tween: Tween
var _select_tween: Tween
var _entrance_ready: bool = false
var _showing_back: bool = false


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	gui_input.connect(_on_gui_input)
	_apply_typography()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_center_pivot()


func configure(api: PerkAPI) -> void:
	_api = api
	_apply_typography()


func bind_offer(offer: Dictionary) -> void:
	_offer = offer.duplicate(true)
	_selected = false
	var kind: String = String(offer.get("kind", ""))
	match kind:
		"perk":
			_bind_perk_offer(offer)
		"reroll":
			_bind_reroll()
		_:
			if offer.has("id") and String(offer.get("id", "")).begins_with("gate_"):
				_bind_gate(offer)
	_apply_typography()


## Grow in place (blank back), then flip to reveal the front face.
func play_entrance(stagger_index: int = 0) -> void:
	_entrance_ready = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _entrance_tween:
		_entrance_tween.kill()
	_set_showing_back(true)
	modulate = Color(1, 1, 1, 0)
	scale = Vector2(ENTRANCE_START_SCALE, ENTRANCE_START_SCALE)
	rotation = 0.0
	_center_pivot()
	var delay := float(stagger_index) * ENTRANCE_STAGGER_SEC
	_entrance_tween = create_tween()
	_entrance_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_entrance_tween.set_ignore_time_scale(true)

	# 1) Grow in place to full size (still blank back).
	_entrance_tween.set_parallel(true)
	_entrance_tween.tween_property(self, "modulate:a", 1.0, ENTRANCE_GROW_SEC * 0.5)\
		.set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_entrance_tween.tween_property(self, "scale", Vector2.ONE, ENTRANCE_GROW_SEC)\
		.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 2) Flip to edge (back), swap to front content, then open.
	var half_flip := ENTRANCE_FLIP_SEC * 0.5
	_entrance_tween.chain().tween_property(self, "scale:x", ENTRANCE_FLIP_EDGE, half_flip)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_entrance_tween.parallel().tween_property(self, "scale:y", 1.08, half_flip)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_entrance_tween.chain().tween_callback(_reveal_front_face)
	_entrance_tween.tween_property(self, "scale:x", 1.0, half_flip)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entrance_tween.parallel().tween_property(self, "scale:y", 1.0, half_flip)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_entrance_tween.chain().tween_callback(_finish_entrance)


## Reverse of entrance: flip front → blank back, then shrink away.
## Returns the tween so callers can `await tween.finished`.
func play_exit(stagger_index: int = 0) -> Tween:
	_entrance_ready = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _entrance_tween:
		_entrance_tween.kill()
	if _select_tween:
		_select_tween.kill()
	_set_showing_back(false)
	rotation = 0.0
	scale = Vector2.ONE
	_center_pivot()
	var delay := float(stagger_index) * ENTRANCE_STAGGER_SEC
	var half_flip := ENTRANCE_FLIP_SEC * 0.5
	_entrance_tween = create_tween()
	_entrance_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_entrance_tween.set_ignore_time_scale(true)
	if delay > 0.0:
		_entrance_tween.tween_interval(delay)

	# 1) Flip front to edge, swap to blank back, open as back.
	_entrance_tween.set_parallel(true)
	_entrance_tween.tween_property(self, "scale:x", ENTRANCE_FLIP_EDGE, half_flip)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_entrance_tween.tween_property(self, "scale:y", 1.08, half_flip)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_entrance_tween.chain().tween_callback(_hide_front_face)
	_entrance_tween.tween_property(self, "scale:x", 1.0, half_flip)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entrance_tween.parallel().tween_property(self, "scale:y", 1.0, half_flip)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2) Shrink in place and fade out.
	_entrance_tween.chain().set_parallel(true)
	_entrance_tween.tween_property(self, "scale", Vector2(ENTRANCE_START_SCALE, ENTRANCE_START_SCALE), ENTRANCE_GROW_SEC)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_entrance_tween.tween_property(self, "modulate:a", 0.0, ENTRANCE_GROW_SEC * 0.5)\
		.set_delay(ENTRANCE_GROW_SEC * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return _entrance_tween


func set_selected(selected: bool) -> void:
	_selected = selected
	var target := Color(1.15, 1.15, 1.15, 1.0) if selected else Color.WHITE
	if not _entrance_ready:
		modulate = target
		return
	if _select_tween:
		_select_tween.kill()
	_center_pivot()
	modulate = target
	if selected:
		_select_tween = create_tween()
		_select_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_select_tween.set_ignore_time_scale(true)
		_select_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_select_tween.tween_property(self, "scale", Vector2.ONE, 0.18)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		scale = Vector2.ONE


func _apply_typography() -> void:
	if _name_label:
		_name_label.add_theme_font_size_override("font_size", _FONT_TITLE)
		_name_label.add_theme_color_override("font_color", _TEXT_PRIMARY)
		_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _description:
		_description.add_theme_font_size_override("normal_font_size", _FONT_BODY)
		_description.add_theme_color_override("default_color", _TEXT_DIM)
		_description.fit_content = true
		_description.scroll_active = false
	if _preview_banner:
		_preview_banner.add_theme_font_size_override("font_size", _FONT_CAPTION)
		_preview_banner.add_theme_color_override("font_color", _TEXT_ACCENT)


func _bind_perk_offer(offer: Dictionary) -> void:
	var definition = offer.get("perk")
	if definition == null or _api == null:
		return
	_name_label.text = _api.get_localized_name(definition)
	_description.text = _api.get_localized_description(definition)
	_icon.texture = definition.icon
	_category_bar.color = _api.get_category_color(String(definition.category))
	_apply_rarity_border(String(definition.rarity))
	var preview_only: bool = bool(offer.get("preview_only", false))
	_preview_banner.visible = preview_only or bool(definition.is_locked(_api.get_unlock_score()))
	if _preview_banner.visible:
		_preview_banner.text = (
			_tr("perk.ui.preview", "Preview")
			if preview_only
			else _tr("perk.ui.locked", "Locked (%d)") % int(definition.unlock_score_required)
		)


func _bind_gate(gate: Dictionary) -> void:
	var category: String = String(gate.get("category", "utility"))
	_name_label.text = _tr("perk.ui.gate_title", "Category Gate: %s") % category.capitalize()
	_description.text = _tr("perk.ui.gate_body", "Choose one perk from this category.")
	_icon.texture = null
	_category_bar.color = _api.get_category_color(category) if _api != null else Color.GRAY
	_apply_rarity_border("")
	_preview_banner.visible = false


func _bind_reroll() -> void:
	_name_label.text = _tr("perk.ui.reroll_title", "Reroll")
	_description.text = _tr("perk.ui.reroll_body", "Reveal the full perk pool for this selection.")
	_icon.texture = null
	_category_bar.color = Color(0.55, 0.55, 0.55)
	_apply_rarity_border("")
	_preview_banner.visible = false


func _apply_rarity_border(rarity: String) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = _PANEL_BG
	style.set_border_width_all(2)
	style.border_color = _api.get_rarity_color(rarity) if _api != null else Color.GRAY
	style.set_corner_radius_all(_PANEL_RADIUS)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	add_theme_stylebox_override("panel", style)


func _center_pivot() -> void:
	pivot_offset = size * 0.5


func _set_showing_back(showing_back: bool) -> void:
	_showing_back = showing_back
	# Keep face in the tree so layout size stays stable; only hide visually.
	var face := get_node_or_null("Margin") as CanvasItem
	if face:
		face.modulate = Color(1, 1, 1, 0) if showing_back else Color.WHITE


func _reveal_front_face() -> void:
	_set_showing_back(false)


func _hide_front_face() -> void:
	_set_showing_back(true)


func _finish_entrance() -> void:
	_entrance_ready = true
	_set_showing_back(false)
	scale = Vector2.ONE
	rotation = 0.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	if _selected:
		modulate = Color(1.15, 1.15, 1.15, 1.0)
	else:
		modulate = Color.WHITE


func _tr(key: String, fallback: String) -> String:
	if _api != null and _api.host != null and _api.host.has_method("translate"):
		return String(_api.host.translate(key, fallback))
	return fallback


func _on_gui_input(event: InputEvent) -> void:
	if not _entrance_ready:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit()
