class_name PerkEffectBus
extends RefCounted

var _handlers: Array = []


func register_handler(handler) -> void:
	if handler == null:
		return
	if not _handlers.has(handler):
		_handlers.append(handler)


func register_handlers(handlers: Array) -> void:
	for handler in handlers:
		register_handler(handler)


func clear_handlers() -> void:
	_handlers.clear()


func get_handlers_for(definition, context: Dictionary = {}) -> Array:
	var matched: Array = []
	for handler in _handlers:
		if handler.supports(definition, context):
			matched.append(handler)
	return matched


func query_active(
	active_ids: Array,
	registry,
	state,
	host,
	kind: String,
	context: Dictionary = {}
) -> Array:
	var results: Array = []
	for perk_id in active_ids:
		var definition = registry.get_perk(String(perk_id))
		if definition == null:
			continue
		for handler in get_handlers_for(definition, context):
			if String(handler.get_kind()) != kind:
				continue
			var value = handler.query(definition, state, host, context)
			if value != null:
				results.append({
					"perk_id": String(definition.id),
					"kind": kind,
					"value": value,
				})
	return results


func apply_for_definition(
	definition,
	state,
	host,
	context: Dictionary = {}
) -> void:
	if definition == null:
		return
	for handler in get_handlers_for(definition, context):
		handler.apply(definition, state, host, context)


func apply_for_active(
	active_ids: Array,
	registry,
	state,
	host,
	kind: String,
	context: Dictionary = {}
) -> void:
	for perk_id in active_ids:
		var definition = registry.get_perk(String(perk_id))
		if definition == null or String(definition.get_effect_kind()) != kind:
			continue
		apply_for_definition(definition, state, host, context)
