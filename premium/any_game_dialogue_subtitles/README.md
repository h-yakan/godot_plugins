# Any Game Dialogue Subtitles (Pro)

> **Any Game Dialogue Subtitles Pro** — On-screen GaDialogueUI scene. Priority support for Pro owners.

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy `addons/any_game_dialogue_subtitles/` and `addons/any_game_event_bus/` into your project’s `res://addons/` directory. Skip Event Bus if you already have it from another Pro package.
2. Enable both plugins in **Project → Project Settings → Plugins**.

## What you get (Pro)

On-screen GaDialogueUI scene

## Dependencies

- None required

## Event Bus (included free)

This Pro zip includes **Any Game Event Bus** (`addons/any_game_event_bus/`). Enable it alongside this plugin. Event Bus is the paid hub that connects Midnight Anxiety addons; it ships with every Pro package at no extra cost.

Standalone: [Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus) (placeholder)

### Features unlocked by Event Bus

- Listens to quest start/complete to trigger dialogue lines.
- Broadcasts `dialogue_started` / `dialogue_finished`.
- Pro UI listens to `ear_state_changed` (ear cover) and broadcasts `dialogue_character_typed`.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- `pro_features/` — UI, samples, convenience modules


---
Includes priority support for Pro owners.


## Itch.io

Upload `logo.png` as the page icon / cover thumbnail on [hyakan.itch.io](https://hyakan.itch.io).
