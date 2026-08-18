class_name DialogueStatStore
extends RefCounted

## Persistent character stat values used by dice rolls and dialogue conditions.

signal changed(stat_name: String, value: int, previous: int)

var save_path: String = "user://clyde_dialogue_stats.json"
var default_stats_path: String = ""
var auto_save: bool = true

var _stats: Dictionary = {}
var _dirty: bool = false


func is_dirty() -> bool:
	return _dirty


func has_stat(stat_name: String) -> bool:
	return _stats.has(stat_name)


func load() -> void:
	_stats = {}
	_dirty = false

	var parsed: Variant = DialogueUtils.read_json_file(save_path)
	if typeof(parsed) == TYPE_DICTIONARY:
		_stats = parsed.duplicate(true)
		return

	if default_stats_path != "":
		var default_data: Variant = DialogueUtils.read_json_file(default_stats_path)
		if typeof(default_data) == TYPE_DICTIONARY:
			_stats = default_data.duplicate(true)
			_dirty = true
			if auto_save:
				save()


func save() -> void:
	if not DialogueUtils.write_json_file(save_path, _stats):
		return
	_dirty = false


func get_stat(stat_name: String, default: int = 0) -> int:
	return int(_stats.get(stat_name, default))


func set_stat(stat_name: String, value: int, persist: bool = true) -> void:
	var previous := get_stat(stat_name)
	if previous == value and _stats.has(stat_name):
		return

	_stats[stat_name] = value
	_dirty = true
	changed.emit(stat_name, value, previous)
	if persist and auto_save:
		save()


func get_all() -> Dictionary:
	return _stats


func load_all(data: Dictionary) -> void:
	_stats = data.duplicate(true)
	_dirty = true
	if auto_save:
		save()


func clear_all() -> void:
	_stats.clear()
	_dirty = true
	if auto_save:
		save()
