extends Control
class_name GaDialogueUI

const _EventBus := preload("res://addons/any_game_dialogue_subtitles/core/ga_event_bus_client.gd")

@export var characters_per_second: float = 30.0
@export var dialogue_label_path: NodePath = ^"DialogueLabel"

var is_dialogue_visible: bool = false
var current_typewriter_task: int = -1

@onready var dialogue_label: RichTextLabel = get_node_or_null(dialogue_label_path)

func _ready() -> void:
	visible = false
	if dialogue_label:
		dialogue_label.bbcode_enabled = true
		dialogue_label.text = ""
	_EventBus.listen(self, &"ear_state_changed", _on_ear_state_changed)

func _on_ear_state_changed(is_holding: bool) -> void:
	var ear_effect := get_node_or_null("EarEffect")
	if ear_effect:
		ear_effect.visible = is_holding

func show_dialogue(text: String, speed: float = -1.0, speaker_id: String = "", color: Color = Color.WHITE) -> void:
	current_typewriter_task = -1
	var typing_speed := speed if speed > 0 else characters_per_second
	var delay_per_character := 1.0 / typing_speed
	visible = true
	is_dialogue_visible = true
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	await _start_typewriter_effect(text, delay_per_character, speaker_id, color)

func _start_typewriter_effect(text: String, delay_per_character: float, speaker_id: String, color: Color = Color.WHITE) -> void:
	if not dialogue_label:
		return
	current_typewriter_task = Time.get_ticks_msec()
	var task_id := current_typewriter_task
	var color_hex := "#" + color.to_html(false)
	dialogue_label.text = "[color=%s]" % color_hex
	for i in range(text.length()):
		if current_typewriter_task != task_id:
			return
		dialogue_label.text += text[i]
		if not speaker_id.is_empty():
			_EventBus.emit(self, &"dialogue_character_typed", [speaker_id])
		await _wait_dialogue_delay(delay_per_character)
	dialogue_label.text += "[/color]"

func _wait_dialogue_delay(time: float) -> void:
	var waited := 0.0
	while waited < time:
		var tree := get_tree()
		if tree:
			await tree.process_frame
			var paused_overlay := GaDialogueManager.dialogue_paused_by_overlay if GaDialogueManager else false
			if not tree.paused and not paused_overlay:
				waited += get_process_delta_time()

func hide_dialogue() -> void:
	if not is_dialogue_visible:
		return
	current_typewriter_task = -1
	is_dialogue_visible = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	visible = false
	if dialogue_label:
		dialogue_label.text = ""
