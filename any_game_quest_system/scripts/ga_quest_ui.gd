extends Control
class_name GaQuestUI

@export var quest_item_scene: PackedScene

@onready var quest_container: VBoxContainer = $MarginContainer/QuestContainer

var quest_items: Dictionary = {}
const COMPLETED_DISPLAY_DURATION: float = 2.5
var _showing_completed_quest_id: String = ""

func _ready() -> void:
	if not quest_item_scene:
		quest_item_scene = preload("res://godot_plugins/any_game_quest_system/scenes/ga_quest_item_ui.tscn")
	if GaEventBus:
		GaEventBus.quest_started.connect(_on_quest_started)
		GaEventBus.quest_completed.connect(_on_quest_completed)
		GaEventBus.quest_progress_updated.connect(_on_quest_progress_updated)
		GaEventBus.followed_quest_changed.connect(_on_followed_quest_changed)
	update_quests_display()

func update_quests_display() -> void:
	if not GaQuestManager:
		return
	if _showing_completed_quest_id != "" and _showing_completed_quest_id in quest_items:
		return
	var followed: GaQuest = GaQuestManager.get_followed_quest()
	var current_followed_id := followed.quest_id if followed else ""
	for quest_id in quest_items.keys():
		if quest_id != current_followed_id:
			_remove_quest_item(quest_id)
	if followed == null:
		visible = false
		return
	if not followed.quest_id in quest_items:
		_add_quest_item(followed)
	else:
		_update_quest_item(followed)
	if followed.quest_id in quest_items:
		var item = quest_items[followed.quest_id]
		for subquest_id in followed.subquests:
			if GaQuestManager.has_quest(subquest_id) and GaQuestManager.is_quest_active(subquest_id):
				item.add_subquest(GaQuestManager.all_quests[subquest_id])
		item._cleanup_completed_subquests()
	visible = true

func _add_quest_item(quest: GaQuest) -> void:
	var item = quest_item_scene.instantiate()
	quest_container.add_child(item)
	quest_items[quest.quest_id] = item
	item.set_quest(quest)

func _update_quest_item(quest: GaQuest) -> void:
	if quest.quest_id in quest_items:
		quest_items[quest.quest_id].set_quest(quest)

func _remove_quest_item(quest_id: String) -> void:
	if quest_id in quest_items:
		quest_items[quest_id].queue_free()
		quest_items.erase(quest_id)

func _on_quest_started(_quest_id: String) -> void:
	update_quests_display()

func _on_followed_quest_changed(_new_followed_id: String) -> void:
	for qid in quest_items.keys():
		if qid != _new_followed_id and GaQuestManager.is_quest_completed(qid):
			return
	update_quests_display()

func _on_quest_completed(quest_id: String) -> void:
	if GaQuestManager.has_quest(quest_id):
		var quest: GaQuest = GaQuestManager.all_quests[quest_id]
		if not quest.parent_quest_id.is_empty():
			if quest.parent_quest_id in quest_items:
				var parent_item = quest_items[quest.parent_quest_id]
				parent_item._update_subquest_progress()
				if quest_id in parent_item.subquest_items:
					parent_item.remove_subquest(quest_id)
				var parent_quest: GaQuest = GaQuestManager.all_quests.get(quest.parent_quest_id)
				if parent_quest and parent_quest.is_completed():
					return
				await get_tree().create_timer(0.3).timeout
			update_quests_display()
			return
	if quest_id in quest_items:
		_showing_completed_quest_id = quest_id
		var quest_item = quest_items[quest_id]
		quest_item.show_completed_with_ending()
		await get_tree().create_timer(COMPLETED_DISPLAY_DURATION).timeout
		await quest_item.fadeout_and_remove(func(): _remove_quest_item(quest_id), 0.5)
		_showing_completed_quest_id = ""
	update_quests_display()

func _on_quest_progress_updated(quest_id: String, progress: int, max_progress: int) -> void:
	if quest_id in quest_items:
		quest_items[quest_id].update_progress(progress, max_progress)
	if GaQuestManager.has_quest(quest_id):
		var quest: GaQuest = GaQuestManager.all_quests[quest_id]
		if not quest.parent_quest_id.is_empty() and quest.parent_quest_id in quest_items:
			quest_items[quest.parent_quest_id]._update_subquest_progress()
