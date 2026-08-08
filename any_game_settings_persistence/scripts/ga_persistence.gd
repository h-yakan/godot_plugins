extends Node

const PATH := "user://ga_settings.cfg"

@export var remappable_actions: Array[Dictionary] = [
	{"action": &"forward", "label": "Forward"},
	{"action": &"backward", "label": "Backward"},
	{"action": &"left", "label": "Left"},
	{"action": &"right", "label": "Right"},
	{"action": &"interact", "label": "Interact"},
	{"action": &"pause", "label": "Pause"},
]
@export var audio_bus_count: int = 3

var config := ConfigFile.new()
var headbob_enabled: bool = true

func _ready() -> void:
	config.set_value("Video", "FullscreenCheck", DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("Video", "BorderlessCheck", false)
	config.set_value("Video", "VSync", DisplayServer.VSYNC_ENABLED)
	config.set_value("Video", "Brightness", 1.0)
	config.set_value("Video", "Headbob", true)
	for i in range(audio_bus_count):
		config.set_value("Audio", str(i), 0.5)
	load_data()

func save_data() -> void:
	config.save(PATH)

func load_data() -> void:
	if config.load(PATH) != OK:
		save_data()
		return
	load_video_settings()
	load_audio_settings()
	load_input_settings()

func load_video_settings() -> void:
	DisplayServer.window_set_mode(config.get_value("Video", "FullscreenCheck"))
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, config.get_value("Video", "BorderlessCheck"))
	DisplayServer.window_set_vsync_mode(config.get_value("Video", "VSync"))
	headbob_enabled = bool(config.get_value("Video", "Headbob", true))

func load_audio_settings() -> void:
	for i in range(audio_bus_count):
		var vol: float = config.get_value("Audio", str(i), 0.5)
		if i < AudioServer.bus_count:
			AudioServer.set_bus_volume_db(i, linear_to_db(vol))

func set_headbob_enabled(enabled: bool) -> void:
	headbob_enabled = enabled
	config.set_value("Video", "Headbob", enabled)
	save_data()

func load_input_settings() -> void:
	for entry in remappable_actions:
		var action: StringName = entry.get("action", &"")
		var saved_value: String = config.get_value("Input", str(action), "")
		if saved_value == "":
			continue
		InputMap.action_erase_events(action)
		for part in saved_value.split("|"):
			var event := _decode_event(part)
			if event:
				InputMap.action_add_event(action, event)

func _decode_event(data: String) -> InputEvent:
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

func reset_keys_to_defaults() -> void:
	if config.has_section("Input"):
		config.erase_section("Input")
	InputMap.load_from_project_settings()
	save_data()

func save_action_mapping(action_name: StringName, events: Array[InputEvent]) -> void:
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
	save_data()
