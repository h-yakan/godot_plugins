extends Area3D
class_name GaSavePoint

@export var slot_index: int = 0
@export var interact_action: StringName = &"interact"

func interact() -> void:
	if GaSaveManager and GaSaveManager.save_game(slot_index):
		if GaEventBus:
			GaEventBus.save_completed.emit()
