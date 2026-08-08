class_name PerkRegistry
extends RefCounted

const ConfigScript := preload("res://godot_plugins/modular_perks/core/perk_config.gd")
const DefinitionScript := preload("res://godot_plugins/modular_perks/core/perk_definition.gd")

var _config
var _perks_by_id: Dictionary = {}
var _all_perks: Array = []


func _init(config = null) -> void:
	_config = config if config != null else ConfigScript.new()


func configure(config) -> void:
	_config = config


func clear() -> void:
	_perks_by_id.clear()
	_all_perks.clear()


func register_definition(definition) -> void:
	if definition == null or String(definition.id).strip_edges() == "":
		return
	var normalized_id := String(definition.id).strip_edges()
	if _perks_by_id.has(normalized_id):
		var previous = _perks_by_id[normalized_id]
		var index := _all_perks.find(previous)
		if index >= 0:
			_all_perks[index] = definition
	else:
		_all_perks.append(definition)
	_perks_by_id[normalized_id] = definition
	_sort_all()


func register_definitions(definitions: Array) -> void:
	for item in definitions:
		register_definition(item)


func register_pack_from_dir(content_dir: String) -> int:
	var dir := DirAccess.open(content_dir)
	if dir == null:
		return 0
	var loaded := 0
	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var path := content_dir.path_join(file_name)
		var definition = load(path)
		if definition == null or String(definition.id) == "":
			continue
		register_definition(definition)
		loaded += 1
	return loaded


func get_all() -> Array:
	return _all_perks.duplicate()


func get_perk(perk_id: String):
	return _perks_by_id.get(String(perk_id), null)


func get_unlocked(unlock_score: int) -> Array:
	var result: Array = []
	for perk in _all_perks:
		if unlock_score >= int(perk.unlock_score_required):
			result.append(perk)
	return result


func is_unlocked(perk_id: String, unlock_score: int) -> bool:
	var perk = get_perk(perk_id)
	if perk == null:
		return false
	return unlock_score >= int(perk.unlock_score_required)


func count_available_in_category(
	category: String,
	unlock_score: int,
	active_ids: Array
) -> int:
	var count := 0
	for perk in get_unlocked(unlock_score):
		if String(perk.category) != category:
			continue
		if active_ids.has(String(perk.id)) and not bool(perk.repeatable):
			continue
		count += 1
	return count


func get_eligible_gates(unlock_score: int, active_ids: Array) -> Array:
	var eligible: Array = []
	for gate in _config.get_category_gates():
		var category := String(gate.get("category", ""))
		if count_available_in_category(category, unlock_score, active_ids) >= int(_config.gate_min_available):
			eligible.append(gate.duplicate(true))
	return eligible


func get_gate_category(gate_id: String) -> String:
	return _config.get_gate_category(gate_id)


func _sort_all() -> void:
	_all_perks.sort_custom(func(a, b) -> bool:
		if int(a.unlock_score_required) != int(b.unlock_score_required):
			return int(a.unlock_score_required) < int(b.unlock_score_required)
		return String(a.id) < String(b.id)
	)
