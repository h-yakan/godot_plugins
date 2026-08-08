class_name PerkRunState
extends RefCounted

var active_ids: Array[String] = []
var picked_ids: Array[String] = []
var instances: Array[Dictionary] = []
var flags: Dictionary = {}


func duplicate_state():
	var copy_script: GDScript = load("res://godot_plugins/modular_perks/core/perk_run_state.gd")
	var copy = copy_script.new()
	copy.active_ids = active_ids.duplicate()
	copy.picked_ids = picked_ids.duplicate()
	copy.instances = instances.duplicate(true)
	copy.flags = flags.duplicate(true)
	return copy


func to_dict() -> Dictionary:
	return {
		"active_ids": active_ids.duplicate(),
		"picked_ids": picked_ids.duplicate(),
		"instances": instances.duplicate(true),
		"flags": flags.duplicate(true),
	}


static func from_dict(data: Dictionary):
	var state_script: GDScript = load("res://godot_plugins/modular_perks/core/perk_run_state.gd")
	var state = state_script.new()
	for raw_id in data.get("active_ids", []):
		state.active_ids.append(String(raw_id))
	for raw_id in data.get("picked_ids", []):
		state.picked_ids.append(String(raw_id))
	for raw_instance in data.get("instances", []):
		if raw_instance is Dictionary:
			state.instances.append(raw_instance.duplicate(true))
	state.flags = (data.get("flags", {}) as Dictionary).duplicate(true)
	return state


func has_active(perk_id: String) -> bool:
	return active_ids.has(String(perk_id))


func record_instance(record: Dictionary) -> void:
	instances.append(record.duplicate(true))


func get_instances_for(perk_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for instance in instances:
		if String(instance.get("perk_id", "")) == String(perk_id):
			result.append(instance.duplicate(true))
	return result


func set_flag(key: String, value: Variant) -> void:
	flags[String(key)] = value


func get_flag(key: String, default_value: Variant = null) -> Variant:
	if flags.has(key):
		return flags[key]
	return default_value
