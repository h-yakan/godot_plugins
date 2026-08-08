extends PanelContainer

signal card_clicked

@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel
@onready var _description: RichTextLabel = %Description
@onready var _category_bar: ColorRect = %CategoryBar
@onready var _preview_banner: Label = %PreviewBanner

var _api = null
var _offer: Dictionary = {}
var _selected := false


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	gui_input.connect(_on_gui_input)


func configure(api) -> void:
	_api = api


func bind_offer(offer: Dictionary) -> void:
	_offer = offer.duplicate(true)
	_selected = false
	var kind := String(offer.get("kind", ""))
	match kind:
		"perk":
			_bind_perk_offer(offer)
		"reroll":
			_bind_reroll()
		_:
			if offer.has("id") and String(offer.get("id", "")).begins_with("gate_"):
				_bind_gate(offer)


func set_selected(selected: bool) -> void:
	_selected = selected
	modulate = Color(1.15, 1.15, 1.15, 1.0) if selected else Color.WHITE


func _bind_perk_offer(offer: Dictionary) -> void:
	var definition = offer.get("perk")
	if definition == null or _api == null:
		return
	_name_label.text = _api.get_localized_name(definition)
	_description.text = _api.get_localized_description(definition)
	_icon.texture = definition.icon
	_category_bar.color = _api.get_category_color(String(definition.category))
	_apply_rarity_border(String(definition.rarity))
	var preview_only := bool(offer.get("preview_only", false))
	_preview_banner.visible = preview_only or bool(definition.is_locked(_api.get_unlock_score()))
	if _preview_banner.visible:
		_preview_banner.text = "Preview" if preview_only else "Locked (%d)" % int(definition.unlock_score_required)


func _bind_gate(gate: Dictionary) -> void:
	var category := String(gate.get("category", "utility"))
	_name_label.text = "Category Gate: %s" % category.capitalize()
	_description.text = "Choose one perk from this category."
	_icon.texture = null
	_category_bar.color = _api.get_category_color(category) if _api != null else Color.GRAY
	_apply_rarity_border("")
	_preview_banner.visible = false


func _bind_reroll() -> void:
	_name_label.text = "Reroll"
	_description.text = "Reveal the full perk pool for this selection."
	_icon.texture = null
	_category_bar.color = Color(0.55, 0.55, 0.55)
	_apply_rarity_border("")
	_preview_banner.visible = false


func _apply_rarity_border(rarity: String) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.18, 1.0)
	style.set_border_width_all(2)
	style.border_color = _api.get_rarity_color(rarity) if _api != null else Color.GRAY
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit()
