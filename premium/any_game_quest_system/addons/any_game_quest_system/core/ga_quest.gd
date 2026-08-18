extends Resource
class_name GaQuest

enum QuestStatus { NOT_STARTED, ACTIVE, COMPLETED, FAILED }

@export var quest_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var ending_description: String = ""
@export var status: QuestStatus = QuestStatus.NOT_STARTED
@export var current_progress: int = 0
@export var max_progress: int = 1
@export var completion_events: Array[String] = []
@export var start_events: Array[String] = []
@export var next_quest: String = ""
@export var prerequisite_quests: Array[String] = []
@export var subquests: Array[String] = []
var parent_quest_id: String = ""

func is_completed() -> bool:
	return status == QuestStatus.COMPLETED

func is_active() -> bool:
	return status == QuestStatus.ACTIVE

func get_progress_percentage() -> float:
	if not subquests.is_empty():
		var completed_count := 0
		for subquest_id in subquests:
			if GaQuestManager.has_quest(subquest_id):
				var subquest: GaQuest = GaQuestManager.all_quests[subquest_id]
				if subquest.is_completed():
					completed_count += 1
			return float(completed_count) / float(subquests.size()) if subquests.size() > 0 else 0.0
	if max_progress <= 0:
		return 0.0
	return float(current_progress) / float(max_progress)

func check_subquests_completion() -> bool:
	if subquests.is_empty():
		return false
	for subquest_id in subquests:
		if GaQuestManager.has_quest(subquest_id):
			var subquest: GaQuest = GaQuestManager.all_quests[subquest_id]
			if not subquest.is_completed():
				return false
	return true

func add_progress(amount: int = 1) -> void:
	if not subquests.is_empty():
		return
	current_progress = mini(current_progress + amount, max_progress)
	if current_progress >= max_progress:
		status = QuestStatus.COMPLETED

func set_progress(value: int) -> void:
	if not subquests.is_empty():
		return
	current_progress = clampi(value, 0, max_progress)
	if current_progress >= max_progress:
		status = QuestStatus.COMPLETED

func start() -> void:
	if status == QuestStatus.NOT_STARTED:
		status = QuestStatus.ACTIVE
		for subquest_id in subquests:
			GaQuestManager.start_quest(subquest_id)

func complete() -> void:
	status = QuestStatus.COMPLETED
	if subquests.is_empty():
		current_progress = max_progress
	if next_quest:
		GaQuestManager.start_quest(next_quest)

func fail() -> void:
	status = QuestStatus.FAILED
