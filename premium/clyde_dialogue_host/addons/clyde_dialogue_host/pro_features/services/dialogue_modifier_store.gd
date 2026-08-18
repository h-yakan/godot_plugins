class_name DialogueModifierStore
extends RefCounted

## Persistent modifier list for dice roll bonuses. Indexed by id for O(1) lookup.

signal changed(id: String, data: Dictionary)

var save_path: String = "user://clyde_dialogue_modifiers.json"
var default_modifiers_path: String = ""
var auto_save: bool = true

var items: Array[Dictionary] = []

var _by_id: Dictionary = {}
var _dirty: bool = false


func is_dirty() -> bool:
	return _dirty


func load() -> void:
	items.clear()
	_by_id.clear()
	_dirty = false

	if not FileAccess.file_exists(save_path) and default_modifiers_path != "":
		_copy_default_file()

	var parsed: Variant = DialogueUtils.read_json_file(save_path)
	if typeof(parsed) != TYPE_ARRAY:
		return

	for raw in parsed:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		if not bool(raw.get("active", true)):
			continue
		_register_item(_normalize_item(raw))


func save() -> void:
	var raw_items: Array = []
	for item in items:
		raw_items.append(item.duplicate(true))

	if not DialogueUtils.write_json_file(save_path, raw_items):
		return
	_dirty = false


func add_or_update(
	id: String,
	tags: Array,
	value: int,
	description: String = "",
	active: bool = true
) -> void:
	var item := {
		"id": id,
		"tags": tags.map(func(tag): return str(tag)),
		"value": value,
		"description": description,
		"active": active,
	}

	if _by_id.has(id):
		var index: int = _by_id[id]
		items[index] = item
	else:
		_register_item(item)

	_dirty = true
	changed.emit(id, item.duplicate(true))
	if auto_save:
		save()


func get_by_id(id: String) -> Dictionary:
	if not _by_id.has(id):
		return {}
	var index: int = _by_id[id]
	return items[index].duplicate(true)


func sum_for(roll_id: String, tag: String) -> int:
	if not _by_id.has(roll_id):
		return 0

	var item: Dictionary = items[_by_id[roll_id]]
	var tags: Array = item.get("tags", [])
	if tag in tags:
		return int(item.get("value", 0))
	return 0


func _register_item(item: Dictionary) -> void:
	var id := str(item.get("id", ""))
	if id == "":
		return
	if _by_id.has(id):
		items[_by_id[id]] = item
	else:
		_by_id[id] = items.size()
		items.append(item)


func _copy_default_file() -> void:
	if default_modifiers_path == "":
		return
	var src := FileAccess.open(default_modifiers_path, FileAccess.READ)
	if not src:
		return
	var dst := FileAccess.open(save_path, FileAccess.WRITE)
	if not dst:
		src.close()
		return
	dst.store_string(src.get_as_text())
	dst.close()
	src.close()


func _normalize_item(raw: Dictionary) -> Dictionary:
	var tags_any: Variant = raw.get("tags", [])
	var tags: Array[String] = []
	if typeof(tags_any) == TYPE_ARRAY:
		for tag in tags_any:
			tags.append(str(tag))

	return {
		"id": str(raw.get("id", "")),
		"tags": tags,
		"value": int(raw.get("value", 0)),
		"description": str(raw.get("description", "")),
		"active": bool(raw.get("active", true)),
	}
