# Any Game Notes Documents (Pro)

> **Any Game Notes Documents Pro** — GaNoteInteractable 3D world prop. Priority support for Pro owners.

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy `addons/any_game_notes_documents/` and `addons/any_game_event_bus/` into your project’s `res://addons/` directory. Skip Event Bus if you already have it from another Pro package.
2. Enable both plugins in **Project → Project Settings → Plugins**.

## What you get (Pro)

GaNoteInteractable 3D world prop

## Dependencies

- None required

## Event Bus (included free)

This Pro zip includes **Any Game Event Bus** (`addons/any_game_event_bus/`). Enable it alongside this plugin. Event Bus is the paid hub that connects Midnight Anxiety addons; it ships with every Pro package at no extra cost.

Standalone: [Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus) (placeholder)

### Features unlocked by Event Bus

- Listens to `show_note` to open the reader.
- While reading: `toggle_ui`, `player_look_switch`, and `player_move_switch` freeze the player and hide HUD.
- Pro interactable emits `show_note`.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- `pro_features/` — UI, samples, convenience modules


---
Includes priority support for Pro owners.


## Itch.io

Upload `logo.png` as the page icon / cover thumbnail on [hyakan.itch.io](https://hyakan.itch.io).
