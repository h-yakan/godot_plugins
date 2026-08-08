extends PanelContainer
class_name GaCustomTooltip

@export var label_path: NodePath = ^"MarginContainer/TooltipLabel"
@onready var label: Label = get_node_or_null(label_path)

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position() + Vector2(15, 15)

func display(text: String) -> void:
	if label:
		label.text = text
	show()

func stop() -> void:
	hide()
