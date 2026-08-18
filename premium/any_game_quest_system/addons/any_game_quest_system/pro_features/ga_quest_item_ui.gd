extends Control
class_name GaQuestItemUI

@onready var title_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/TitleLabel
@onready var description_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DescriptionLabel
@onready var progress_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/ProgressLabel
@onready var checkmark: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Checkmark
@onready var subquest_set: VBoxContainer = $Panel/MarginContainer/VBoxContainer/Subquest/VBoxContainer

var current_quest: GaQuest = null
var subquest_items: Dictionary = {}
var subquest_containers: Dictionary = {}
var is_subquest: bool = false

func _ready() -> void:
	if checkmark:
		checkmark.visible = false
	modulate.a = 1.0
	scale = Vector2.ONE

func set_quest(quest: GaQuest) -> void:
	current_quest = quest
	title_label.text = quest.title
	description_label.text = quest.description
	if is_subquest:
		_apply_subquest_style()
	if not quest.subquests.is_empty():
		var completed_count := 0
		for subquest_id in quest.subquests:
			if GaQuestManager.has_quest(subquest_id):
				var subquest: GaQuest = GaQuestManager.all_quests[subquest_id]
				if subquest.is_completed():
					completed_count += 1
				if GaQuestManager.is_quest_active(subquest_id):
					add_subquest(subquest)
		progress_label.text = "%d / %d" % [completed_count, quest.subquests.size()]
	else:
		update_progress(quest.current_progress, quest.max_progress)
	checkmark.visible = quest.is_completed()

func _apply_subquest_style() -> void:
	title_label.add_theme_font_size_override("font_size", 13)
	description_label.add_theme_font_size_override("font_size", 10)
	if progress_label:
		progress_label.add_theme_font_size_override("font_size", 9)

func update_progress(progress: int, max_progress: int) -> void:
	if max_progress > 1:
		progress_label.text = "%d / %d" % [progress, max_progress]
	else:
		progress_label.text = ""
	if current_quest and progress >= max_progress:
		mark_completed()

func mark_completed() -> void:
	checkmark.visible = true
	title_label.modulate = Color(0.7, 0.7, 0.7)
	description_label.modulate = Color(0.7, 0.7, 0.7)

func show_completed_with_ending() -> void:
	mark_completed()
	if current_quest:
		description_label.text = current_quest.ending_description if not current_quest.ending_description.is_empty() else current_quest.description
		if not current_quest.subquests.is_empty():
			progress_label.text = "%d / %d" % [current_quest.subquests.size(), current_quest.subquests.size()]

func add_subquest(subquest: GaQuest) -> void:
	if not subquest_set or is_subquest:
		return
	if subquest.quest_id in subquest_items:
		_update_subquest_display(subquest)
		_update_subquest_progress()
		return
	var subquest_scene := preload("res://addons/any_game_quest_system/pro_features/scenes/ga_subquest_ui.tscn")
	var subquest_ui_instance = subquest_scene.instantiate()
	subquest_set.add_child(subquest_ui_instance)
	var subquest_title_label = subquest_ui_instance.get_node("TitleLabel")
	var subquest_checkmark = subquest_ui_instance.get_node("Checkmark")
	if subquest_title_label:
		subquest_title_label.text = subquest.title
	if subquest_checkmark:
		subquest_checkmark.visible = subquest.is_completed()
	subquest_items[subquest.quest_id] = subquest_ui_instance
	subquest_containers[subquest.quest_id] = subquest_ui_instance
	_update_subquest_progress()

func _update_subquest_display(subquest: GaQuest) -> void:
	if not subquest.quest_id in subquest_items:
		return
	var inst = subquest_items[subquest.quest_id]
	var subquest_title_label = inst.get_node_or_null("TitleLabel")
	var subquest_checkmark = inst.get_node_or_null("Checkmark")
	if subquest_title_label:
		subquest_title_label.text = subquest.title
	if subquest_checkmark:
		subquest_checkmark.visible = subquest.is_completed()

func _update_subquest_progress() -> void:
	if current_quest and not current_quest.subquests.is_empty():
		var completed_count := 0
		for sq_id in current_quest.subquests:
			if GaQuestManager.has_quest(sq_id):
				var sq: GaQuest = GaQuestManager.all_quests[sq_id]
				if sq.is_completed():
					completed_count += 1
				if sq_id in subquest_items:
					_update_subquest_display(sq)
		progress_label.text = "%d / %d" % [completed_count, current_quest.subquests.size()]
		if completed_count >= current_quest.subquests.size():
			mark_completed()

func remove_subquest(subquest_id: String) -> void:
	if subquest_id in subquest_items:
		if subquest_id in subquest_containers:
			subquest_containers[subquest_id].queue_free()
			subquest_containers.erase(subquest_id)
		subquest_items.erase(subquest_id)
		_update_subquest_progress()

func _cleanup_completed_subquests() -> void:
	if not current_quest or not subquest_set:
		return
	var to_remove: Array[String] = []
	for subquest_id in subquest_items.keys():
		if not GaQuestManager.is_quest_active(subquest_id):
			to_remove.append(subquest_id)
	for subquest_id in to_remove:
		remove_subquest(subquest_id)

func fadeout_and_remove(callback: Callable, duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), duration)
	await tween.finished
	if callback.is_valid():
		callback.call()
