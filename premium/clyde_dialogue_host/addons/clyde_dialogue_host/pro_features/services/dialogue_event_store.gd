class_name DialogueEventStore
extends RefCounted

## Persistent key-value store for dialogue flags and scripted events.

signal changed(key: String, value: Variant, previous: Variant)

var save_path: String = "user://clyde_dialogue_events.json"
var auto_save: bool = true

var _events: Dictionary = {}
var _dirty: bool = false


func is_dirty() -> bool:
	return _dirty


func load() -> void:
	_events = {}
	_dirty = false
	var parsed: Variant = DialogueUtils.read_json_file(save_path)
	if typeof(parsed) == TYPE_DICTIONARY:
		_events = parsed.duplicate(true)


func save() -> void:
	if not DialogueUtils.write_json_file(save_path, _events):
		return
	_dirty = false


func has(key: String) -> bool:
	return _events.has(key)


func get_value(key: String, default: Variant = null) -> Variant:
	return _events.get(key, default)


func set_value(key: String, value: Variant, persist: bool = true) -> void:
	var previous: Variant = _events.get(key, null)
	if previous == value and _events.has(key):
		return

	_events[key] = value
	_dirty = true
	changed.emit(key, value, previous)

	if persist and auto_save:
		save()


func record(key: String) -> void:
	set_value(key, true)


func clear(key: String) -> void:
	if not _events.has(key):
		return
	var previous: Variant = _events[key]
	_events.erase(key)
	_dirty = true
	changed.emit(key, null, previous)
	if auto_save:
		save()


func get_all() -> Dictionary:
	return _events


func load_all(data: Dictionary) -> void:
	_events = data.duplicate(true)
	_dirty = true
	if auto_save:
		save()


func clear_all() -> void:
	_events.clear()
	_dirty = true
	if auto_save:
		save()
