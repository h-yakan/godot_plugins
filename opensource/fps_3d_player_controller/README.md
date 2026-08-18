# FPS 3D Player Controller (Lite)

> This is the core (Lite) version of **FPS 3D Player Controller**. If you need advanced features (Packed ga_fps_player.tscn prefab), check out the Pro Version on Itch.io: [https://hyakan.itch.io](https://hyakan.itch.io)

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy the `addons/fps_3d_player_controller/` folder into your project’s `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**.

## What you get (Lite)

Full FPS movement/look/jump/sprint/crouch/freefly/health API.

## Dependencies

- None required. The Pro prefab bundles `fps_3d_interaction_ray`; Lite has no scene dependency.

## Event Bus (optional)

This plugin runs standalone. Cross-plugin features below require **[Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus)** (placeholder), a separate paid hub that connects Midnight Anxiety addons to each other.

Every Pro package includes Event Bus for free.

### Features unlocked by Event Bus

- Broadcasts `player_health_changed` so HUDs and other systems can track health.
- Listens to `player_look_switch` / `player_move_switch` so notes, dialogue, TVs, and doors can freeze look and movement.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- No `pro_features/` in Lite


---
Need Packed ga_fps_player.tscn prefab? [Get the Pro version on Itch.io](https://hyakan.itch.io)

