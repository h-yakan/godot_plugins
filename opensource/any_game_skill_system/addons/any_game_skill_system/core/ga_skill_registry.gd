extends RefCounted
class_name GaSkillRegistry

const DefinitionScript := preload("res://addons/any_game_skill_system/core/ga_skill_definition.gd")

var _definitions_by_id: Dictionary = {}


func clear() -> void:
	_definitions_by_id.clear()


func register_definition(definition: GaSkillDefinition) -> void:
	if definition == null:
		return
	var normalized_id := definition.get_id().strip_edges()
	if normalized_id.is_empty():
		push_warning("GaSkillRegistry: skipped definition with empty id.")
		return
	_definitions_by_id[normalized_id] = definition


func register_definitions(definitions: Array) -> void:
	for item in definitions:
		if item is GaSkillDefinition:
			register_definition(item)


func register_directory(content_dir: String) -> int:
	return _register_directory_recursive(content_dir.rstrip("/"))


func _register_directory_recursive(path: String) -> int:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("GaSkillRegistry: cannot open directory '%s'." % path)
		return 0

	var loaded := 0
	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var definition: GaSkillDefinition = load(path.path_join(file_name))
		if definition:
			register_definition(definition)
			loaded += 1

	for subdir in dir.get_directories():
		loaded += _register_directory_recursive(path.path_join(subdir))

	return loaded


func has_definition(skill_id: String) -> bool:
	return _definitions_by_id.has(skill_id.strip_edges())


func get_definition(skill_id: String) -> GaSkillDefinition:
	return _definitions_by_id.get(skill_id.strip_edges())


func get_all_definitions() -> Array[GaSkillDefinition]:
	var result: Array[GaSkillDefinition] = []
	for definition in _definitions_by_id.values():
		result.append(definition)
	return result


func get_definitions_by_category(category: StringName) -> Array[GaSkillDefinition]:
	var result: Array[GaSkillDefinition] = []
	for definition in _definitions_by_id.values():
		if definition.slot_category == category:
			result.append(definition)
	return result
