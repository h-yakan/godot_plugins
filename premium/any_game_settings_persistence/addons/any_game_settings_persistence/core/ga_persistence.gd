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
	if ClassDB.class_exists("GaInputRemapper") or ResourceLoader.exists("res://addons/any_game_settings_persistence/pro_features/ga_input_remapper.gd"):
		var remapper = load("res://addons/any_game_settings_persistence/pro_features/ga_input_remapper.gd")
		remapper.load_input_settings(config, remappable_actions)

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
	var remapper = load("res://addons/any_game_settings_persistence/pro_features/ga_input_remapper.gd")
	remapper.load_input_settings(config, remappable_actions)

func reset_keys_to_defaults() -> void:
	var remapper = load("res://addons/any_game_settings_persistence/pro_features/ga_input_remapper.gd")
	remapper.reset_keys_to_defaults(config)
	save_data()

func save_action_mapping(action_name: StringName, events: Array) -> void:
	var remapper = load("res://addons/any_game_settings_persistence/pro_features/ga_input_remapper.gd")
	remapper.save_action_mapping(config, action_name, events)
	save_data()
