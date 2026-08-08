extends Control
class_name GaProgressTracker

@export var item_ui_scene: PackedScene
@export var tooltip_scene: PackedScene

@onready var followed_quest_label: Label = $Panel/MarginContainer/HBoxContainer/Quests/FollowedQuest/Quest
@onready var all_quests_richtext: RichTextLabel = $Panel/MarginContainer/HBoxContainer/Quests/AllQuests/RichTextLabel
@onready var previous_dialogues_richtext: RichTextLabel = $Panel/MarginContainer/HBoxContainer/PreviousDialoguesAndInventory/Dialogues/RichTextLabel
@onready var followed_quest_description_label: Label = $Panel/MarginContainer/HBoxContainer/Quests/FollowedQuest/Description
@onready var inventory_items_container: VBoxContainer = %Items

var equipped_item_prefix: String = " (equipped)"
var empty_inventory: String = "Inventory empty."
var no_followed_quest: String = "No followed quest."
var no_quest: String = "No quests yet."
var no_dialogue: String = "No dialogue yet."
var _tooltip: Control

func _ready() -> void:
	if not item_ui_scene:
		item_ui_scene = preload("res://godot_plugins/any_game_inventory/scenes/ga_item_ui.tscn")
	if tooltip_scene:
		_tooltip = tooltip_scene.instantiate()
		add_child(_tooltip)
	if GaEventBus:
		GaEventBus.followed_quest_changed.connect(_on_followed_quest_changed)
		GaEventBus.quest_started.connect(_on_quest_started_or_completed)
		GaEventBus.quest_completed.connect(_on_quest_started_or_completed)
		GaEventBus.dialogue_finished.connect(_on_dialogue_finished)
		GaEventBus.inventory_changed.connect(_on_inventory_changed)
		GaEventBus.equipped_changed.connect(_on_equipped_changed)
	if all_quests_richtext:
		all_quests_richtext.meta_clicked.connect(_on_quest_meta_clicked)
	call_deferred("refresh_ui")

func refresh_ui() -> void:
	_refresh_dialogue_history()
	_refresh_quests_list()
	_refresh_followed_quest()
	_refresh_inventory()

func _refresh_dialogue_history() -> void:
	if not GaDialogueManager or not previous_dialogues_richtext:
		return
	var history = GaDialogueManager.get_dialogue_history()
	var lines: PackedStringArray = []
	for entry in history:
		var speaker_id: String = entry.get("speaker_id", "")
		var text: String = entry.get("text", "")
		if speaker_id.is_empty():
			lines.append(text)
		else:
			var color = GaDialogueManager.get_speaker_color(speaker_id)
			lines.append("[color=#%s]%s[/color]" % [color.to_html(), text])
	previous_dialogues_richtext.text = "\n\n".join(lines) if lines.size() > 0 else no_dialogue

func _refresh_quests_list() -> void:
	if not GaQuestManager or not all_quests_richtext:
		return
	var bb: Array[String] = []
	for quest in GaQuestManager.get_active_quests():
		if quest.parent_quest_id.is_empty():
			bb.append("[url=%s]%s[/url]" % [quest.quest_id, quest.title])
	for quest_id in GaQuestManager.get_completed_quest_ids():
		if quest_id in GaQuestManager.all_quests:
			var q: GaQuest = GaQuestManager.all_quests[quest_id]
			if q.parent_quest_id.is_empty():
				bb.append("[color=#888][s]%s[/s] (done)[/color]" % q.title)
	all_quests_richtext.text = "\n".join(bb) if bb.size() > 0 else no_quest

func _refresh_followed_quest() -> void:
	if not followed_quest_label:
		return
	var quest: GaQuest = GaQuestManager.get_followed_quest() if GaQuestManager else null
	if quest == null:
		followed_quest_label.text = no_followed_quest
		if followed_quest_description_label:
			followed_quest_description_label.text = ""
		return
	followed_quest_label.text = quest.title
	if followed_quest_description_label:
		followed_quest_description_label.text = quest.description

func _refresh_inventory() -> void:
	if not inventory_items_container:
		return
	for child in inventory_items_container.get_children():
		child.queue_free()
	if not GaInventoryManager:
		return
	if GaInventoryManager.inventory.is_empty():
		var empty_label := Label.new()
		empty_label.text = empty_inventory
		inventory_items_container.add_child(empty_label)
		return
	for i in range(GaInventoryManager.inventory.size()):
		var item: GaItemData = GaInventoryManager.inventory[i]
		var item_ui = item_ui_scene.instantiate()
		if item_ui.has_method("set_item"):
			item_ui.set_item(item, item == GaInventoryManager.equipped_item)
		elif item_ui is Button:
			item_ui.text = item.item_name
		item_ui.pressed.connect(_on_inventory_item_pressed.bind(i))
		inventory_items_container.add_child(item_ui)

func _on_inventory_item_pressed(idx: int) -> void:
	if GaInventoryManager.equip_item(idx):
		_refresh_inventory()

func _on_quest_meta_clicked(meta: Variant) -> void:
	if GaQuestManager:
		GaQuestManager.set_followed_quest(str(meta))
		_refresh_followed_quest()

func _on_followed_quest_changed(_quest_id: String) -> void:
	_refresh_followed_quest()

func _on_quest_started_or_completed(_quest_id: String) -> void:
	_refresh_quests_list()
	_refresh_followed_quest()

func _on_dialogue_finished(_dialogue_id) -> void:
	_refresh_dialogue_history()

func _on_inventory_changed() -> void:
	_refresh_inventory()

func _on_equipped_changed(_item: GaItemData) -> void:
	_refresh_inventory()
