extends Node3D

const _EventBusClient := preload("res://addons/any_game_event_bus/core/ga_event_bus_client.gd")

@export var player_path: NodePath = ^"GaHorrorPlayer"
@export var hint_label_path: NodePath = ^"HUD/Hint"
@export var warning_label_path: NodePath = ^"HUD/Warning"
@export var equipped_label_path: NodePath = ^"HUD/Equipped"
@export var tape_slot_path: NodePath = ^"LivingRoom/TapeSlot"
@export var tv_viewport_path: NodePath = ^"LivingRoom/TV"

var _warning_left: float = 0.0

func _ready() -> void:
	_ensure_input_map()
	_EventBusClient.listen(self, &"show_warning", _on_show_warning)
	var slot := get_node_or_null(tape_slot_path)
	if slot and slot.has_signal("placement_updated"):
		slot.placement_updated.connect(_on_tape_placed)

func _process(delta: float) -> void:
	if _warning_left > 0.0:
		_warning_left -= delta
		if _warning_left <= 0.0:
			_set_label(warning_label_path, "")
	_update_hint()
	_update_equipped()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"equip_slot_1"):
		var inv := get_tree().root.get_node_or_null("GaInventoryManager")
		if inv and inv.has_method("equip_item"):
			inv.call("equip_item", 0)
		get_viewport().set_input_as_handled()

func _on_show_warning(content: String = "", duration: float = 3.0) -> void:
	_set_label(warning_label_path, content)
	_warning_left = duration

func _on_tape_placed() -> void:
	_on_show_warning("The deck takes the tape. The TV finds a signal.", 4.0)
	var tv := get_node_or_null(tv_viewport_path)
	if tv == null:
		return
	for child in tv.get_children():
		if child.has_method("set_broadcast"):
			child.set_broadcast("CHANNEL 03", "DON'T COVER YOUR EARS.\nDON'T LOOK AWAY.")

func _update_hint() -> void:
	var player := get_node_or_null(player_path)
	if player == null:
		return
	var ray := player.get_node_or_null("Head/Eyes/Camera3D/RayCast3D")
	if ray == null or not ray.has_method("get_interaction_hints"):
		return
	var hints: Dictionary = ray.get_interaction_hints()
	var parts: PackedStringArray = []
	if hints.get("grab", false):
		parts.append("LMB grab / RMB throw")
	elif hints.get("interact", false):
		parts.append("LMB interact")
	if hints.get("place", false):
		parts.append("RMB place equipped item")
	_set_label(hint_label_path, "  ·  ".join(parts))

func _update_equipped() -> void:
	var inv := get_tree().root.get_node_or_null("GaInventoryManager")
	if inv == null:
		return
	var equipped = inv.get("equipped_item")
	if equipped:
		_set_label(equipped_label_path, "Equipped: %s  (1 to toggle)" % str(equipped.item_name))
	elif inv.get("inventory") and inv.inventory.size() > 0:
		_set_label(equipped_label_path, "Pocket: %s  (press 1 to equip)" % str(inv.inventory[0].item_name))
	else:
		_set_label(equipped_label_path, "")

func _set_label(path: NodePath, text: String) -> void:
	var label := get_node_or_null(path) as Label
	if label:
		label.text = text

func _ensure_input_map() -> void:
	_bind(&"forward", KEY_W)
	_bind(&"backward", KEY_S)
	_bind(&"left", KEY_A)
	_bind(&"right", KEY_D)
	_bind(&"jump", KEY_SPACE)
	_bind(&"sprint", KEY_SHIFT)
	_bind(&"crouch", KEY_CTRL)
	_bind(&"pause", KEY_ESCAPE)
	_bind(&"blinkclose", KEY_C)
	_bind(&"blinkopen", KEY_V)
	_bind(&"left_ear", KEY_Q)
	_bind(&"right_ear", KEY_E)
	_bind(&"equip_slot_1", KEY_1)
	_bind_mouse(&"interact", MOUSE_BUTTON_LEFT)
	_bind_mouse(&"secondary_interact", MOUSE_BUTTON_RIGHT)

func _bind(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	if not _has_event(action, ev):
		InputMap.action_add_event(action, ev)

func _bind_mouse(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	if not _has_event(action, ev):
		InputMap.action_add_event(action, ev)

func _has_event(action: StringName, ev: InputEvent) -> bool:
	for existing in InputMap.action_get_events(action):
		if existing.is_match(ev, true):
			return true
	return false
