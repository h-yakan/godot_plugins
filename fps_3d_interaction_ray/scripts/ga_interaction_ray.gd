extends RayCast3D
class_name GaInteractionRay

signal target_changed(target: Object)
signal interacted(target: Object)
signal placed(target: Object)
signal grabbed(target: Object)

@export var interact_action: StringName = &"interact"
@export var secondary_interact_action: StringName = &"secondary_interact"
@export var enabled_when: bool = true

var current_target: Object = null

func _physics_process(_delta: float) -> void:
	if not enabled_when:
		return
	var target: Object = get_collider() if is_colliding() else null
	if target != current_target:
		current_target = target
		target_changed.emit(target)
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("interact") and Input.is_action_just_pressed(interact_action):
		target.interact()
		interacted.emit(target)
	if target.has_method("place_item") and Input.is_action_just_pressed(secondary_interact_action):
		target.place_item()
		placed.emit(target)
	if target.has_method("grab") and Input.is_action_just_pressed(interact_action):
		if not target.get("is_holding"):
			target.grab()
			grabbed.emit(target)

func get_interaction_hints() -> Dictionary:
	if current_target == null:
		return {"interact": false, "place": false, "grab": false}
	return {
		"interact": current_target.has_method("interact") or current_target.has_method("grab"),
		"place": current_target.has_method("place_item"),
		"grab": current_target.has_method("grab")
	}
