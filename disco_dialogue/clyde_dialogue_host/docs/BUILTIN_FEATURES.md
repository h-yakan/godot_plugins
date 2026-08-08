# Clyde Dialogue Host — Built-in Features

Dice rolling, persistent events, stats, and modifiers work out of the box via Clyde `{trigger ...}` calls. No extra GDScript required for standard usage.

## Dice rolling

In `.clyde` files:

```clyde
{ set dc = 7 }
{ trigger roll_dice("zeka", "gozlem") }
{ when roll_final >= dc }
Observation succeeded!
{ otherwise }
Observation failed.
```

### Arguments

```
{ trigger roll_dice(stat_type) }
{ trigger roll_dice(stat_type, roll_id) }
{ trigger roll_dice(stat_type, roll_id, extra_tag) }
```

| Argument | Role |
|----------|------|
| `stat_type` | Stat used for bonus (e.g. `zeka`, `karizma`) |
| `roll_id` | Modifier id looked up in modifier store |
| `extra_tag` | Optional extra tag for modifier matching |

### Variables set after roll

| Variable | Meaning |
|----------|---------|
| `die1`, `die2` | Individual dice |
| `roll_base` | Sum of dice |
| `mod_sum` | Modifier bonus total |
| `stat_bonus` | Stat bonus |
| `roll_final` | Final total |
| `dice_id`, `stat_type` | Echo of roll args |

Use in conditions: `{ when roll_final >= dc }`

From GDScript:

```gdscript
host.roll_dice("zeka", "gozlem")
host.dice_rolled.connect(func(r): print(r.final))
```

## Events (save / load / read in dialogue)

Events are key-value flags stored in `user://clyde_dialogue_events.json` (configurable).

### Record a flag

```clyde
{ trigger record_event("met_nur") }
{ when met_nur }
You already met Nur.
```

### Set any value

```clyde
{ trigger set_event("quest_stage", 2) }
{ when quest_stage >= 2 }
...
```

### Clear a flag

```clyde
{ trigger clear_event("met_nur") }
```

Events sync to Clyde variables automatically, so `{ when key }` works in the same and later dialogues.

From GDScript:

```gdscript
host.record_event("found_key")
host.set_event("gold", 50)
var stage = host.get_event("quest_stage", 0)
host.clear_event("found_key")
```

### Manual save / load

Auto-save is on by default. Force from dialogue:

```clyde
{ trigger save_state() }
{ trigger load_state() }
```

Or from code:

```gdscript
host.save_persistence()
host.load_persistence()
```

## Stats

Character stats persist in `user://clyde_dialogue_stats.json`.

```clyde
{ trigger set_stat("zeka", 3) }
{ trigger show_stats() }
```

Set default file on host:

```gdscript
host.default_stats_path = "res://data/character_stats.json"
host.load_persistence()
```

Stats are available as `%zeka%` and used as dice bonuses via `roll_dice("zeka", ...)`.

## Modifiers

Modifiers persist in `user://clyde_dialogue_modifiers.json`.

```clyde
{ trigger add_modifier("hanci_known", 2, "You know the innkeeper's name") }
{ trigger roll_dice("karizma", "hanci_known") }
```

Arguments: `id`, `value`, `description`, optional `active` (default `true`).

Default seed file:

```gdscript
host.default_modifiers_path = "res://data/modifiers.default.json"
```

## Full example (from komandolar dialogues)

```clyde
{ set dc = 5 }
{ trigger roll_dice("zeka", "gozlem") }
{ when roll_final >= dc } You notice everyone avoids the board. { trigger set_event("pano_fark", true) }
{ when roll_final < dc } You notice nothing special.

{ trigger add_modifier("hanci_known", 2, "You know Nur") }
{ trigger roll_dice("karizma", "hanci_known") }
{ when roll_final >= dc } Nur tells you the rumor...
```

## Custom providers (optional)

Override stat/modifier lookup without JSON files:

```gdscript
host.set_stat_provider(func(stat_name: String) -> int:
	return my_stats.get(stat_name, 0)
)
host.set_modifier_provider(func(roll_id: String, tag: String) -> int:
	return my_mod_system.sum(roll_id, tag)
)
```

## Host exports

| Export | Default | Purpose |
|--------|---------|---------|
| `enable_dice` | `true` | Built-in roll_dice trigger |
| `enable_persistence` | `true` | Events/stats/modifiers |
| `auto_save_persistence` | `true` | Debounced save after changes |
| `save_on_dialogue_end` | `true` | Flush dirty persistence when dialogue ends |
| `sync_persistence_on_start` | `true` | Push saved data into Clyde vars at dialogue start |
| `show_roll_results` | `true` | Show roll breakdown in UI |
| `events_save_path` | `user://clyde_dialogue_events.json` | Event file |
| `stats_save_path` | `user://clyde_dialogue_stats.json` | Stats file |
| `modifiers_save_path` | `user://clyde_dialogue_modifiers.json` | Modifiers file |

## Signals

| Signal | When |
|--------|------|
| `dice_rolled(result)` | After each roll |
| `event_changed(key, value, previous)` | Event store updated |
| `stat_changed(name, value, previous)` | Stat updated |
| `persistence_saved()` | All stores saved |
| `persistence_loaded()` | All stores loaded |

See also: [USAGE.md](USAGE.md) for core host API.
