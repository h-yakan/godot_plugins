@tool
class_name ClydeDialogueHost
extends Control

## Game-agnostic Clyde dialogue host with dice, persistence, and pluggable UI.

signal dialogue_started(file_path: String, block_name: String)
signal dialogue_ended()
signal line_presented(speaker: String, text: String, content: Dictionary)
signal options_presented(title: String, options: Array)
signal choice_made(choice_index: int, choice_text: String)
signal trigger_received(event_name: String, args: Array)
signal variable_changed(name: String, value: Variant, previous_value: Variant)
signal dice_rolled(result: Dictionary)
signal event_changed(key: String, value: Variant, previous: Variant)
signal stat_changed(stat_name: String, value: int, previous: int)
signal persistence_saved()
signal persistence_loaded()

@export_group("Playback")
@export var auto_drain_lines: bool = true
@export var max_lines_per_frame: int = 12
@export var strict_triggers: bool = false
@export var show_ui_on_start: bool = true
@export var hide_ui_on_end: bool = true
@export var presenter_path: NodePath = ^"RichTextDialoguePresenter"

@export_group("Dice")
@export var enable_dice: bool = true
@export var show_roll_results: bool = true
@export var roll_system_speaker: String = "System"
@export var dice_count: int = 2
@export var dice_sides: int = 6

@export_group("Persistence")
@export var enable_persistence: bool = true
@export var auto_save_persistence: bool = true
@export var save_on_dialogue_end: bool = true
@export var sync_persistence_on_start: bool = true
@export var events_save_path: String = "user://clyde_dialogue_events.json"
@export var stats_save_path: String = "user://clyde_dialogue_stats.json"
@export var modifiers_save_path: String = "user://clyde_dialogue_modifiers.json"
@export var default_stats_path: String = ""
@export var default_modifiers_path: String = ""

var clyde_dialogue: ClydeDialogue
var persistence: DialoguePersistence
var dice_roller: DialogueDiceRoller

var is_dialogue_active: bool = false
var current_dialogue_file: String = ""
var current_block: String = ""

var _trigger_router := ClydeTriggerRouter.new()
var _presenter: DialoguePresenter
var _waiting_for_choice: bool = false
var _stat_provider := Callable()
var _modifier_provider := Callable()
var _save_scheduled: bool = false


## Backward-compatible accessors for persistence stores.
var events: DialogueEventStore:
	get: return persistence.events if persistence else null

var stats: DialogueStatStore:
	get: return persistence.stats if persistence else null

var modifiers: DialogueModifierStore:
	get: return persistence.modifiers if persistence else null


func _ready() -> void:
	_initialize_persistence()
	_initialize_clyde()
	_initialize_dice()
	_bind_presenter()
	_register_builtin_triggers()
	if enable_persistence:
		load_persistence()


func _exit_tree() -> void:
	if enable_persistence and persistence and persistence.is_dirty():
		save_persistence()


func _initialize_persistence() -> void:
	persistence = DialoguePersistence.new()
	persistence.configure({
		"events_path": events_save_path,
		"stats_path": stats_save_path,
		"modifiers_path": modifiers_save_path,
		"default_stats_path": default_stats_path,
		"default_modifiers_path": default_modifiers_path,
		"auto_save": false,
	})
	persistence.event_changed.connect(_on_persistence_event_changed)
	persistence.stat_changed.connect(_on_persistence_stat_changed)
	persistence.saved.connect(func(): persistence_saved.emit())
	persistence.loaded.connect(func(): persistence_loaded.emit())


func _initialize_clyde() -> void:
	clyde_dialogue = ClydeDialogue.new()
	clyde_dialogue.event_triggered.connect(_on_clyde_event)
	clyde_dialogue.variable_changed.connect(_on_clyde_variable_changed)
	clyde_dialogue.on_external_variable_fetch(_fetch_external_variable)
	clyde_dialogue.on_external_variable_update(_update_external_variable)


func _initialize_dice() -> void:
	dice_roller = DialogueDiceRoller.new()


func _bind_presenter() -> void:
	if presenter_path.is_empty():
		return
	var node := get_node_or_null(presenter_path)
	if node is DialoguePresenter:
		_presenter = node
		_presenter.setup(self)
		if not _presenter.option_selected.is_connected(_on_presenter_option_selected):
			_presenter.option_selected.connect(_on_presenter_option_selected)


