extends Node
class_name GaSkill

## Runtime skill behaviour with LoL-style archetypes: active, passive, toggle, always-active.

enum ActivationResult {
	SUCCESS,
	FAILED,
	ON_COOLDOWN,
	DISABLED,
	NOT_FOUND,
	INSUFFICIENT_COST,
	NOT_CASTABLE,
	ALREADY_TOGGLED,
	NOT_TOGGLED,
}

enum RuntimeState {
	IDLE,
	COOLDOWN,
	TOGGLED_ON,
	PASSIVE_ACTIVE,
	ALWAYS_ACTIVE,
	DISABLED,
}

signal activated(context: GaSkillContext)
signal deactivated(context: GaSkillContext)
signal toggled_on(context: GaSkillContext)
signal toggled_off(context: GaSkillContext)
signal passive_applied(context: GaSkillContext)
signal activation_failed(reason: String)
signal cooldown_started(duration: float)
signal cooldown_updated(remaining: float)
signal cooldown_finished
signal state_changed(old_state: RuntimeState, new_state: RuntimeState)
signal cost_spent(resource_id: StringName, amount: float)
signal cost_insufficient(resource_id: StringName, amount: float)

@export var definition: GaSkillDefinition

var _context: GaSkillContext = GaSkillContext.new()
var _runtime_state: RuntimeState = RuntimeState.IDLE
var _on_cooldown: bool = false
var _cooldown_remaining: float = 0.0
var _toggled_on: bool = false


func _ready() -> void:
	set_process(false)


func setup(context: GaSkillContext) -> void:
	_context = context
	if not is_enabled():
		_set_runtime_state(RuntimeState.DISABLED)


func on_registered(context: GaSkillContext) -> void:
	setup(context)
	if definition == null:
		return
	match definition.kind:
		GaSkillKinds.Kind.PASSIVE:
			_start_passive(context)
		GaSkillKinds.Kind.ALWAYS_ACTIVE:
			_start_always_active(context)


func get_definition() -> GaSkillDefinition:
	return definition


func get_kind() -> GaSkillKinds.Kind:
	return definition.kind if definition else GaSkillKinds.Kind.ACTIVE


func get_id() -> String:
	if definition:
		return definition.get_id()
	return name


func get_display_name() -> String:
	if definition and not definition.display_name.is_empty():
		return definition.display_name
	return get_id()


func get_icon() -> Texture2D:
	return definition.icon if definition else null


func get_cooldown() -> float:
	if definition == null or not definition.has_cooldown():
		return 0.0
	return definition.cooldown


func get_resource_cost() -> float:
	if definition == null or not definition.has_cost():
		return 0.0
	return definition.resource_cost


func get_resource_id() -> StringName:
	return definition.resource_id if definition else &""


func get_tooltip() -> String:
	if definition:
		return definition.get_tooltip()
	return ""


func get_input_action() -> StringName:
	if definition and not definition.input_action.is_empty():
		return definition.input_action
	return &""


func is_enabled() -> bool:
	return definition == null or definition.enabled


func is_castable() -> bool:
	return definition != null and definition.is_castable() and is_enabled()


func is_on_cooldown() -> bool:
	return _on_cooldown


func is_toggled_on() -> bool:
	return _toggled_on


func get_runtime_state() -> RuntimeState:
	return _runtime_state


func get_cooldown_remaining() -> float:
	return _cooldown_remaining


func should_tick() -> bool:
	if definition == null or not definition.tick_while_active:
		return false
	match definition.kind:
		GaSkillKinds.Kind.ALWAYS_ACTIVE:
			return true
		GaSkillKinds.Kind.TOGGLE:
			return _toggled_on
		GaSkillKinds.Kind.PASSIVE:
			return _runtime_state == RuntimeState.PASSIVE_ACTIVE
		_:
			return false


func can_activate() -> bool:
	return _can_cast_or_toggle_on(_context)


func try_activate(context: GaSkillContext = null) -> ActivationResult:
	if context:
		_context = context
	if not is_enabled():
		activation_failed.emit("disabled")
		return ActivationResult.DISABLED
	if definition == null:
		activation_failed.emit("missing_definition")
		return ActivationResult.FAILED

	match definition.kind:
		GaSkillKinds.Kind.PASSIVE, GaSkillKinds.Kind.ALWAYS_ACTIVE:
			activation_failed.emit("not_castable")
			return ActivationResult.NOT_CASTABLE
		GaSkillKinds.Kind.TOGGLE:
			if _toggled_on:
				return _try_toggle_off(_context)
			return _try_cast(_context)
		_:
			return _try_cast(_context)


func try_deactivate(context: GaSkillContext = null) -> ActivationResult:
	if context:
		_context = context
	if definition == null or definition.kind != GaSkillKinds.Kind.TOGGLE:
		return ActivationResult.NOT_CASTABLE
	return _try_toggle_off(_context)


func process_skill(delta: float, context: GaSkillContext = null) -> void:
	if context:
		_context = context
	if not should_tick():
		return
	_process_skill(delta, _context)


func reset_cooldown() -> void:
	_on_cooldown = false
	_cooldown_remaining = 0.0
	if _runtime_state == RuntimeState.COOLDOWN:
		_set_runtime_state(_state_after_cooldown())
	cooldown_finished.emit()


func _try_cast(context: GaSkillContext) -> ActivationResult:
	if _on_cooldown:
		activation_failed.emit("on_cooldown")
		return ActivationResult.ON_COOLDOWN
	if not _check_can_activate(context):
		activation_failed.emit("conditions_not_met")
		return ActivationResult.FAILED
	if not _can_afford_cost(context):
		if definition.has_cost():
			cost_insufficient.emit(definition.resource_id, definition.resource_cost)
		activation_failed.emit("insufficient_cost")
		return ActivationResult.INSUFFICIENT_COST
	if not _do_activate(context):
		activation_failed.emit("activate_returned_false")
		return ActivationResult.FAILED

	_spend_cost(context)
	activated.emit(context)
	_apply_post_activate(context)
	return ActivationResult.SUCCESS


