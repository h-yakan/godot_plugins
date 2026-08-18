# Any Game Inventory (Lite)

> This is the core (Lite) version of **Any Game Inventory**. If you need advanced features (GaItemUI list-row scene and script), check out the Pro Version on Itch.io: [https://hyakan.itch.io](https://hyakan.itch.io)

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy the `addons/any_game_inventory/` folder into your project’s `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**.

## What you get (Lite)

GaItemData + GaInventoryManager API (pickup/equip/registry).

## Dependencies

- None required

## Event Bus (optional)

This plugin runs standalone. Cross-plugin features below require **[Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus)** (placeholder), a separate paid hub that connects Midnight Anxiety addons to each other.

Every Pro package includes Event Bus for free.

### Features unlocked by Event Bus

- Broadcasts `inventory_changed` and `equipped_changed` so UI and other addons stay in sync.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- No `pro_features/` in Lite


---
Need GaItemUI list-row scene and script? [Get the Pro version on Itch.io](https://hyakan.itch.io)