func _register_builtin_triggers() -> void:
	register_trigger(DialogueConstants.TRIGGER_END_DIALOGUE, _builtin_end_dialogue)
	if enable_dice:
		register_trigger(DialogueConstants.TRIGGER_ROLL_DICE, _builtin_roll_dice)
	if enable_persistence:
		register_trigger(DialogueConstants.TRIGGER_SET_EVENT, _builtin_set_event)
		register_trigger(DialogueConstants.TRIGGER_RECORD_EVENT, _builtin_record_event)
		register_trigger(DialogueConstants.TRIGGER_CLEAR_EVENT, _builtin_clear_event)
		register_trigger(DialogueConstants.TRIGGER_SET_STAT, _builtin_set_stat)
		register_trigger(DialogueConstants.TRIGGER_SHOW_STATS, _builtin_show_stats)
		register_trigger(DialogueConstants.TRIGGER_ADD_MODIFIER, _builtin_add_modifier)
		register_trigger(DialogueConstants.TRIGGER_SAVE_STATE, _builtin_save_state)
		register_trigger(DialogueConstants.TRIGGER_LOAD_STATE, _builtin_load_state)


func set_stat_provider(provider: Callable) -> void:
	_stat_provider = provider


func set_modifier_provider(provider: Callable) -> void:
	_modifier_provider = provider


func register_trigger(event_name: String, handler: Callable) -> void:
	_trigger_router.register_trigger(event_name, handler)


func unregister_trigger(event_name: String) -> void:
	_trigger_router.unregister_trigger(event_name)


func load_persistence() -> void:
	if not enable_persistence or not persistence:
		return
	persistence.load_all()
	if sync_persistence_on_start:
		persistence.sync_to_clyde(clyde_dialogue)


func save_persistence() -> void:
	if not enable_persistence or not persistence:
		return
	persistence.save_all()


func schedule_persistence_save() -> void:
	if not enable_persistence or not auto_save_persistence or _save_scheduled:
		return
	_save_scheduled = true
	call_deferred("_flush_persistence_save")


func get_event(key: String, default: Variant = null) -> Variant:
	return persistence.events.get_value(key, default) if persistence else default


func set_event(key: String, value: Variant) -> void:
	if not persistence:
		return
	persistence.events.set_value(key, value, false)
	if clyde_dialogue:
		clyde_dialogue.set_variable(key, value)
	schedule_persistence_save()


func record_event(key: String) -> void:
	set_event(key, true)


func clear_event(key: String) -> void:
	if not persistence:
		return
	persistence.events.clear(key)
	if clyde_dialogue:
		clyde_dialogue.set_variable(key, false)
	schedule_persistence_save()


func get_stat(stat_name: String, default: int = 0) -> int:
	return persistence.stats.get_stat(stat_name, default) if persistence else default


func set_stat(stat_name: String, value: int) -> void:
	if not persistence:
		return
	persistence.stats.set_stat(stat_name, value, false)
	if clyde_dialogue:
		clyde_dialogue.set_variable(stat_name, value)
		clyde_dialogue.set_variable("%s_stat" % stat_name, value)
	schedule_persistence_save()


func roll_dice(stat_type: String = "", roll_id: String = "", tags: Array = []) -> Dictionary:
	if not dice_roller:
		return {}

	var result := dice_roller.roll(
		stat_type,
		roll_id,
		tags,
		persistence.stats if persistence else null,
		persistence.modifiers if persistence else null,
		_stat_provider,
		_modifier_provider,
		dice_count,
		dice_sides
	)
	dice_roller.apply_to_clyde(clyde_dialogue, result)
	dice_rolled.emit(result)

	if show_roll_results and _presenter:
		_presenter.show_line(roll_system_speaker, dice_roller.format_result_message(result))

	return result


func start_dialogue(file_path: String, block_name: String = DialogueConstants.DEFAULT_BLOCK) -> void:
	_begin_dialogue(file_path, block_name, func():
		clyde_dialogue.load_dialogue(file_path, block_name)
	)


func start_from_resource(resource: ClydeDialogueFile, block_name: String = DialogueConstants.DEFAULT_BLOCK) -> void:
	var path := resource.resource_path if resource else ""
	_begin_dialogue(path, block_name, func():
		clyde_dialogue.load_resource(resource, block_name)
	)


