extends Node

## Example: extend built-in triggers with game-specific handlers.

@export var dialogue_host_path: NodePath

var _host: ClydeDialogueHost


func _ready() -> void:
	_host = get_node_or_null(dialogue_host_path) as ClydeDialogueHost
	if not _host:
		push_warning("ExampleTriggerHandler: ClydeDialogueHost not found")
		return

	# Built-in: roll_dice, set_event, record_event, add_modifier, set_stat, save_state, load_state
	# Add only game-specific triggers here:
	_host.register_trigger("change_scene", _on_change_scene)


func _on_change_scene(args: Array) -> void:
	if args.is_empty():
		return
	print("[ExampleTriggerHandler] change_scene -> ", args[0])
