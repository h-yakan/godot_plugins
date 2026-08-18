# Any Game Notes Documents (Lite)

> This is the core (Lite) version of **Any Game Notes Documents**. If you need advanced features (GaNoteInteractable 3D world prop), check out the Pro Version on Itch.io: [https://hyakan.itch.io](https://hyakan.itch.io)

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy the `addons/any_game_notes_documents/` folder into your project’s `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**.

## What you get (Lite)

GaNoteData + read-note UI.

## Dependencies

- None required

## Event Bus (optional)

This plugin runs standalone. Cross-plugin features below require **[Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus)** (placeholder), a separate paid hub that connects Midnight Anxiety addons to each other.

Every Pro package includes Event Bus for free.

### Features unlocked by Event Bus

- Listens to `show_note` to open the reader.
- While reading: `toggle_ui`, `player_look_switch`, and `player_move_switch` freeze the player and hide HUD.
- Pro interactable emits `show_note`.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- No `pro_features/` in Lite


---
Need GaNoteInteractable 3D world prop? [Get the Pro version on Itch.io](https://hyakan.itch.io)