func end_dialogue() -> void:
	if not is_dialogue_active:
		return

	is_dialogue_active = false
	_waiting_for_choice = false
	_set_presenter_batch_mode(false)

	if _presenter:
		_presenter.clear()
		if hide_ui_on_end:
			_presenter.set_dialogue_visible(false)

	if save_on_dialogue_end and enable_persistence and persistence.is_dirty():
		save_persistence()

	dialogue_ended.emit()


func choose(option_index: int) -> void:
	if not clyde_dialogue or not is_dialogue_active:
		return

	clyde_dialogue.choose(option_index)
	_waiting_for_choice = false
	_continue_processing()


func advance() -> void:
	if not clyde_dialogue or not is_dialogue_active:
		return
	_apply_content(clyde_dialogue.get_content())


func set_variable(name: String, value: Variant) -> void:
	if clyde_dialogue:
		clyde_dialogue.set_variable(name, value)


func get_variable(name: String, default: Variant = null) -> Variant:
	if not clyde_dialogue:
		return default
	var value := clyde_dialogue.get_variable(name)
	return default if value == null else value


func get_data() -> Dictionary:
	return clyde_dialogue.get_data() if clyde_dialogue else {}


func load_data(data: Dictionary) -> void:
	if clyde_dialogue:
		clyde_dialogue.load_data(data)


func clear_data() -> void:
	if clyde_dialogue:
		clyde_dialogue.clear_data()


func configure_clyde(options: Dictionary) -> void:
	if clyde_dialogue:
		clyde_dialogue.configure(options)


func get_dialogue_state() -> Dictionary:
	return {
		"is_active": is_dialogue_active,
		"file": current_dialogue_file,
		"block": current_block,
		"waiting_for_choice": _waiting_for_choice,
		"has_clyde": clyde_dialogue != null,
		"has_presenter": _presenter != null,
		"persistence_dirty": persistence.is_dirty() if persistence else false,
		"events": persistence.events.get_all() if persistence else {},
		"stats": persistence.stats.get_all() if persistence else {},
	}


func _begin_dialogue(file_path: String, block_name: String, load_callable: Callable) -> void:
	if not clyde_dialogue:
		push_error("ClydeDialogueHost: Clyde is not initialized")
		return

	if sync_persistence_on_start and persistence:
		persistence.sync_to_clyde(clyde_dialogue)

	current_dialogue_file = file_path
	current_block = block_name
	is_dialogue_active = true
	_waiting_for_choice = false

	if _presenter:
		_presenter.clear()
		if show_ui_on_start:
			_presenter.set_dialogue_visible(true)

	load_callable.call()
	clyde_dialogue.start(block_name)
	dialogue_started.emit(file_path, block_name)
	_continue_processing()


func _continue_processing() -> void:
	if auto_drain_lines:
		_process_until_pause()
	else:
		advance()


func _process_until_pause() -> void:
	if not clyde_dialogue or not is_dialogue_active:
		return

	_set_presenter_batch_mode(true)
	var lines_this_frame := 0

	while is_dialogue_active and not _waiting_for_choice:
		var content := clyde_dialogue.get_content()
		if not _apply_content(content):
			_set_presenter_batch_mode(false)
			return

		if max_lines_per_frame > 0:
			lines_this_frame += 1
			if lines_this_frame >= max_lines_per_frame:
				call_deferred("_process_until_pause")
				return

	_set_presenter_batch_mode(false)


func _apply_content(content: Variant) -> bool:
	if content == null:
		end_dialogue()
		return false

	if typeof(content) != TYPE_DICTIONARY:
		return true

	var content_type := str(content.get("type", ""))
	match content_type:
		ClydeDialogue.CONTENT_TYPE_LINE:
			_handle_line(content)
		ClydeDialogue.CONTENT_TYPE_OPTIONS:
			_handle_options(content)
			return false
		ClydeDialogue.CONTENT_TYPE_END:
			end_dialogue()
			return false

	return true


func _handle_line(content: Dictionary) -> void:
	var speaker := str(content.get("speaker", ""))
	var text := str(content.get("text", ""))
	line_presented.emit(speaker, text, content)
	if _presenter:
		_presenter.show_line(speaker, text)


