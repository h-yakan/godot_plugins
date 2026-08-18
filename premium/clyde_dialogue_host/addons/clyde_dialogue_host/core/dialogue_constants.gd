class_name DialogueConstants
extends RefCounted

## Shared names for Clyde variables and built-in trigger ids.

const TRIGGER_END_DIALOGUE := "end_dialogue"
const TRIGGER_ROLL_DICE := "roll_dice"
const TRIGGER_SET_EVENT := "set_event"
const TRIGGER_RECORD_EVENT := "record_event"
const TRIGGER_CLEAR_EVENT := "clear_event"
const TRIGGER_SET_STAT := "set_stat"
const TRIGGER_SHOW_STATS := "show_stats"
const TRIGGER_ADD_MODIFIER := "add_modifier"
const TRIGGER_SAVE_STATE := "save_state"
const TRIGGER_LOAD_STATE := "load_state"

const VAR_DIE1 := "die1"
const VAR_DIE2 := "die2"
const VAR_ROLL_BASE := "roll_base"
const VAR_MOD_SUM := "mod_sum"
const VAR_STAT_BONUS := "stat_bonus"
const VAR_ROLL_FINAL := "roll_final"
const VAR_DICE_ID := "dice_id"
const VAR_STAT_TYPE := "stat_type"

const DEFAULT_BLOCK := "START"

const NULLISH_STRINGS: Array[String] = ["", "null", "None", "<null>"]
