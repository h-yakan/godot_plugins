# FPS 3D Player Controller (Pro)

> **FPS 3D Player Controller Pro** — Packed ga_fps_player.tscn prefab. Priority support for Pro owners.

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy `addons/fps_3d_player_controller/`, `addons/fps_3d_interaction_ray/`, and `addons/any_game_event_bus/` into your project’s `res://addons/` directory. Skip Event Bus if you already have it from another Pro package.
2. Enable the player controller and interaction ray plugins in **Project → Project Settings → Plugins**. Enable Event Bus as well if you want cross-plugin features.

## What you get (Pro)

Packed `ga_fps_player.tscn` prefab, with **FPS 3D Interaction Ray** bundled (the prefab’s camera ray depends on it).

## Dependencies

- `fps_3d_interaction_ray` — included in this zip (`addons/fps_3d_interaction_ray/`). Required for the Pro prefab. Skip if you already installed the standalone MIT package.

## Event Bus (included free)

This Pro zip includes **Any Game Event Bus** (`addons/any_game_event_bus/`). Enable it alongside this plugin. Event Bus is the paid hub that connects Midnight Anxiety addons; it ships with every Pro package at no extra cost.

Standalone: [Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus) (placeholder)

### Features unlocked by Event Bus

- Broadcasts `player_health_changed` so HUDs and other systems can track health.
- Listens to `player_look_switch` / `player_move_switch` so notes, dialogue, TVs, and doors can freeze look and movement.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- `pro_features/` — UI, samples, convenience modules


---
Includes priority support for Pro owners.


## Itch.io

Upload `logo.png` as the page icon / cover thumbnail on [hyakan.itch.io](https://hyakan.itch.io).