func _handle_options(content: Dictionary) -> void:
	var title := str(content.get("text", ""))
	var options: Array = content.get("options", [])
	_waiting_for_choice = true
	options_presented.emit(title, options)
	if _presenter:
		_presenter.show_options(title, options)


func _on_presenter_option_selected(index: int, text: String) -> void:
	if not is_dialogue_active or not _waiting_for_choice:
		return

	clyde_dialogue.choose(index)
	choice_made.emit(index, text)
	_waiting_for_choice = false
	_continue_processing()


func _on_clyde_event(event_name: String, args: Array) -> void:
	trigger_received.emit(event_name, args)
	if not _trigger_router.dispatch(event_name, args) and strict_triggers:
		push_warning("ClydeDialogueHost: unhandled trigger '%s' args=%s" % [event_name, args])


func _on_clyde_variable_changed(name: String, value: Variant, previous_value: Variant) -> void:
	variable_changed.emit(name, value, previous_value)


func _on_persistence_event_changed(key: String, value: Variant, previous: Variant) -> void:
	event_changed.emit(key, value, previous)


func _on_persistence_stat_changed(stat_name: String, value: int, previous: int) -> void:
	stat_changed.emit(stat_name, value, previous)


func _fetch_external_variable(variable_name: String) -> Variant:
	return persistence.fetch_variable(variable_name) if persistence else null


func _update_external_variable(variable_name: String, value: Variant) -> void:
	if not persistence:
		return
	persistence.update_variable(variable_name, value)
	if clyde_dialogue:
		clyde_dialogue.set_variable(variable_name, value)
		if persistence.stats.has_stat(variable_name):
			clyde_dialogue.set_variable("%s_stat" % variable_name, int(value))
	schedule_persistence_save()


func _flush_persistence_save() -> void:
	_save_scheduled = false
	save_persistence()


func _set_presenter_batch_mode(enabled: bool) -> void:
	if _presenter is RichTextDialoguePresenter:
		(_presenter as RichTextDialoguePresenter).set_batch_mode(enabled)


func _builtin_end_dialogue(_args: Array) -> void:
	end_dialogue()


func _builtin_roll_dice(args: Array) -> void:
	if args.is_empty():
		push_warning("ClydeDialogueHost: roll_dice requires stat_type")
		return

	var parsed := DialogueUtils.parse_roll_dice_args(args)
	roll_dice(
		str(parsed.get("stat_type", "")),
		str(parsed.get("roll_id", "")),
		parsed.get("tags", [])
	)


func _builtin_set_event(args: Array) -> void:
	if args.size() < 2:
		push_warning("ClydeDialogueHost: set_event requires key and value")
		return
	set_event(str(args[0]), args[1])


func _builtin_record_event(args: Array) -> void:
	if args.is_empty():
		push_warning("ClydeDialogueHost: record_event requires key")
		return
	record_event(str(args[0]))


func _builtin_clear_event(args: Array) -> void:
	if args.is_empty():
		push_warning("ClydeDialogueHost: clear_event requires key")
		return
	clear_event(str(args[0]))


func _builtin_set_stat(args: Array) -> void:
	if args.size() < 2:
		push_warning("ClydeDialogueHost: set_stat requires stat_name and value")
		return
	set_stat(str(args[0]), int(args[1]))


func _builtin_show_stats(_args: Array) -> void:
	if not persistence:
		return

	var lines: PackedStringArray = []
	for stat_name in persistence.stats.get_all():
		lines.append("%s: %d" % [stat_name, persistence.stats.get_stat(stat_name)])

	if _presenter:
		_presenter.show_line(roll_system_speaker, "Stats:\n" + "\n".join(lines))


func _builtin_add_modifier(args: Array) -> void:
	if args.size() < 2 or not persistence:
		push_warning("ClydeDialogueHost: add_modifier requires id and value")
		return

	var id := str(args[0])
	var value := int(args[1])
	var description := str(args[2]) if args.size() > 2 else ""
	var active := bool(args[3]) if args.size() > 3 else true
	persistence.modifiers.add_or_update(id, [id], value, description, active)
	schedule_persistence_save()


func _builtin_save_state(_args: Array) -> void:
	save_persistence()


func _builtin_load_state(_args: Array) -> void:
	load_persistence()
