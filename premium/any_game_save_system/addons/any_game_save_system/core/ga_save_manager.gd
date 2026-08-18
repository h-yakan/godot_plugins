extends Node

const _EventBus := preload("res://addons/any_game_save_system/core/ga_event_bus_client.gd")

@export var save_slots: int = 46
@export var save_dir: String = "user://ga_saves/"
@export var player_group: StringName = &"Player"
@export var player_head_path: NodePath = ^"Head"
@export var main_scene_path: String = ""
@export var use_event_bus: bool = true

var world_state: Dictionary = {}
var door_states: Dictionary = {}
var _pending_load: Dictionary = {}
var current_room_path: String = ""

func set_current_room_path(p: String) -> void:
	current_room_path = p

func _ready() -> void:
	_dir_ensure()

func _dir_ensure() -> void:
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)

func _slot_path(slot_index: int) -> String:
	return save_dir + "slot_%02d.save" % slot_index

func get_slot_info(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= save_slots:
		return {"exists": false, "timestamp": 0, "scene_path": "", "slot_index": slot_index}
	var path := _slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return {"exists": false, "timestamp": 0, "scene_path": "", "slot_index": slot_index}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"exists": false, "timestamp": 0, "scene_path": "", "slot_index": slot_index}
	var data = f.get_var()
	f.close()
	if data == null or not data is Dictionary:
		return {"exists": false, "timestamp": 0, "scene_path": "", "slot_index": slot_index}
	return {"exists": true, "timestamp": data.get("timestamp", 0), "scene_path": data.get("scene_path", ""), "slot_index": slot_index}

func get_all_slots_info() -> Array:
	var arr: Array = []
	for i in save_slots:
		arr.append(get_slot_info(i))
	return arr

func set_door_state(door_id: String, state: Dictionary) -> void:
	door_states[door_id] = state

func get_door_state(door_id: String) -> Dictionary:
	return door_states.get(door_id, {})

func set_world_state(key: String, value: Variant) -> void:
	world_state[key] = value

func get_world_state(key: String) -> Variant:
	return world_state.get(key)

func delete_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= save_slots:
		return false
	var path := _slot_path(slot_index)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	return true

func has_pending_load() -> bool:
	return not _pending_load.is_empty()

func get_pending_load_data() -> Dictionary:
	return _pending_load.duplicate(true)

func clear_pending_load() -> void:
	_pending_load.clear()

func apply_pending_load_to_player(player_node: Node, head_path: NodePath = ^"Head") -> void:
	if not has_pending_load():
		return
	var pl: Dictionary = _pending_load.get("player", {})
	if pl.is_empty():
		clear_pending_load()
		return
	if player_node is Node3D:
		var n3d := player_node as Node3D
		n3d.global_position = pl.get("position", n3d.global_position)
		n3d.rotation.y = pl.get("rotation_y", 0.0)
		var head: Node3D = player_node.get_node_or_null(head_path)
		if head:
			head.rotation.x = pl.get("head_rotation_x", head.rotation.x)
	if player_node.get("max_health") != null:
		player_node.max_health = pl.get("max_health", 50.0)
	if player_node.get("health") != null:
		player_node.health = pl.get("health", player_node.max_health)
	clear_pending_load()

func _find_player(root: Node) -> Node:
	var from_group := get_tree().get_first_node_in_group(player_group)
	if from_group:
		return from_group
	return root.get_node_or_null("GameSpace/Player")

