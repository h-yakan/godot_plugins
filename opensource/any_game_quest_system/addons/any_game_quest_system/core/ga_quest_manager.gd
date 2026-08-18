extends Node

const _EventBus := preload("res://addons/any_game_quest_system/core/ga_event_bus_client.gd")

@export var quest_directory: String = "res://quests/"
@export var save_path: String = "user://ga_quest_save.dat"
@export var quest_ui_path: NodePath

var active_quests: Dictionary = {}
var completed_quests: Array[String] = []
var failed_quests: Array[String] = []
var all_quests: Dictionary = {}
var followed_quest_id: String = ""
var quest_ui: Control = null

func _ready() -> void:
	_EventBus.listen(self, &"quest_started", _on_quest_started)
	_EventBus.listen(self, &"quest_completed", _on_quest_completed)
	_EventBus.listen(self, &"interactable_activated", _on_interactable_activated)
	call_deferred("_setup_quest_ui")
	call_deferred("register_all_quests")
	load_game()

func set_quest_ui(ui: Control) -> void:
	quest_ui = ui
	if quest_ui and quest_ui.has_method("update_quests_display"):
		quest_ui.update_quests_display()

func _setup_quest_ui() -> void:
	if quest_ui_path.is_empty():
		return
	var node := get_node_or_null(quest_ui_path)
	if node is Control:
		set_quest_ui(node)

func save_game() -> void:
	var save_data := {}
	for id in all_quests:
		save_data[id] = all_quests[id].status
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return
	var save_data = file.get_var()
	file.close()
	if save_data is Dictionary:
		for id in save_data:
			if all_quests.has(id):
				all_quests[id].status = save_data[id]

func register_quest(quest: GaQuest) -> void:
	if quest.quest_id.is_empty():
		push_error("GaQuest: quest_id cannot be empty")
		return
	all_quests[quest.quest_id] = quest
	quest.status = GaQuest.QuestStatus.NOT_STARTED
	_update_subquest_relationships(quest)
	for other_quest_id in all_quests:
		var other_quest: GaQuest = all_quests[other_quest_id]
		if quest.quest_id in other_quest.subquests:
			quest.parent_quest_id = other_quest_id

func register_all_quests() -> void:
	var dir := DirAccess.open(quest_directory)
	if not dir:
		push_warning("GaQuestManager: quest directory not found: %s" % quest_directory)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".remap")):
			var clean_path := quest_directory.path_join(file_name.replace(".remap", ""))
			var quest_res := load(clean_path) as GaQuest
			if quest_res:
				all_quests[quest_res.quest_id] = quest_res
		file_name = dir.get_next()
	dir.list_dir_end()
	for q in all_quests.values():
		_update_subquest_relationships(q)

func _update_subquest_relationships(parent_quest: GaQuest) -> void:
	for subquest_id in parent_quest.subquests:
		if subquest_id in all_quests:
			all_quests[subquest_id].parent_quest_id = parent_quest.quest_id

func start_quest(quest_id: String) -> bool:
	if not quest_id in all_quests:
		push_warning("GaQuestManager: quest not found: %s" % quest_id)
		return false
	var quest: GaQuest = all_quests[quest_id]
	if not _check_prerequisites(quest):
		return false
	if completed_quests.has(quest_id) or failed_quests.has(quest_id) or active_quests.has(quest_id):
		return false
	quest.start()
	active_quests[quest_id] = quest
	for subquest_id in quest.subquests:
		if subquest_id in all_quests:
			var subquest: GaQuest = all_quests[subquest_id]
			subquest.parent_quest_id = quest_id
			if _check_prerequisites(subquest):
				subquest.start()
				active_quests[subquest_id] = subquest
				for event_id in subquest.start_events:
					_trigger_event(event_id)
				_EventBus.emit(self, &"quest_started", [subquest_id])
	for event_id in quest.start_events:
		_trigger_event(event_id)
	_EventBus.emit(self, &"quest_started", [quest_id])
	if followed_quest_id.is_empty() and quest.parent_quest_id.is_empty():
		set_followed_quest(quest_id)
	if quest_ui and quest_ui.has_method("update_quests_display"):
		quest_ui.update_quests_display()
	return true

