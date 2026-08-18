# FPS 3D Camera Shake

Fully free / open-source Godot plugin (MIT). No separate Pro edition.

## Install

1. Copy the `addons/fps_3d_camera_shake/` folder into your project's `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**.

## What you get

Complete camera shake (idle, trauma, tilt, bob).

## Dependencies

- None required

## Event Bus (optional)

This plugin runs standalone. Cross-plugin features below require **[Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus)** (placeholder), a separate paid hub that connects Midnight Anxiety addons to each other.

Every Pro package includes Event Bus for free.

### Features unlocked by Event Bus

- Listens to `camera_shake_trauma` so other systems can trigger shake remotely.


## Structure

- `core/` — full plugin runtime
- MIT `LICENSE`

---
More tools and Pro editions: [hyakan.itch.io](https://hyakan.itch.io)
