class_name DialogueDiceRoller
extends RefCounted

## Rolls dice, applies stat and modifier bonuses, returns a result dictionary.
func roll(
	stat_type: String = "",
	roll_id: String = "",
	tags: Array = [],
	stat_store: DialogueStatStore = null,
	modifier_store: DialogueModifierStore = null,
	stat_provider: Callable = Callable(),
	modifier_provider: Callable = Callable(),
	dice_count: int = 2,
	dice_sides: int = 6
) -> Dictionary:
	var dice := _roll_dice(dice_count, dice_sides)
	var die_values: Array = dice["values"]
	var base_total: int = dice["total"]

	var description := ""
	if roll_id != "" and modifier_store:
		var modifier := modifier_store.get_by_id(roll_id)
		if not modifier.is_empty():
			description = str(modifier.get("description", ""))

	var roll_tags: Array = tags.duplicate()
	if roll_id != "" and roll_id not in roll_tags:
		roll_tags.append(roll_id)

	var mod_sum := _sum_modifiers(roll_id, roll_tags, modifier_store, modifier_provider)
	var stat_bonus := _get_stat_bonus(stat_type, stat_store, stat_provider)
	var final_total := base_total + mod_sum + stat_bonus

	return {
		"roll_id": roll_id,
		"stat_type": stat_type,
		"tags": roll_tags,
		"die1": die_values[0] if die_values.size() > 0 else 0,
		"die2": die_values[1] if die_values.size() > 1 else 0,
		"dice_values": die_values,
		"base": base_total,
		"mod_sum": mod_sum,
		"stat_bonus": stat_bonus,
		"final": final_total,
		"description": description,
	}


func apply_to_clyde(clyde: ClydeDialogue, result: Dictionary) -> void:
	if not clyde:
		return

	clyde.set_variable(DialogueConstants.VAR_DIE1, result.get("die1", 0))
	clyde.set_variable(DialogueConstants.VAR_DIE2, result.get("die2", 0))
	clyde.set_variable(DialogueConstants.VAR_ROLL_BASE, result.get("base", 0))
	clyde.set_variable(DialogueConstants.VAR_MOD_SUM, result.get("mod_sum", 0))
	clyde.set_variable(DialogueConstants.VAR_STAT_BONUS, result.get("stat_bonus", 0))
	clyde.set_variable(DialogueConstants.VAR_ROLL_FINAL, result.get("final", 0))
	clyde.set_variable(DialogueConstants.VAR_DICE_ID, result.get("roll_id", ""))
	clyde.set_variable(DialogueConstants.VAR_STAT_TYPE, result.get("stat_type", ""))


func format_result_message(result: Dictionary) -> String:
	var stat_type := str(result.get("stat_type", ""))
	var description := str(result.get("description", ""))
	var modifier_note := description if description != "" else "-"
	return "Roll (%s): %d + %d (dice) + %d (stat) + %d (mods: %s) = %d" % [
		stat_type,
		result.get("die1", 0),
		result.get("die2", 0),
		result.get("stat_bonus", 0),
		result.get("mod_sum", 0),
		modifier_note,
		result.get("final", 0),
	]


func _sum_modifiers(
	roll_id: String,
	tags: Array,
	modifier_store: DialogueModifierStore,
	modifier_provider: Callable
) -> int:
	var total := 0
	for tag in tags:
		var tag_name := str(tag)
		if modifier_provider.is_valid():
			total += int(modifier_provider.call(roll_id, tag_name))
		elif modifier_store:
			total += modifier_store.sum_for(roll_id, tag_name)
	return total


func _get_stat_bonus(
	stat_type: String,
	stat_store: DialogueStatStore,
	stat_provider: Callable
) -> int:
	if stat_type == "":
		return 0
	if stat_provider.is_valid():
		return int(stat_provider.call(stat_type))
	if stat_store:
		return stat_store.get_stat(stat_type)
	return 0


func _roll_dice(count: int, sides: int) -> Dictionary:
	var values: Array[int] = []
	var total := 0
	var roll_count := maxi(count, 1)
	var roll_sides := maxi(sides, 1)
	for _i in range(roll_count):
		var value := randi_range(1, roll_sides)
		values.append(value)
		total += value
	return {"values": values, "total": total}
