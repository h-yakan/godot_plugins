extends RefCounted
class_name GaInputRemapper

## Pro input remapping helpers used with GaPersistence.

static func load_input_settings(config: ConfigFile, remappable_actions: Array) -> void:
	for entry in remappable_actions:
		var action: StringName = entry.get("action", &"")
		var saved_value: String = config.get_value("Input", str(action), "")
		if saved_value == "":
			continue
		InputMap.action_erase_events(action)
		for part in saved_value.split("|"):
			var event := decode_event(part)
			if event:
				InputMap.action_add_event(action, event)

static func decode_event(data: String) -> InputEvent:
	if data.begins_with("KEY:"):
		var code := data.get_slice(":", 1).to_int()
		var event := InputEventKey.new()
		event.physical_keycode = code
		return event
	if data.begins_with("MB:"):
		var code := data.get_slice(":", 1).to_int()
		var event := InputEventMouseButton.new()
		event.button_index = code
		return event
	return null

static func reset_keys_to_defaults(config: ConfigFile) -> void:
	if config.has_section("Input"):
		config.erase_section("Input")
	InputMap.load_from_project_settings()

static func save_action_mapping(config: ConfigFile, action_name: StringName, events: Array) -> void:
	var encoded_list: Array[String] = []
	for event in events:
		var encoded := ""
		if event is InputEventKey:
			var key_event := event as InputEventKey
			var keycode := key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
			encoded = "KEY:%d" % keycode
		elif event is InputEventMouseButton:
			var mouse_event := event as InputEventMouseButton
			encoded = "MB:%d" % mouse_event.button_index
		if encoded != "":
			encoded_list.append(encoded)
	config.set_value("Input", str(action_name), "|".join(encoded_list))
