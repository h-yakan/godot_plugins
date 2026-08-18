class_name ClydeTriggerRouter
extends RefCounted

## Routes Clyde {trigger ...} events to registered callables.
## Built-in handlers run first; unknown triggers return false so the host can emit a signal.

var _handlers: Dictionary = {}


func register_trigger(event_name: String, handler: Callable) -> void:
	_handlers[event_name] = handler


func unregister_trigger(event_name: String) -> void:
	_handlers.erase(event_name)


func has_trigger(event_name: String) -> bool:
	return _handlers.has(event_name)


func dispatch(event_name: String, args: Array) -> bool:
	if not _handlers.has(event_name):
		return false
	var handler: Callable = _handlers[event_name]
	if handler.is_valid():
		handler.call(args)
	return true


func clear() -> void:
	_handlers.clear()