func update_quest_progress(quest_id: String, progress: int) -> void:
	if not quest_id in active_quests:
		return
	var quest: GaQuest = all_quests[quest_id]
	if not quest.subquests.is_empty():
		return
	var old_progress := quest.current_progress
	quest.set_progress(progress)
	if quest.current_progress != old_progress:
		_EventBus.emit(self, &"quest_progress_updated", [quest_id, quest.current_progress, quest.max_progress])
	if quest.is_completed():
		complete_quest(quest_id)
	if quest_ui and quest_ui.has_method("update_quests_display"):
		quest_ui.update_quests_display()

func add_quest_progress(quest_id: String, amount: int = 1) -> void:
	if not quest_id in active_quests:
		return
	var quest: GaQuest = all_quests[quest_id]
	if not quest.subquests.is_empty():
		return
	var old_progress := quest.current_progress
	quest.add_progress(amount)
	if quest.current_progress != old_progress:
		_EventBus.emit(self, &"quest_progress_updated", [quest_id, quest.current_progress, quest.max_progress])
	if quest.is_completed():
		complete_quest(quest_id)
	if quest_ui and quest_ui.has_method("update_quests_display"):
		quest_ui.update_quests_display()

func complete_quest(quest_id: String) -> void:
	if not quest_id in active_quests:
		return
	var quest: GaQuest = all_quests[quest_id]
	var next_quest := quest.next_quest
	quest.complete()
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	if quest_id == followed_quest_id:
		followed_quest_id = ""
		if next_quest:
			set_followed_quest(next_quest)
		else:
			for q in active_quests.values():
				if q.parent_quest_id.is_empty():
					set_followed_quest(q.quest_id)
					break
			if followed_quest_id.is_empty():
				_EventBus.emit(self, &"followed_quest_changed", [""])
	for event_id in quest.completion_events:
		_trigger_event(event_id)
	_EventBus.emit(self, &"quest_completed", [quest_id])
	if not quest.parent_quest_id.is_empty() and quest.parent_quest_id in all_quests:
		var parent_quest: GaQuest = all_quests[quest.parent_quest_id]
		if parent_quest.check_subquests_completion():
			complete_quest(quest.parent_quest_id)
	if quest_ui and quest_ui.has_method("update_quests_display"):
		quest_ui.update_quests_display()

func fail_quest(quest_id: String) -> void:
	if not quest_id in active_quests:
		return
	var quest: GaQuest = all_quests[quest_id]
	quest.fail()
	active_quests.erase(quest_id)
	failed_quests.append(quest_id)
	_EventBus.emit(self, &"quest_failed", [quest_id])
	if quest_ui and quest_ui.has_method("update_quests_display"):
		quest_ui.update_quests_display()

func has_quest(quest_id: String) -> bool:
	return quest_id in all_quests

func is_quest_active(quest_id: String) -> bool:
	return quest_id in active_quests

func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests

func get_active_quests() -> Array:
	return active_quests.values()

func get_completed_quest_ids() -> Array[String]:
	return completed_quests.duplicate()

func set_followed_quest(quest_id: String) -> bool:
	if quest_id.is_empty():
		followed_quest_id = ""
		_EventBus.emit(self, &"followed_quest_changed", [""])
		return true
	if not quest_id in active_quests:
		return false
	followed_quest_id = quest_id
	_EventBus.emit(self, &"followed_quest_changed", [quest_id])
	return true

func get_followed_quest() -> GaQuest:
	if followed_quest_id.is_empty() or not followed_quest_id in active_quests:
		return null
	return all_quests[followed_quest_id]

func _check_prerequisites(quest: GaQuest) -> bool:
	for prereq_id in quest.prerequisite_quests:
		if not is_quest_completed(prereq_id):
			return false
	return true

func _trigger_event(event_id: String) -> void:
	pass

func _on_quest_started(_quest_id: String) -> void:
	pass

func _on_quest_completed(_quest_id: String) -> void:
	pass

func _on_interactable_activated(_interactable_id: String, _interactable_type: String) -> void:
	pass
