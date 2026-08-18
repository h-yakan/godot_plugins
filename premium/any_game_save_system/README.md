# Any Game Save System (Pro)

> **Any Game Save System Pro** — GaSavePoint interactable convenience node. Priority support for Pro owners.

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy `addons/any_game_save_system/` and `addons/any_game_event_bus/` into your project’s `res://addons/` directory. Skip Event Bus if you already have it from another Pro package.
2. Enable both plugins in **Project → Project Settings → Plugins**.

## What you get (Pro)

GaSavePoint interactable convenience node

## Dependencies

- None required

## Event Bus (included free)

This Pro zip includes **Any Game Event Bus** (`addons/any_game_event_bus/`). Enable it alongside this plugin. Event Bus is the paid hub that connects Midnight Anxiety addons; it ships with every Pro package at no extra cost.

Standalone: [Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus) (placeholder)

### Features unlocked by Event Bus

- Broadcasts `save_completed` after a successful save.
- After load, broadcasts `inventory_changed` so inventory UI refreshes.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- `pro_features/` — UI, samples, convenience modules


---
Includes priority support for Pro owners.


## Itch.io

Upload `logo.png` as the page icon / cover thumbnail on [hyakan.itch.io](https://hyakan.itch.io).
