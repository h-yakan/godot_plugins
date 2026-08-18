extends Node

const _EventBus := preload("res://addons/any_game_dialogue_subtitles/core/ga_event_bus_client.gd")

@export var default_duration: float = 3.0
@export var default_typing_speed: float = 30.0
@export var dialogue_ui_path: NodePath
@export var speaker_colors: Dictionary = {}

var dialogue_queue: Array = []
var is_showing_dialogue: bool = false
var current_dialogue: Dictionary = {}
var current_dialogue_id: int = 0
var dialogue_history: Array = []
var dialogue_paused_by_overlay: bool = false
var dialogue_ui: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_EventBus.listen(self, &"quest_completed", _on_quest_completed)
	_EventBus.listen(self, &"quest_started", _on_quest_started)
	call_deferred("_setup_dialogue_ui")

func set_dialogue_ui(ui: Control) -> void:
	dialogue_ui = ui

func _setup_dialogue_ui() -> void:
	if dialogue_ui_path.is_empty():
		return
	var node := get_node_or_null(dialogue_ui_path)
	if node is Control:
		set_dialogue_ui(node)

func show_dialogue(text: String, duration: float = -1.0, priority: int = 0, typing_speed: float = -1.0, speaker_id: String = "") -> void:
	if duration < 0:
		duration = default_duration
	if typing_speed < 0:
		typing_speed = default_typing_speed
	var dialogue_data := {
		"text": text,
		"duration": duration,
		"priority": priority,
		"typing_speed": typing_speed,
		"speaker_id": speaker_id
	}
	if is_showing_dialogue and current_dialogue.get("priority", 0) < priority:
		_insert_by_priority(current_dialogue)
		current_dialogue_id += 1
		current_dialogue = dialogue_data
		if dialogue_ui:
			await dialogue_ui.show_dialogue(current_dialogue.text, current_dialogue.get("typing_speed", default_typing_speed), current_dialogue.get("speaker_id", ""), get_speaker_color(speaker_id))
		_EventBus.emit(self, &"dialogue_started", ["dialogue_%d" % Time.get_ticks_msec()])
		_process_current_dialogue(current_dialogue_id)
		return
	_insert_by_priority(dialogue_data)
	if not is_showing_dialogue:
		_process_queue()

func show_dialogue_multiline(dialogue_text: String, post_typing_duration: float = 1.0, priority: int = 0, typing_speed: float = -1.0, speaker_id: String = "") -> void:
	if dialogue_text.is_empty():
		return
	for line in dialogue_text.split("\n"):
		line = line.strip_edges()
		if not line.begins_with("-"):
			continue
		var dialogue_line := line.substr(1).strip_edges()
		if dialogue_line.is_empty():
			continue
		var line_speaker_id := speaker_id
		var line_typing_speed := typing_speed
		var remaining_text := dialogue_line
		while remaining_text.begins_with("["):
			var bracket_end := remaining_text.find("]")
			if bracket_end <= 0:
				break
			var bracket_content := remaining_text.substr(1, bracket_end - 1).strip_edges()
			remaining_text = remaining_text.substr(bracket_end + 1).strip_edges()
			if bracket_content.is_valid_float():
				line_typing_speed = bracket_content.to_float()
			elif not bracket_content.is_empty():
				line_speaker_id = bracket_content
		var actual_typing_speed := line_typing_speed if line_typing_speed > 0 else default_typing_speed
		var typing_duration := remaining_text.length() / actual_typing_speed
		var total_duration := typing_duration + post_typing_duration
		if not remaining_text.is_empty():
			show_dialogue(remaining_text, total_duration, priority, line_typing_speed, line_speaker_id)

func _insert_by_priority(dialogue_data: Dictionary) -> void:
	var inserted := false
	for i in range(dialogue_queue.size()):
		if dialogue_queue[i].get("priority", 0) < dialogue_data.get("priority", 0):
			dialogue_queue.insert(i, dialogue_data)
			inserted = true
			break
	if not inserted:
		dialogue_queue.append(dialogue_data)

func _process_queue() -> void:
	if dialogue_queue.is_empty():
		is_showing_dialogue = false
		current_dialogue = {}
		if dialogue_ui:
			await dialogue_ui.hide_dialogue()
		return
	is_showing_dialogue = true
	current_dialogue = dialogue_queue.pop_front()
	current_dialogue_id += 1
	var dialogue_id := current_dialogue_id
	if dialogue_ui:
		var typing_speed := current_dialogue.get("typing_speed", default_typing_speed)
		var speaker_id := current_dialogue.get("speaker_id", "")
		await dialogue_ui.show_dialogue(current_dialogue.text, typing_speed, speaker_id, get_speaker_color(speaker_id))
		_EventBus.emit(self, &"dialogue_started", ["dialogue_%d" % Time.get_ticks_msec()])
	else:
		print("[GaDialogue] ", current_dialogue.text)
	_process_current_dialogue(dialogue_id)

func _process_current_dialogue(dialogue_id: int = -1) -> void:
	if dialogue_id == -1:
		dialogue_id = current_dialogue_id
	var typing_speed := current_dialogue.get("typing_speed", default_typing_speed)
	var typing_duration := current_dialogue.text.length() / typing_speed
	var remaining_duration := current_dialogue.duration - typing_duration
	if remaining_duration > 0:
		await _wait_unpaused(remaining_duration)
	if dialogue_id != current_dialogue_id:
		return
	if dialogue_ui:
		await dialogue_ui.hide_dialogue()
	if dialogue_id != current_dialogue_id:
		return
	dialogue_history.append({"text": current_dialogue.text, "speaker_id": current_dialogue.get("speaker_id", "")})
	if dialogue_history.size() > 50:
		dialogue_history.pop_front()
	_EventBus.emit(self, &"dialogue_finished", [dialogue_id])
	_process_queue()

func get_speaker_color(speaker_id: String) -> Color:
	if speaker_id.is_empty():
		return Color.WHITE
	return speaker_colors.get(speaker_id, Color.WHITE)

func set_dialogue_paused_by_overlay(paused: bool) -> void:
	dialogue_paused_by_overlay = paused

func _wait_unpaused(time: float) -> void:
	var elapsed := 0.0
	while elapsed < time:
		await get_tree().process_frame
		if not get_tree().paused and not dialogue_paused_by_overlay:
			elapsed += get_process_delta_time()

func clear_queue() -> void:
	dialogue_queue.clear()
	if dialogue_ui:
		dialogue_ui.hide_dialogue()
	is_showing_dialogue = false

func get_dialogue_history() -> Array:
	return dialogue_history.duplicate()

func _on_quest_completed(_quest_id: String) -> void:
	pass

func _on_quest_started(_quest_id: String) -> void:
	pass