func _try_toggle_off(context: GaSkillContext) -> ActivationResult:
	if not _toggled_on:
		activation_failed.emit("not_toggled")
		return ActivationResult.NOT_TOGGLED
	if definition.pay_cost_on_toggle_off and not _can_afford_cost(context):
		if definition.has_cost():
			cost_insufficient.emit(definition.resource_id, definition.resource_cost)
		activation_failed.emit("insufficient_cost")
		return ActivationResult.INSUFFICIENT_COST
	if not _do_deactivate(context):
		activation_failed.emit("deactivate_returned_false")
		return ActivationResult.FAILED
	if definition.pay_cost_on_toggle_off:
		_spend_cost(context)

	_toggled_on = false
	_set_runtime_state(RuntimeState.IDLE)
	deactivated.emit(context)
	toggled_off.emit(context)
	_maybe_start_cooldown(GaSkillKinds.CooldownTrigger.ON_DEACTIVATE)
	return ActivationResult.SUCCESS


func _start_passive(context: GaSkillContext) -> void:
	if not _apply_passive(context):
		return
	_set_runtime_state(RuntimeState.PASSIVE_ACTIVE)
	passive_applied.emit(context)
	_set_tick_process()


func _start_always_active(context: GaSkillContext) -> void:
	if not _do_activate(context):
		return
	_toggled_on = true
	_set_runtime_state(RuntimeState.ALWAYS_ACTIVE)
	activated.emit(context)
	_set_tick_process()


func _apply_post_activate(context: GaSkillContext) -> void:
	if definition.kind == GaSkillKinds.Kind.TOGGLE:
		_toggled_on = true
		_set_runtime_state(RuntimeState.TOGGLED_ON)
		toggled_on.emit(context)
	else:
		_set_runtime_state(RuntimeState.IDLE)
	_maybe_start_cooldown(definition.cooldown_trigger)
	_set_tick_process()


func _maybe_start_cooldown(trigger: GaSkillKinds.CooldownTrigger) -> void:
	if definition.cooldown_trigger != trigger:
		return
	_start_cooldown()


func _can_cast_or_toggle_on(context: GaSkillContext) -> bool:
	if not is_castable() or _on_cooldown:
		return false
	if not _check_can_activate(context):
		return false
	if definition.kind == GaSkillKinds.Kind.TOGGLE and _toggled_on:
		return _check_can_deactivate(context)
	return _can_afford_cost(context)


func _can_afford_cost(context: GaSkillContext) -> bool:
	if definition == null or not definition.has_cost():
		return true
	var provider := _resolve_cost_provider(context)
	if provider == null:
		return true
	return provider.can_afford(context.caster, definition.resource_id, definition.resource_cost)


func _spend_cost(context: GaSkillContext) -> void:
	if definition == null or not definition.has_cost():
		return
	var provider := _resolve_cost_provider(context)
	if provider == null:
		return
	if provider.spend(context.caster, definition.resource_id, definition.resource_cost):
		cost_spent.emit(definition.resource_id, definition.resource_cost)


func _resolve_cost_provider(context: GaSkillContext) -> GaSkillCostProvider:
	if context.cost_provider:
		return context.cost_provider
	return null


func _start_cooldown() -> void:
	var duration := get_cooldown()
	if duration <= 0.0:
		return
	_on_cooldown = true
	_cooldown_remaining = duration
	_set_runtime_state(RuntimeState.COOLDOWN)
	set_process(true)
	cooldown_started.emit(duration)
	cooldown_updated.emit(_cooldown_remaining)


func _process(delta: float) -> void:
	if _on_cooldown:
		_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)
		cooldown_updated.emit(_cooldown_remaining)
		if _cooldown_remaining <= 0.0:
			_on_cooldown = false
			_set_runtime_state(_state_after_cooldown())
			cooldown_finished.emit()
	if should_tick():
		_process_skill(delta, _context)
	if not _on_cooldown and not should_tick():
		set_process(false)


func _set_tick_process() -> void:
	if should_tick() or _on_cooldown:
		set_process(true)


func _state_after_cooldown() -> RuntimeState:
	match definition.kind if definition else GaSkillKinds.Kind.ACTIVE:
		GaSkillKinds.Kind.TOGGLE:
			return RuntimeState.TOGGLED_ON if _toggled_on else RuntimeState.IDLE
		GaSkillKinds.Kind.PASSIVE:
			return RuntimeState.PASSIVE_ACTIVE
		GaSkillKinds.Kind.ALWAYS_ACTIVE:
			return RuntimeState.ALWAYS_ACTIVE
		_:
			return RuntimeState.IDLE


func _set_runtime_state(new_state: RuntimeState) -> void:
	if _runtime_state == new_state:
		return
	var old_state := _runtime_state
	_runtime_state = new_state
	state_changed.emit(old_state, new_state)


func _check_can_activate(_context: GaSkillContext) -> bool:
	return true


func _check_can_deactivate(_context: GaSkillContext) -> bool:
	return true


func _apply_passive(_context: GaSkillContext) -> bool:
	return _do_activate(_context)


func _do_activate(_context: GaSkillContext) -> bool:
	return true


func _do_deactivate(_context: GaSkillContext) -> bool:
	return true


func _process_skill(_delta: float, _context: GaSkillContext) -> void:
	pass
