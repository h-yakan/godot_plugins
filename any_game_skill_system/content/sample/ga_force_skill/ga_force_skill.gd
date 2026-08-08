extends GaSkill
class_name GaForceSkill

## Sample skill: applies an impulse to RigidBody2D bodies in an Area2D.

@export var strength: float = 200.0
@export var impact_distance: float = 1.0
@export var impulse_direction: Vector2 = Vector2.UP

@onready var _area: Area2D = $Area2D
@onready var _effect: ColorRect = $Area2D/Effect


func _do_activate(context: GaSkillContext) -> bool:
	if _area == null:
		return false
	if context.caster:
		global_position = context.caster.global_position
	_area.monitoring = true
	await get_tree().process_frame
	if _effect:
		_effect.visible = true
	await get_tree().create_timer(0.1).timeout
	if _effect:
		_effect.visible = false
	_area.monitoring = false
	return true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.apply_central_impulse(impulse_direction.normalized() * strength)
