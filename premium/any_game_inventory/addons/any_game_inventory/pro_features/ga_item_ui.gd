extends Button
class_name GaItemUI

@export var label_path: NodePath = ^"ColorRect/HBoxContainer/Label"
@export var icon_path: NodePath = ^"ColorRect/HBoxContainer/TextureRect"

func set_item(item: GaItemData, equipped: bool = false) -> void:
	var label: Label = get_node_or_null(label_path)
	var icon_rect: TextureRect = get_node_or_null(icon_path)
	if label:
		label.text = item.item_name + (" (equipped)" if equipped else "")
	if icon_rect:
		icon_rect.texture = item.item_icon
