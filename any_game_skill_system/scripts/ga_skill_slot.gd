extends TextureButton
class_name GaSkillSlot

## Presentation-only skill slot. Supports active, toggle, and passive display states.

@export var skill_id: String = ""
@export var input_action: StringName = &""
@export var toggle_on_modulate: Color = Color(0.85, 1.0, 0.6, 1.0)
@export var passive_modulate: Color = Color(0.75, 0.75, 0.85, 1.0)

@onready var _cooldown: TextureProgressBar = $Cooldown
@onready var _key: Label = $Key
@onready var _time: Label = $Time
@onready var _popup: GaSkillTooltip = $PopupPanel
@onready var _tooltip: RichTextLabel = $PopupPanel/Tooltip

var skill: GaSkill = null

var _controller: GaSkillController = null
var _cooldown_active: bool = false


func _ready() -> void:
	await get_parent().ready
	_refresh_from_skill()


func bind_to_controller(controller: GaSkillController, bound_skill: GaSkill = null) -> void:
	_disconnect_skill()
	_controller = controller
	skill = bound_skill
	if skill == null and _controller and not skill_id.is_empty():
		skill = _controller.get_skill(skill_id)
	if is_node_ready():
		_refresh_from_skill()
	_connect_skill()


func set_skill(new_skill: GaSkill) -> void:
	skill = new_skill
	if skill:
		skill_id = skill.get_id()
	if is_node_ready():
		_refresh_from_skill()


func _refresh_from_skill() -> void:
	_disconnect_skill()
	if skill == null:
		disabled = true
		texture_normal = null
		_tooltip.text = ""
		modulate = Color.WHITE
		return

	if skill.definition and not skill.definition.show_in_skill_bar:
		visible = false
		return
	visible = true

	texture_normal = skill.get_icon()
	_cooldown.max_value = maxf(skill.get_cooldown(), 0.001)
	_time.text = str(skill.get_cooldown())
	_tooltip.text = skill.get_tooltip()
	_popup.position = DisplayServer.mouse_get_position()
	_bind_hotkey_label()
	_connect_skill()
	_sync_interaction_state()
	_sync_cooldown_ui(skill.get_cooldown_remaining(), skill.is_on_cooldown())
	_sync_archetype_visual()


func _sync_interaction_state() -> void:
	if skill == null:
		disabled = true
		return
	if not skill.is_castable():
		disabled = true
		return
	disabled = skill.is_on_cooldown() or not skill.can_activate()


func _sync_archetype_visual() -> void:
	if skill == null:
		modulate = Color.WHITE
		return
	match skill.get_kind():
		GaSkillKinds.Kind.PASSIVE:
			modulate = passive_modulate
		GaSkillKinds.Kind.TOGGLE:
			modulate = toggle_on_modulate if skill.is_toggled_on() else Color.WHITE
		GaSkillKinds.Kind.ALWAYS_ACTIVE:
			modulate = toggle_on_modulate
		_:
			modulate = Color.WHITE


func _connect_skill() -> void:
	if skill == null:
		return
	if not skill.cooldown_started.is_connected(_on_skill_cooldown_started):
		skill.cooldown_started.connect(_on_skill_cooldown_started)
	if not skill.cooldown_updated.is_connected(_on_skill_cooldown_updated):
		skill.cooldown_updated.connect(_on_skill_cooldown_updated)
	if not skill.cooldown_finished.is_connected(_on_skill_cooldown_finished):
		skill.cooldown_finished.connect(_on_skill_cooldown_finished)
	if not skill.state_changed.is_connected(_on_skill_state_changed):
		skill.state_changed.connect(_on_skill_state_changed)
	if not skill.toggled_on.is_connected(_on_skill_toggled):
		skill.toggled_on.connect(_on_skill_toggled)
	if not skill.toggled_off.is_connected(_on_skill_toggled):
		skill.toggled_off.connect(_on_skill_toggled)


func _disconnect_skill() -> void:
	if skill == null:
		return
	if skill.cooldown_started.is_connected(_on_skill_cooldown_started):
		skill.cooldown_started.disconnect(_on_skill_cooldown_started)
	if skill.cooldown_updated.is_connected(_on_skill_cooldown_updated):
		skill.cooldown_updated.disconnect(_on_skill_cooldown_updated)
	if skill.cooldown_finished.is_connected(_on_skill_cooldown_finished):
		skill.cooldown_finished.disconnect(_on_skill_cooldown_finished)
	if skill.state_changed.is_connected(_on_skill_state_changed):
		skill.state_changed.disconnect(_on_skill_state_changed)
	if skill.toggled_on.is_connected(_on_skill_toggled):
		skill.toggled_on.disconnect(_on_skill_toggled)
	if skill.toggled_off.is_connected(_on_skill_toggled):
		skill.toggled_off.disconnect(_on_skill_toggled)


func _bind_hotkey_label() -> void:
	var action := _get_input_action()
	if action.is_empty() or not skill.is_castable():
		_key.text = ""
		return
	if not InputMap.has_action(action):
		_key.text = ""
		return
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key_text: String = event.as_text()
			if not key_text.is_empty():
				_key.text = key_text[0]
			return


func _get_input_action() -> StringName:
	if not input_action.is_empty():
		return input_action
	if skill and not skill.get_input_action().is_empty():
		return skill.get_input_action()
	return &""


func _process(_delta: float) -> void:
	if _cooldown_active or skill == null or not skill.is_castable():
		return
	if disabled:
		return
	var action := _get_input_action()
	if action.is_empty():
		return
	if Input.is_action_just_pressed(action):
		_request_activation()


func _request_activation() -> void:
	if _controller == null or skill == null or not skill.is_castable():
		return
	_controller.request_activation_for_skill(skill)


func _on_pressed() -> void:
	_request_activation()


func _on_skill_cooldown_started(duration: float) -> void:
	_sync_cooldown_ui(duration, true)


func _on_skill_cooldown_updated(remaining: float) -> void:
	_sync_cooldown_ui(remaining, true)


func _on_skill_cooldown_finished() -> void:
	_sync_cooldown_ui(0.0, false)
	_sync_interaction_state()


func _on_skill_state_changed(_old_state: GaSkill.RuntimeState, _new_state: GaSkill.RuntimeState) -> void:
	_sync_interaction_state()
	_sync_archetype_visual()


func _on_skill_toggled(_context: GaSkillContext = null) -> void:
	_sync_interaction_state()
	_sync_archetype_visual()


func _sync_cooldown_ui(remaining: float, active: bool) -> void:
	_cooldown_active = active
	_time.visible = active and skill != null and skill.get_cooldown() > 0.0
	if active:
		_time.text = "%3.1f" % remaining
		_cooldown.value = remaining
	else:
		_cooldown.value = 0.0
	_sync_interaction_state()


func _on_mouse_entered() -> void:
	if skill:
		_popup.toggle(true)


func _on_mouse_exited() -> void:
	_popup.toggle(false)