func save_game(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= save_slots:
		return false
	var root := get_tree().current_scene
	if root == null:
		return false
	var player := _find_player(root)
	if player == null:
		push_error("GaSaveManager: player not found")
		return false
	var head := player.get_node_or_null(player_head_path)
	var data := _collect_save_data(
		current_room_path if current_room_path else (root.scene_file_path if root.scene_file_path else ""),
		player.global_position if player is Node3D else Vector3.ZERO,
		player.rotation.y if player is Node3D else 0.0,
		head.rotation.x if head else 0.0,
		player.get("health") if player.get("health") != null else 50.0,
		player.get("max_health") if player.get("max_health") != null else 50.0
	)
	data["timestamp"] = int(Time.get_unix_time_from_system())
	var f := FileAccess.open(_slot_path(slot_index), FileAccess.WRITE)
	if f == null:
		return false
	f.store_var(data)
	f.close()
	_EventBus.emit(self, &"save_completed", [], use_event_bus)
	return true

func _collect_save_data(scene_path: String, player_position: Vector3, player_rotation_y: float, player_head_rotation_x: float, player_health: float, player_max_health: float) -> Dictionary:
	return {
		"version": 1,
		"scene_path": scene_path,
		"player": {
			"position": player_position,
			"rotation_y": player_rotation_y,
			"head_rotation_x": player_head_rotation_x,
			"health": player_health,
			"max_health": player_max_health
		},
		"quests": _save_quests(),
		"inventory": _save_inventory(),
		"dialogue_history": _save_dialogue_history(),
		"door_states": door_states.duplicate(true),
		"world_state": world_state.duplicate(true)
	}

func _save_quests() -> Dictionary:
	if not GaQuestManager:
		return {}
	var qm := GaQuestManager
	var quest_data := {}
	for qid in qm.all_quests:
		var q: GaQuest = qm.all_quests[qid]
		quest_data[qid] = {"status": q.status, "current_progress": q.current_progress}
	return {
		"quest_states": quest_data,
		"active_quests": qm.active_quests.keys(),
		"completed_quests": qm.completed_quests.duplicate(),
		"failed_quests": qm.failed_quests.duplicate(),
		"followed_quest_id": qm.followed_quest_id
	}

func _save_inventory() -> Dictionary:
	if not GaInventoryManager:
		return {"items": [], "equipped_index": -1, "placed_items": []}
	var im := GaInventoryManager
	var item_paths: Array = []
	for item in im.inventory:
		var path := item.resource_path if item and item.resource_path else item.item_name
		item_paths.append(path)
	var equipped_index := -1
	if im.equipped_item != null:
		for i in range(im.inventory.size()):
			if im.inventory[i] == im.equipped_item:
				equipped_index = i
				break
	var placed_list: Array = []
	for item_data in im.placed_items:
		var area_id: String = im.placed_items[item_data]
		var path_or_name := item_data.resource_path if item_data and item_data.resource_path else item_data.item_name
		placed_list.append({"item": path_or_name, "area_id": area_id})
	return {"items": item_paths, "equipped_index": equipped_index, "placed_items": placed_list}

func _save_dialogue_history() -> Array:
	if not GaDialogueManager:
		return []
	return GaDialogueManager.get_dialogue_history()

func load_game(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= save_slots:
		return false
	var path := _slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var data = f.get_var()
	f.close()
	if data == null or not data is Dictionary:
		return false
	_apply_quests(data.get("quests", {}))
	_apply_inventory(data.get("inventory", {}))
	_apply_dialogue_history(data.get("dialogue_history", []))
	door_states.clear()
	for k in data.get("door_states", {}):
		door_states[k] = data["door_states"][k]
	world_state.clear()
	for k in data.get("world_state", {}):
		world_state[k] = data["world_state"][k]
	_pending_load = {"player": data.get("player", {}), "scene_path": data.get("scene_path", "")}
	var current := get_tree().current_scene
	if current and current.has_method("apply_pending_load"):
		current.apply_pending_load()
		return true
	if not main_scene_path.is_empty():
		get_tree().change_scene_to_file(main_scene_path)
	return true

func _apply_quests(quests_data: Dictionary) -> void:
	if not GaQuestManager:
		return
	var qm := GaQuestManager
	var states = quests_data.get("quest_states", {})
	for qid in states:
		if qm.all_quests.has(qid):
			var q: GaQuest = qm.all_quests[qid]
			q.status = states[qid].get("status", q.status)
			q.current_progress = states[qid].get("current_progress", 0)
	qm.active_quests.clear()
	for qid in quests_data.get("active_quests", []):
		if qm.all_quests.has(qid):
			qm.all_quests[qid].status = GaQuest.QuestStatus.ACTIVE
			qm.active_quests[qid] = qm.all_quests[qid]
	qm.completed_quests = quests_data.get("completed_quests", []).duplicate()
	qm.failed_quests = quests_data.get("failed_quests", []).duplicate()
	qm.followed_quest_id = quests_data.get("followed_quest_id", "")
	if qm.quest_ui and qm.quest_ui.has_method("update_quests_display"):
		qm.quest_ui.update_quests_display()

func _apply_inventory(inv_data: Dictionary) -> void:
	if not GaInventoryManager:
		return
	var im := GaInventoryManager
	im.inventory.clear()
	im.equipped_item = null
	for path_or_name in inv_data.get("items", []):
		var item: GaItemData = im.resolve_item(str(path_or_name))
		if item:
			im.inventory.append(item)
	var eq_idx: int = inv_data.get("equipped_index", -1)
	if eq_idx >= 0 and eq_idx < im.inventory.size():
		im.equip_item(eq_idx)
	im.placed_items.clear()
	for entry in inv_data.get("placed_items", []):
		if entry is Dictionary:
			var item_data: GaItemData = im.resolve_item(str(entry.get("item", "")))
			if item_data:
				im.placed_items[item_data] = entry.get("area_id", "")
	_EventBus.emit(self, &"inventory_changed")

func _apply_dialogue_history(history: Array) -> void:
	if not GaDialogueManager:
		return
	GaDialogueManager.dialogue_history.clear()
	for entry in history:
		if entry is Dictionary:
			GaDialogueManager.dialogue_history.append({"text": entry.get("text", ""), "speaker_id": entry.get("speaker_id", "")})
