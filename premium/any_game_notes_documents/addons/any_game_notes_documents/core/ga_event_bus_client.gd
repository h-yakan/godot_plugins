extends RefCounted

## Optional Event Bus lookup. Plugins ship a copy of this script so they
## compile without the Event Bus addon installed.

const AUTOLOAD_NAME := "GaEventBus"

static func get_bus(from: Node) -> Node:
	if from == null or not from.is_inside_tree():
		return null
	return from.get_tree().root.get_node_or_null(AUTOLOAD_NAME)

static func extend(from: Node, signal_name: StringName, enabled: bool = true) -> void:
	if not enabled:
		return
	var bus := get_bus(from)
	if bus == null:
		return
	if bus.has_method("register_signal"):
		bus.call("register_signal", signal_name)

static func emit(from: Node, signal_name: StringName, args: Array = [], enabled: bool = true) -> void:
	if not enabled:
		return
	var bus := get_bus(from)
	if bus == null:
		return
	if bus.has_method("emit_named"):
		bus.call("emit_named", signal_name, args)
		return
	if bus.has_signal(signal_name):
		var packed: Array = [signal_name]
		packed.append_array(args)
		bus.callv("emit_signal", packed)

static func listen(from: Node, signal_name: StringName, callable: Callable, enabled: bool = true) -> void:
	if not enabled:
		return
	var bus := get_bus(from)
	if bus == null:
		return
	if bus.has_method("connect_named"):
		bus.call("connect_named", signal_name, callable)
		return
	if bus.has_signal(signal_name) and not bus.is_connected(signal_name, callable):
		bus.connect(signal_name, callable)
