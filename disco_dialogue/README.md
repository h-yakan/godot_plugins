# Godot Plugins — Clyde Dialogue Stack

Self-contained dialogue plugins for Godot 4, built on [Clyde Dialogue](https://thisisvini.com/clyde) 7.0.0.

> **Komandolar projesi:** Türkçe kullanım kılavuzu → [`DIALOGUE_SYSTEM.md`](../DIALOGUE_SYSTEM.md) (proje kökü)

## Contents

| Plugin | Path | Role |
|--------|------|------|
| **Clyde Dialogue** | `godot_plugins/clyde/` | Language, parser, interpreter, editor, `.clyde` importer |
| **Clyde Dialogue Host** | `godot_plugins/clyde_dialogue_host/` | Game-agnostic runtime host with pluggable UI and triggers |

## Features

- Auto-drain line playback until choices/end (with `max_lines_per_frame` budget)
- RichText BBCode presenter with batch scroll optimization
- Built-in dice rolling (`roll_dice` trigger)
- Persistent events, stats, modifiers (debounced JSON save)
- Pluggable `{trigger ...}` handlers via `register_trigger`
- Signals for lines, options, choices, rolls, and persistence

## Best practices

1. **Keep game logic in `.clyde`** — branching, conditions, copy; GDScript only for integration.
2. **Use `record_event` for persistent flags** — `{ set flag = true }` is session-only; triggers write to disk.
3. **Name events in snake_case** — `met_nur`, `quest_stage_2`.
4. **Pair modifier ids with roll ids** — `add_modifier("gozlem", …)` + `roll_dice("zeka", "gozlem")`.
5. **Register only game-specific triggers** — scene changes, audio, animations; dice/events are built-in.
6. **Tune `max_lines_per_frame`** — default `12` prevents frame spikes on long line dumps.
7. **Set default data paths once in `_ready`** — then call `load_persistence()`.

## Enable in a project

1. Copy the entire `godot_plugins/` folder into your Godot project root (or use it in-place in this repo).
2. Open **Project → Project Settings → Plugins**.
3. Enable **one** Clyde plugin only:
   - `res://godot_plugins/clyde/plugin.cfg` **or**
   - existing `res://addons/clyde/plugin.cfg`
   
   Do **not** enable both.
4. Enable **Clyde Dialogue Host**: `res://godot_plugins/clyde_dialogue_host/plugin.cfg`
5. Set `dialogue/source_folder` in Project Settings (e.g. `res://dialogue/`).

### This repo (komandolar)

Keep using `addons/clyde` for editor continuity. Enable only the **host** plugin from `godot_plugins/clyde_dialogue_host/`.

## Quick start

1. Instance `res://godot_plugins/clyde_dialogue_host/scenes/clyde_dialogue_host.tscn` under your UI.
2. Wire from game code:

```gdscript
@onready var host: ClydeDialogueHost = $ClydeDialogueHost

func _ready() -> void:
	host.default_stats_path = "res://data/character_stats.json"
	host.default_modifiers_path = "res://data/modifiers.default.json"
	host.load_persistence()
	host.register_trigger("change_scene", func(args): go_to_scene(str(args[0])))
	host.start_dialogue("res://dialogue/intro_scene.clyde")
```

3. In `.clyde` files:

```clyde
{ trigger roll_dice("zeka", "gozlem") }
{ when roll_final >= 5 } Success!
{ trigger record_event("found_clue") }
{ when found_clue } You remember the clue.
```

## Architecture

```
Game code → ClydeDialogueHost
              ├── ClydeDialogue
              ├── DialoguePersistence (events / stats / modifiers)
              ├── DialogueDiceRoller
              └── DialoguePresenter
```

## Documentation

| Doc | Content |
|-----|---------|
| [`DIALOGUE_SYSTEM.md`](../DIALOGUE_SYSTEM.md) | Project usage guide (TR) |
| `clyde_dialogue_host/docs/BUILTIN_FEATURES.md` | Dice, events, stats API |
| `clyde_dialogue_host/docs/USAGE.md` | Host API reference |

## License

Clyde Dialogue is by Vinicius Gerevini (see upstream). Host plugin code follows this project's license.
