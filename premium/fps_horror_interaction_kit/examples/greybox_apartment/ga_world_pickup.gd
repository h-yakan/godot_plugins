extends StaticBody3D
class_name GaWorldPickup

## Demo / kit convenience: look at the object, press interact, it goes into inventory.

@export var item_data: GaItemData
@export var pickup_message: String = ""

func interact() -> void:
	if item_data == null:
		return
	var inv := get_tree().root.get_node_or_null("GaInventoryManager")
	if inv == null or not inv.has_method("pickup_item"):
		return
	inv.call("pickup_item", item_data)
	if not pickup_message.is_empty():
		var bus := get_tree().root.get_node_or_null("GaEventBus")
		if bus and bus.has_method("emit_named"):
			bus.call("emit_named", &"show_warning", [pickup_message, 3.0])
	queue_free()
