# Modular Perks

Game-agnostic Godot 4 perk framework: definitions, registry, draft offers, runtime state, effect bus, optional UI, and a host adapter contract.

Install by copying or symlinking this folder into your project:

```text
godot_plugins/modular_perks  ->  res://addons/modular_perks
```

Enable the plugin in **Project → Project Settings → Plugins**. The plugin registers `PerkDefinition` and `PerkConfig` custom resource types in the editor.

## Quick start

```gdscript
var host := MyGamePerkHost.new()
var api := PerkAPI.new(host)
SamplePerkPack.register(api)

var state := PerkRunState.new()
var offers := api.roll_offers(state, 3, false, "session_start")
api.apply_pick(state, "sample_keen_eye")
```

Load `.tres` packs from disk:

```gdscript
api.register_pack_from_dir("res://addons/modular_perks/content/sample/perks")
```

## Architecture

| Type | Responsibility |
|------|----------------|
| `PerkDefinition` | Resource describing one perk |
| `PerkConfig` | Offer weights, categories, rarities, gates |
| `PerkRegistry` | Index definitions, unlock filtering |
| `PerkDraftService` | Roll offers, gates, reroll, apply pick rules |
| `PerkRunState` | Active ids, picked ids, instances, flags |
| `PerkEffect` / `PerkEffectBus` | Pluggable effect handlers |
| `PerkAPI` | Facade for host code |
| `PerkHost` | Game adapter interface |
| `PerkFlow` | Optional UI flows (selection, target pick, option pick) |

## Host contract (`PerkHost`)

Implement these methods in your game:

| Method | Purpose |
|--------|---------|
| `get_unlock_score() -> int` | Meta progress used to filter unlockable perks |
| `translate(key, fallback) -> String` | Localization hook |
| `list_target_entities(context) -> Array[Dictionary]` | Entities for target-pick perks (`id`, `label`) |
| `list_option_choices(context) -> Array[Dictionary]` | Options for instant-choice perks |
| `on_pick_applied(perk_id, state, context)` | Post-pick hook (telemetry, save, etc.) |
| `apply_resource_bonus(resource_id, amount, context)` | Domain mutation for resource perks |
| `apply_stat_multiplier(entity_id, stat_id, multiplier, context)` | Domain stat changes |
| `apply_option_choice(option_id, context)` | Domain option application |

The plugin core never imports game managers or simulators.

## Content packs

A pack supplies:

1. `PerkDefinition` resources (`.tres`) and/or runtime registration
2. Optional `PerkEffect` handlers registered on `PerkAPI.register_effect_handler`

Use `effect_data.kind` to route effects, for example:

```gdscript
effect_data = {
    "kind": "resource_bonus",
    "resource_id": "credits",
    "amount": 10,
}
```

Target-pick perks set `"requires_target_pick": true`. Option-pick perks set `"requires_option_pick": true`.

See [`content/sample/`](content/sample/) for a minimal pack with three generic effect kinds:

- `resource_bonus`
- `stat_multiply`
- `option_pick`

## Draft rules (defaults)

- Offer weights: 85% perk, 10% gate, 5% reroll (`PerkConfig`)
- Gates unlock when a category has at least 3 available unlocked perks
- `session_start_only` perks only appear in `"session_start"` selection mode
- Non-repeatable perks are removed from eligibility after pick
- Reroll switches to preview-locked full pool offers

All defaults are configurable via `PerkConfig`.

## Persistence

Serialize `PerkRunState.to_dict()` inside your save system. The host owns save/load; the plugin only provides the blob shape.

## Optional UI

`PerkFlow.await_selection()` shows three offers. `PerkFlow.apply_pick_with_flows()` runs target/option subflows before calling `apply_pick`.

`PerkSelectionScreen` supports both horizontal (`HBoxContainer`) and vertical (`VBoxContainer`) card rows: put either under `%CardsRow`, or call `set_cards_layout()` at runtime. Cards keep entrance/exit flip animations either way.

UI strings are plain English fallbacks. Wire `PerkHost.translate()` to your localization system using keys like `perk.<id>.name` and `perk.ui.*`.

## Tests

Run headless tests (requires Godot CLI on PATH):

```bash
godot --headless --path /path/to/project --script res://addons/modular_perks/tests/run_tests.gd
```

For isolated scripts or CLI tools, call `PerkModuleLoader.preload_all()` once before referencing global perk types.

## Integrating an existing game

1. Implement `PerkHost` against your meta-progress and domain systems.
2. Move perk definitions into a content pack (`.tres` + handlers).
3. Replace direct perk resolver calls with `PerkAPI.query_effect(kind, state, context)` or custom handler queries.
4. Persist `PerkRunState` in your existing run save blob.
5. Optionally replace bespoke selection UI with `PerkFlow`.

Keep legacy perk code in the game until the adapter is complete; the plugin is designed to coexist while you migrate incrementally.

## Sample pack registration

```gdscript
SamplePerkPack.register(api)
# or
api.register_pack_from_dir(SamplePerkPack.get_content_dir())
```
