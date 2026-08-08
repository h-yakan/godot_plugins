# Clyde Dialogue Host — Usage

Game-agnostic runtime built on Clyde. Handles playback, UI presentation, and trigger routing without coupling to dice, stats, or scene graphs.

## Setup

1. Enable Clyde (see `godot_plugins/README.md`).
2. Enable **Clyde Dialogue Host** plugin.
3. Add `scenes/clyde_dialogue_host.tscn` to your scene tree, or add a `ClydeDialogueHost` node manually with a `RichTextDialoguePresenter` child.

## Basic usage

```gdscript
@onready var host: ClydeDialogueHost = $ClydeDialogueHost

func _ready() -> void:
	host.dialogue_started.connect(_on_started)
	host.dialogue_ended.connect(_on_ended)
	host.choice_made.connect(_on_choice)

func start() -> void:
	host.start_dialogue("res://dialogue/my_scene.clyde", "START")

func _on_started(path: String, block: String) -> void:
	print("Dialogue: ", path, " block=", block)

func _on_ended() -> void:
	print("Done")

func _on_choice(index: int, text: String) -> void:
	print("Picked ", index, ": ", text)
```

### From a ClydeDialogueFile resource

```gdscript
@export var dialogue: ClydeDialogueFile

func start() -> void:
	host.start_from_resource(dialogue, "START")
```

## Playback modes

| Export | Default | Behavior |
|--------|---------|----------|
| `auto_drain_lines` | `true` | Consumes all lines until options or end (VN-style log) |
| `max_lines_per_frame` | `12` | Limits lines processed per frame (0 = unlimited) |
| `auto_drain_lines = false` | — | Call `host.advance()` manually for one step at a time |

When `auto_drain_lines` is false, choices still work via the presenter or `host.choose(index)`.

## Signals

| Signal | When |
|--------|------|
| `dialogue_started(file_path, block_name)` | After Clyde loads and starts |
| `dialogue_ended()` | Dialogue finished or `{trigger end_dialogue}` |
| `line_presented(speaker, text, content)` | Each Clyde line |
| `options_presented(title, options)` | Choice block shown |
| `choice_made(index, text)` | Player picked an option |
| `trigger_received(name, args)` | Any Clyde `{trigger ...}` (always emitted) |
| `variable_changed(name, value, previous)` | Clyde variable changed |
| `dice_rolled(result)` | Built-in dice roll completed |
| `event_changed(key, value, previous)` | Event store updated |
| `persistence_saved()` / `persistence_loaded()` | Save files written/read |

## Built-in dice, events, and persistence

The host includes built-in triggers — use them directly in `.clyde` files:

| Trigger | Example |
|---------|---------|
| `roll_dice(stat, roll_id?)` | `{ trigger roll_dice("zeka", "gozlem") }` |
| `record_event(key)` | `{ trigger record_event("met_npc") }` |
| `set_event(key, value)` | `{ trigger set_event("gold", 100) }` |
| `clear_event(key)` | `{ trigger clear_event("met_npc") }` |
| `set_stat(name, value)` | `{ trigger set_stat("zeka", 3) }` |
| `add_modifier(id, value, desc?)` | `{ trigger add_modifier("lucky", 1, "Lucky") }` |
| `save_state()` / `load_state()` | Manual persistence flush/reload |

Full reference: [BUILTIN_FEATURES.md](BUILTIN_FEATURES.md)

## Custom trigger handlers

Register game-specific logic for triggers not covered above:

```gdscript
host.register_trigger("change_scene", func(args: Array):
	if args.size() > 0:
		my_game.change_scene(str(args[0]))
)
```

Built-in handler:

- `end_dialogue` → calls `host.end_dialogue()`
- `roll_dice`, `set_event`, `record_event`, `clear_event`, `set_stat`, `show_stats`, `add_modifier`, `save_state`, `load_state` → see [BUILTIN_FEATURES.md](BUILTIN_FEATURES.md)

Unknown triggers only emit `trigger_received`. Set `strict_triggers = true` on the host to warn on unhandled triggers.

Unregister:

```gdscript
host.unregister_trigger("change_scene")
```

## Variables and persistence

Forwarded to Clyde:

```gdscript
host.set_variable("gold", 100)
var hp = host.get_variable("hp", 0)
host.get_data()      # save state
host.load_data(data) # restore
host.clear_data()
```

## Custom UI (presenters)

Extend `DialoguePresenter`:

```gdscript
class_name MyDialoguePresenter
extends DialoguePresenter

func show_line(speaker: String, text: String) -> void:
	my_label.text += "%s: %s\n" % [speaker, text]

func show_options(title: String, options: Array) -> void:
	for i in options.size():
		add_button(options[i].text, func(): option_selected.emit(i, options[i].text))
```

Attach as child of `ClydeDialogueHost` and set `presenter_path` on the host.

Or skip presenters entirely — connect to `line_presented` and `options_presented`, then call `host.choose(index)`.

## Default RichText presenter

`RichTextDialoguePresenter` expects:

- `DialogueUI/Panel/VBoxContainer/Dialogue` — log (BBCode)
- `DialogueUI/Panel/VBoxContainer/Choices` — clickable options via `[url]` meta

Export `dialogue_label_path` / `choices_label_path` if your tree differs.

## Clyde syntax reference

Common patterns in `.clyde` files:

```clyde
{ set dc = 8 }
{ trigger roll_dice("zeka", "lockpick") }
{ when roll_final >= dc }
Success!
{ otherwise }
Failure.
{ trigger change_scene("town") }
{ trigger end_dialogue() }

== START
Speaker: Hello %name%!
* Option A
* Option B
```

See Clyde docs: https://thisisvini.com/clyde

## Migrating from `scripts/dialogue_manager.gd`

| Old (game manager) | New (host) |
|--------------------|------------|
| `start_dialogue(path, block)` | Same on `ClydeDialogueHost` |
| Built-in `roll_dice` | Built-in `{ trigger roll_dice(...) }` |
| Built-in `add_modifier` | Built-in `{ trigger add_modifier(...) }` |
| Built-in `set_stat` / `show_stats` | Built-in `{ trigger set_stat(...) }` / `show_stats()` |
| `$"../..".change_scene` | `register_trigger("change_scene", ...)` |
| Hardcoded UI paths | `RichTextDialoguePresenter` or custom presenter |
| `character_stats.json` / modifiers JSON | Set `default_stats_path` / `default_modifiers_path` on host |

Point default paths at existing game data for drop-in compatibility:

```gdscript
host.default_stats_path = "res://data/character_stats.json"
host.default_modifiers_path = "res://data/modifiers.default.json"
host.load_persistence()
```

## Scene reference

Ready-made scene: `scenes/clyde_dialogue_host.tscn`

```
ClydeDialogueHost
├── DialogueUI (Control, hidden until dialogue starts)
│   └── Panel → VBoxContainer → Dialogue, Choices
└── RichTextDialoguePresenter
```

## Debugging

```gdscript
print(host.get_dialogue_state())
# { is_active, file, block, waiting_for_choice, has_clyde, has_presenter }
```
