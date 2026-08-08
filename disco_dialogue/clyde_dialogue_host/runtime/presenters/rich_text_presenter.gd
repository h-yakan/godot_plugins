class_name RichTextDialoguePresenter
extends DialoguePresenter

## Default presenter: appends lines and clickable BBCode choices to RichTextLabels.

@export var dialogue_label_path: NodePath = ^"../DialogueUI/Panel/VBoxContainer/Dialogue"
@export var choices_label_path: NodePath = ^"../DialogueUI/Panel/VBoxContainer/Choices"
@export var scroll_on_new_line: bool = true
@export var animate_scroll: bool = true
@export var scroll_duration: float = 0.25

var _dialogue_label: RichTextLabel
var _choices_label: RichTextLabel
var _choice_map: Dictionary = {}
var _batch_mode: bool = false
var _scroll_dirty: bool = false
var _scroll_tween: Tween


func setup(host: ClydeDialogueHost) -> void:
	_resolve_labels(host)


func set_batch_mode(enabled: bool) -> void:
	_batch_mode = enabled
	if not enabled and _scroll_dirty:
		_flush_scroll()


func _resolve_labels(_host: ClydeDialogueHost) -> void:
	_dialogue_label = get_node_or_null(dialogue_label_path) as RichTextLabel
	_choices_label = get_node_or_null(choices_label_path) as RichTextLabel

	if _dialogue_label:
		_dialogue_label.bbcode_enabled = true
		_dialogue_label.scroll_active = true

	if _choices_label:
		_choices_label.bbcode_enabled = true
		_choices_label.meta_underlined = true
		if not _choices_label.meta_clicked.is_connected(_on_meta_clicked):
			_choices_label.meta_clicked.connect(_on_meta_clicked)


func set_dialogue_visible(active: bool) -> void:
	var ui := get_parent().get_node_or_null("DialogueUI") as Control
	if ui:
		ui.visible = active
	else:
		super.set_dialogue_visible(active)


func clear() -> void:
	if _dialogue_label:
		_dialogue_label.clear()
	if _choices_label:
		_choices_label.clear()
	_choice_map.clear()
	_scroll_dirty = false
	_kill_scroll_tween()


func show_line(speaker: String, text: String) -> void:
	if not _dialogue_label or DialogueUtils.is_nullish(text):
		return

	var clean_speaker := DialogueUtils.normalize_speaker(speaker)
	var prefix := "[b]%s:[/b] " % clean_speaker if clean_speaker != "" else ""
	_dialogue_label.append_text(prefix + text + "\n")

	if scroll_on_new_line:
		if _batch_mode:
			_scroll_dirty = true
		else:
			_scroll_to_bottom(_dialogue_label)


func show_options(title: String, options: Array) -> void:
	if not _choices_label:
		return

	set_batch_mode(false)
	_choices_label.clear()
	_choice_map.clear()

	if not DialogueUtils.is_nullish(title):
		_choices_label.append_text("[b]%s[/b]\n\n" % title)

	var timestamp := str(Time.get_ticks_usec())
	for i in range(options.size()):
		var option = options[i]
		if typeof(option) != TYPE_DICTIONARY:
			continue

		var option_text: String = str(option.get("text", ""))
		if DialogueUtils.is_nullish(option_text):
			continue

		var meta_key := "choice_%s_%d" % [timestamp, i]
		_choice_map[meta_key] = {"index": i, "text": option_text}
		var is_visited: bool = option.get("visited", false)

		if is_visited:
			_choices_label.append_text(
				"[url=%s][color=#888888]• %s[/color][/url]\n" % [meta_key, option_text]
			)
		else:
			_choices_label.append_text("[url=%s]• %s[/url]\n" % [meta_key, option_text])


func _on_meta_clicked(meta: Variant) -> void:
	var meta_key := str(meta)
	if not _choice_map.has(meta_key):
		return

	var entry: Dictionary = _choice_map[meta_key]
	var choice_index: int = entry.get("index", 0)
	var choice_text: String = str(entry.get("text", ""))
	_choices_label.clear()
	_choice_map.clear()
	option_selected.emit(choice_index, choice_text)


func _flush_scroll() -> void:
	_scroll_dirty = false
	if _dialogue_label:
		_scroll_to_bottom(_dialogue_label)


func _scroll_to_bottom(label: RichTextLabel) -> void:
	var scrollbar := label.get_v_scroll_bar()
	if not scrollbar:
		return

	if not animate_scroll:
		scrollbar.value = scrollbar.max_value
		return

	_kill_scroll_tween()
	_scroll_tween = create_tween()
	_scroll_tween.set_ease(Tween.EASE_OUT)
	_scroll_tween.tween_property(scrollbar, "value", scrollbar.max_value, scroll_duration)


func _kill_scroll_tween() -> void:
	if _scroll_tween and _scroll_tween.is_valid():
		_scroll_tween.kill()
	_scroll_tween = null
