# Any Game Quest System (Pro)

> **Any Game Quest System Pro** — Quest HUD UI scenes and row widgets. Priority support for Pro owners.

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy `addons/any_game_quest_system/` and `addons/any_game_event_bus/` into your project’s `res://addons/` directory. Skip Event Bus if you already have it from another Pro package.
2. Enable both plugins in **Project → Project Settings → Plugins**.

## What you get (Pro)

Quest HUD UI scenes and row widgets

## Dependencies

- None required

## Event Bus (included free)

This Pro zip includes **Any Game Event Bus** (`addons/any_game_event_bus/`). Enable it alongside this plugin. Event Bus is the paid hub that connects Midnight Anxiety addons; it ships with every Pro package at no extra cost.

Standalone: [Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus) (placeholder)

### Features unlocked by Event Bus

- Broadcasts quest started / completed / failed / progress / followed-quest changes.
- Listens to `interactable_activated` so world interactions can advance quests.
- Pro HUD updates live from those signals.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- `pro_features/` — UI, samples, convenience modules


---
Includes priority support for Pro owners.


## Itch.io

Upload `logo.png` as the page icon / cover thumbnail on [hyakan.itch.io](https://hyakan.itch.io).
