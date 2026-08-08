extends PanelContainer
class_name GaSkillTooltip

const OFFSET := Vector2.ONE * 60.0

var _opacity_tween: Tween = null


func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + OFFSET


func toggle(on: bool) -> void:
	if on:
		show()
		modulate.a = 0.0
		_tween_opacity(1.0)
	else:
		modulate.a = 1.0
		await _tween_opacity(0.0).finished
		hide()


func _tween_opacity(to: float) -> Tween:
	if _opacity_tween:
		_opacity_tween.kill()
	_opacity_tween = get_tree().create_tween()
	_opacity_tween.tween_property(self, "modulate:a", to, 0.4)
	return _opacity_tween
