extends Resource
class_name GaSkillDefinition

## Data-only skill descriptor. Supports LoL-style active, passive, toggle, and aura skills.

@export_group("Identity")
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var slot_category: StringName = &"basic"
@export var input_action: StringName = &""
@export var tags: PackedStringArray = PackedStringArray()
@export var scene: PackedScene
@export var enabled: bool = true
@export var show_in_skill_bar: bool = true

@export_group("Archetype")
@export var kind: GaSkillKinds.Kind = GaSkillKinds.Kind.ACTIVE
@export var cooldown_mode: GaSkillKinds.CooldownMode = GaSkillKinds.CooldownMode.TIMED
@export var cost_mode: GaSkillKinds.CostMode = GaSkillKinds.CostMode.NONE
@export var cooldown_trigger: GaSkillKinds.CooldownTrigger = GaSkillKinds.CooldownTrigger.ON_ACTIVATE
@export var tick_while_active: bool = false

@export_group("Cooldown")
@export var cooldown: float = 1.0

@export_group("Cost")
@export var resource_id: StringName = &"mana"
@export var resource_cost: float = 0.0
@export var pay_cost_on_toggle_off: bool = false


func get_id() -> String:
	if not id.is_empty():
		return id
	return resource_path.get_file().get_basename()


func has_cooldown() -> bool:
	return cooldown_mode == GaSkillKinds.CooldownMode.TIMED and cooldown > 0.0


func has_cost() -> bool:
	return cost_mode == GaSkillKinds.CostMode.RESOURCE and resource_cost > 0.0


func is_castable() -> bool:
	return GaSkillKinds.kind_is_castable(kind)


func should_auto_start() -> bool:
	return GaSkillKinds.kind_auto_starts(kind)


func get_tooltip() -> String:
	var lines: PackedStringArray = PackedStringArray()
	if not description.is_empty():
		lines.append(description)
	elif not display_name.is_empty():
		lines.append(display_name)
	lines.append(_kind_label())
	if has_cost():
		lines.append("Cost: %.0f %s" % [resource_cost, resource_id])
	if has_cooldown():
		lines.append("Cooldown: %.1fs" % cooldown)
	elif cooldown_mode == GaSkillKinds.CooldownMode.NONE:
		lines.append("Cooldown: None")
	return "\n".join(lines)


func _kind_label() -> String:
	match kind:
		GaSkillKinds.Kind.PASSIVE:
			return "[Passive]"
		GaSkillKinds.Kind.TOGGLE:
			return "[Toggle]"
		GaSkillKinds.Kind.ALWAYS_ACTIVE:
			return "[Always Active]"
		_:
			return "[Active]"
