extends Node

## Catalog of cross-plugin signals. Other addons look up `/root/GaEventBus`
## and call `register_signal` / `emit_named` / `connect_named` so they stay
## compatible without a hard identifier dependency.

signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal quest_progress_updated(quest_id: String, progress: int, max_progress: int)
signal followed_quest_changed(quest_id: String)
signal dialogue_started(dialogue_id: String)
signal dialogue_finished(dialogue_id: Variant)
signal dialogue_character_typed(speaker_id: String)
signal interactable_activated(interactable_id: String, interactable_type: String)
signal interactable_threatened(interactable_id: String)
signal interactable_threat_removed(interactable_id: String, interactable_type: String)
signal player_health_changed(current_health: float, max_health: float)
signal game_state_changed(new_state: String)
signal eyes_closed()
signal eyes_toggle()
signal ear_state_changed(is_closed: bool)
signal pickup_item(item_name: String)
signal inventory_changed()
signal equipped_changed(item: Resource)
signal save_completed()
signal player_move_switch(is_enabled: bool)
signal player_look_switch(is_release_mouse: bool)
signal toggle_ui()
signal watching_finished()
signal show_warning(content: String, duration: float)
signal camera_shake_trauma(amount: float)
signal show_note(note_content: String)

func register_signal(signal_name: StringName, args: Array = []) -> void:
	if has_signal(signal_name):
		return
	add_user_signal(String(signal_name), args)

func emit_named(signal_name: StringName, args: Array = []) -> void:
	if not has_signal(signal_name):
		register_signal(signal_name)
	var packed: Array = [signal_name]
	packed.append_array(args)
	callv("emit_signal", packed)

func connect_named(signal_name: StringName, callable: Callable) -> void:
	if not has_signal(signal_name):
		register_signal(signal_name)
	if is_connected(signal_name, callable):
		return
	connect(signal_name, callable)
