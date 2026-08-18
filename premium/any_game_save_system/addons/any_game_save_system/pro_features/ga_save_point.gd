extends Area3D
class_name GaSavePoint

const _EventBus := preload("res://addons/any_game_save_system/core/ga_event_bus_client.gd")

@export var slot_index: int = 0
@export var interact_action: StringName = &"interact"

func interact() -> void:
	if GaSaveManager and GaSaveManager.save_game(slot_index):
		_EventBus.emit(self, &"save_completed")
