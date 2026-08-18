extends SubViewport

@export var title_path: NodePath = ^"Root/Title"
@export var body_path: NodePath = ^"Root/Body"

var _noise: float = 0.0

func _process(delta: float) -> void:
	_noise += delta * 8.0
	var flicker := 0.04 + absf(sin(_noise)) * 0.08
	var root := get_node_or_null("Root") as ColorRect
	if root:
		root.color = Color(0.04, 0.05, 0.03, 1.0).lerp(Color(0.09, 0.1, 0.05, 1.0), flicker)

func set_broadcast(title: String, body: String) -> void:
	var title_lbl := get_node_or_null(title_path) as Label
	var body_lbl := get_node_or_null(body_path) as Label
	if title_lbl:
		title_lbl.text = title
	if body_lbl:
		body_lbl.text = body
