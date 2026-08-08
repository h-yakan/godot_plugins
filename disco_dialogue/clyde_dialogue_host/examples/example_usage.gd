extends Node

## Recommended wiring for ClydeDialogueHost in komandolar or any Godot 4 project.

@export var dialogue_host_path: NodePath
@export var dialogue_path: String = "res://dialogue/intro_scene.clyde"

var _host: ClydeDialogueHost


func _ready() -> void:
	_host = get_node_or_null(dialogue_host_path) as ClydeDialogueHost
	if not _host:
		push_warning("ExampleUsage: assign dialogue_host_path to a ClydeDialogueHost")
		return

	_configure_defaults()
	_connect_signals()


func _configure_defaults() -> void:
	_host.default_stats_path = "res://data/character_stats.json"
	_host.default_modifiers_path = "res://data/modifiers.default.json"
	_host.max_lines_per_frame = 12
	_host.save_on_dialogue_end = true
	_host.load_persistence()


func _connect_signals() -> void:
	_host.dialogue_started.connect(func(path, block): print("[Dialogue] ", path, "@", block))
	_host.dialogue_ended.connect(func(): print("[Dialogue] ended"))
	_host.dice_rolled.connect(func(r): print("[Dialogue] roll_final=", r.get("final", 0)))
	_host.event_changed.connect(func(k, v, _p): print("[Dialogue] event ", k, "=", v))


func start_example_dialogue() -> void:
	if _host:
		_host.start_dialogue(dialogue_path, "START")
