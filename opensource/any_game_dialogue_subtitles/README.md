# Any Game Dialogue Subtitles (Lite)

> This is the core (Lite) version of **Any Game Dialogue Subtitles**. If you need advanced features (On-screen GaDialogueUI scene), check out the Pro Version on Itch.io: [https://hyakan.itch.io](https://hyakan.itch.io)

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy the `addons/any_game_dialogue_subtitles/` folder into your project’s `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**.

## What you get (Lite)

GaDialogueManager queue/typewriter/history API.

## Dependencies

- None required

## Event Bus (optional)

This plugin runs standalone. Cross-plugin features below require **[Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus)** (placeholder), a separate paid hub that connects Midnight Anxiety addons to each other.

Every Pro package includes Event Bus for free.

### Features unlocked by Event Bus

- Listens to quest start/complete to trigger dialogue lines.
- Broadcasts `dialogue_started` / `dialogue_finished`.
- Pro UI listens to `ear_state_changed` (ear cover) and broadcasts `dialogue_character_typed`.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- No `pro_features/` in Lite


---
Need On-screen GaDialogueUI scene? [Get the Pro version on Itch.io](https://hyakan.itch.io)

