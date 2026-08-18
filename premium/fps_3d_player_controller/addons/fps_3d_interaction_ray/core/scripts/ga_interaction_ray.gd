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
	if not enabled_when or _look_frozen():
		_clear_target()
		return
	var target: Object = get_collider() if is_colliding() else null
	if target != current_target:
		current_target = target
		target_changed.emit(target)

func _unhandled_input(event: InputEvent) -> void:
	if not enabled_when or _look_frozen():
		return
	if current_target == null or not is_instance_valid(current_target):
		return
	if event.is_action_pressed(interact_action):
		if current_target.has_method("interact"):
			current_target.interact()
			interacted.emit(current_target)
			get_viewport().set_input_as_handled()
		if current_target.has_method("grab") and not current_target.get("is_holding"):
			current_target.grab()
			grabbed.emit(current_target)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(secondary_interact_action) and current_target.has_method("place_item"):
		current_target.place_item()
		placed.emit(current_target)
		get_viewport().set_input_as_handled()

func _look_frozen() -> bool:
	var node: Node = self
	while node:
		if node.get("mouse_captured") == false:
			return true
		node = node.get_parent()
	return false

func _clear_target() -> void:
	if current_target == null:
		return
	current_target = null
	target_changed.emit(null)

func get_interaction_hints() -> Dictionary:
	if current_target == null:
		return {"interact": false, "place": false, "grab": false}
	return {
		"interact": current_target.has_method("interact") or current_target.has_method("grab"),
		"place": current_target.has_method("place_item"),
		"grab": current_target.has_method("grab")
	}
