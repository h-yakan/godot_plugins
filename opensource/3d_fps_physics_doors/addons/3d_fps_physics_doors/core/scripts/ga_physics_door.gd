extends Node3D
class_name GaPhysicsDoor

@export var save_door_id: String = ""
@export var is_locked: bool = false
var is_open: bool = false:
	set(value):
		is_open = value
		_update_save_door_state()

@onready var pivot: Node3D = $pivot

func _ready() -> void:
	if save_door_id != "":
		add_to_group("doors")
		var saves := _save_manager()
		if saves and saves.has_method("get_door_state"):
			apply_saved_state(saves.get_door_state(save_door_id))

func apply_saved_state(state: Dictionary) -> void:
	if state.is_empty() or not pivot:
		return
	is_open = state.get("is_open", false)
	is_locked = state.get("is_locked", is_locked)
	if is_open and pivot.has_method("set_open_amount"):
		pivot.set_open_amount(pivot.max_angle)

func _update_save_door_state() -> void:
	if save_door_id == "":
		return
	var saves := _save_manager()
	if saves and saves.has_method("set_door_state"):
		saves.set_door_state(save_door_id, {"is_open": is_open, "is_locked": is_locked})

func _save_manager() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().root.get_node_or_null("GaSaveManager")
