class_name DialoguePersistence
extends RefCounted

## Coordinates event, stat, and modifier stores with batched disk writes.

signal saved()
signal loaded()
signal event_changed(key: String, value: Variant, previous: Variant)
signal stat_changed(stat_name: String, value: int, previous: int)
signal modifier_changed(id: String, data: Dictionary)

var events := DialogueEventStore.new()
var stats := DialogueStatStore.new()
var modifiers := DialogueModifierStore.new()

var auto_save: bool = true


func configure(config: Dictionary) -> void:
	events.save_path = str(config.get("events_path", events.save_path))
	stats.save_path = str(config.get("stats_path", stats.save_path))
	stats.default_stats_path = str(config.get("default_stats_path", stats.default_stats_path))
	modifiers.save_path = str(config.get("modifiers_path", modifiers.save_path))
	modifiers.default_modifiers_path = str(
		config.get("default_modifiers_path", modifiers.default_modifiers_path)
	)
	auto_save = bool(config.get("auto_save", auto_save))

	events.changed.connect(func(key, value, previous): event_changed.emit(key, value, previous))
	stats.changed.connect(func(name, value, previous): stat_changed.emit(name, value, previous))
	modifiers.changed.connect(func(id, data): modifier_changed.emit(id, data))


func set_auto_save(enabled: bool) -> void:
	auto_save = enabled
	events.auto_save = enabled
	stats.auto_save = enabled
	modifiers.auto_save = enabled


func load_all() -> void:
	events.load()
	stats.load()
	modifiers.load()
	loaded.emit()


func save_all() -> void:
	events.save()
	stats.save()
	modifiers.save()
	saved.emit()


func is_dirty() -> bool:
	return events.is_dirty() or stats.is_dirty() or modifiers.is_dirty()


func sync_to_clyde(clyde: ClydeDialogue) -> void:
	if not clyde:
		return

	for key in events.get_all():
		clyde.set_variable(str(key), events.get_value(key))

	for stat_name in stats.get_all():
		var value := stats.get_stat(stat_name)
		clyde.set_variable(stat_name, value)
		clyde.set_variable("%s_stat" % stat_name, value)


func fetch_variable(variable_name: String) -> Variant:
	if events.has(variable_name):
		return events.get_value(variable_name)
	if stats.has_stat(variable_name):
		return stats.get_stat(variable_name)
	return null


func update_variable(variable_name: String, value: Variant) -> void:
	if stats.has_stat(variable_name):
		stats.set_stat(variable_name, int(value), false)
	else:
		events.set_value(variable_name, value, false)
