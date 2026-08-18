# Any Game Save System (Lite)

> This is the core (Lite) version of **Any Game Save System**. If you need advanced features (GaSavePoint interactable convenience node), check out the Pro Version on Itch.io: [https://hyakan.itch.io](https://hyakan.itch.io)

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy the `addons/any_game_save_system/` folder into your project’s `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**.

## What you get (Lite)

Multi-slot save/load API, player pose, world/door state.

## Dependencies

- None required

## Event Bus (optional)

This plugin runs standalone. Cross-plugin features below require **[Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus)** (placeholder), a separate paid hub that connects Midnight Anxiety addons to each other.

Every Pro package includes Event Bus for free.

### Features unlocked by Event Bus

- Broadcasts `save_completed` after a successful save.
- After load, broadcasts `inventory_changed` so inventory UI refreshes.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- No `pro_features/` in Lite


---
Need GaSavePoint interactable convenience node? [Get the Pro version on Itch.io](https://hyakan.itch.io)

