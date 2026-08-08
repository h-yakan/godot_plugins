extends Node

var inventory: Array[GaItemData] = []
var equipped_item: GaItemData = null
var placed_items: Dictionary = {}
var item_registry: Dictionary = {}

func register_item(item_id: String, item_data: GaItemData) -> void:
	item_registry[item_id] = item_data

func resolve_item(path_or_name: String) -> GaItemData:
	if path_or_name.begins_with("res://"):
		return load(path_or_name) as GaItemData
	if item_registry.has(path_or_name):
		return item_registry[path_or_name]
	for item in inventory:
		if item and item.item_name == path_or_name:
			return item
	return null

func pickup_item(item_data: GaItemData) -> void:
	inventory.append(item_data)
	if GaEventBus:
		GaEventBus.inventory_changed.emit()

func equip_item(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= inventory.size():
		return false
	if equipped_item == inventory[slot_index]:
		unequip_item()
		return true
	equipped_item = inventory[slot_index]
	if GaEventBus:
		GaEventBus.equipped_changed.emit(equipped_item)
	return true

func unequip_item() -> void:
	equipped_item = null
	if GaEventBus:
		GaEventBus.equipped_changed.emit(null)

func has_item(item_name: String) -> bool:
	for item in inventory:
		if item.item_name == item_name:
			return true
	return false

func is_item_placed(item_name: String) -> bool:
	for item in placed_items.keys():
		if item.item_name == item_name:
			return true
	return false

func get_item_by_name(item_name: String) -> GaItemData:
	for item in inventory:
		if item.item_name == item_name:
			return item
	return null

func delete_item(item: GaItemData) -> void:
	inventory.erase(item)

func free_hand_item() -> void:
	var item := equipped_item
	unequip_item()
	delete_item(item)
	if GaEventBus:
		GaEventBus.inventory_changed.emit()
