extends Area3D
class_name GaPlacementArea

const _EventBus := preload("res://addons/3d_item_placement_slots/core/ga_event_bus_client.gd")

@export var area_id: String
@export var allowed_item_names: Array[String]
@export var place_node_path: NodePath = ^"Place"
@export var animation_player_path: NodePath = ^"PlacementAnimation"
@export var collision_shape_path: NodePath = ^"CollisionShape3D"
@export var collision_layer_index: int = 4

var placed_items: Array = []
signal placement_updated

@onready var item_place: Node3D = get_node_or_null(place_node_path)
@onready var item_placement_anim: AnimationPlayer = get_node_or_null(animation_player_path)

func _ready() -> void:
	add_to_group("ItemSlots")

func place_item() -> void:
	if not GaInventoryManager:
		return
	var equipped_item: GaItemData = GaInventoryManager.equipped_item
	if not equipped_item:
		return
	if not allowed_item_names.is_empty() and not allowed_item_names.has(equipped_item.item_name):
		_EventBus.emit(self, &"show_warning", ["Item cannot be placed here", 4.0])
		return
	GaInventoryManager.free_hand_item()
	if equipped_item.inspection_scene.is_empty():
		return
	var item_resource = load(equipped_item.inspection_scene)
	var item = item_resource.instantiate()
	if item_place:
		item_place.add_child(item)
	if item_placement_anim and item_placement_anim.has_animation("placement"):
		item_placement_anim.play("placement")
	if item.get("item_data"):
		placed_items.append(item.item_data.item_name)
		GaInventoryManager.placed_items[item.item_data] = area_id
	set_collision_layer_value(collision_layer_index, false)
	var col: CollisionShape3D = get_node_or_null(collision_shape_path)
	if col:
		col.set_deferred("disabled", true)
	placement_updated.emit()

func spawn_placed_item(item_data: GaItemData) -> void:
	if not item_data or item_data.inspection_scene.is_empty():
		return
	var item_resource = load(item_data.inspection_scene)
	var item = item_resource.instantiate()
	if item_place:
		item_place.add_child(item)
	if item_placement_anim and item_placement_anim.has_animation("placement"):
		item_placement_anim.play("placement")
	if item.get("item_data"):
		placed_items.append(item.item_data.item_name)
	set_collision_layer_value(collision_layer_index, false)
	var col: CollisionShape3D = get_node_or_null(collision_shape_path)
	if col:
		col.set_deferred("disabled", true)
	placement_updated.emit()
