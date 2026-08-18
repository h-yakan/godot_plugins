# Any Game Event Bus (Pro)

> **Any Game Event Bus** — The paid signal hub that connects Midnight Anxiety plugins and unlocks their cross-addon features. Priority support for Pro owners.

There is no Lite edition. Every other Pro package includes this addon for free.

## Install

1. Copy the `addons/any_game_event_bus/` folder into your project’s `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**. That registers the `GaEventBus` autoload.

If you already installed Event Bus from another Pro zip, keep a single copy.

## What you get (Pro)

- `GaEventBus` autoload: catalog of shared signals (health, look/move lock, quests, dialogue, inventory, notes, doors, shake, and more).
- Extension API: other addons call `register_signal`, `emit_named`, and `connect_named` so they can add or use signals without a hard compile-time dependency.
- Live glue between plugins — each addon still works alone; Event Bus is what makes them talk.

Standalone store page (placeholder): [https://hyakan.itch.io/any-game-event-bus](https://hyakan.itch.io/any-game-event-bus)

## Plugins Event Bus connects

| Plugin | What Event Bus unlocks |
|--------|------------------------|
| FPS 3D Player Controller | Health broadcasts; look/move freeze from notes, TVs, doors, dialogue |
| Any Game Quest System | Quest start/complete/fail/progress/follow signals; interactable-driven progress |
| Any Game Dialogue Subtitles | Quest-triggered lines; dialogue start/finish; ear-cover ducking (Pro UI) |
| Any Game Inventory | Inventory and equipped-item change broadcasts |
| Any Game Notes Documents | Open notes; freeze player and toggle HUD while reading |
| Any Game Save System | `save_completed`; inventory refresh after load |
| Any Game Progress Tracker UI | Live dashboard from quest, dialogue, and inventory signals |
| 3D FPS Physics Doors | Locked-door warnings; look lock while pushing |
| 3D Interactable TV Viewport | Freeze look/move and toggle HUD while watching |
| 3D Item Placement Slots | Warning when an item cannot be placed |
| FPS 3D Camera Shake | Remote `camera_shake_trauma` triggers |
| FPS Horror Eye Blink | `eyes_toggle` / `eyes_closed` broadcasts |
| FPS Horror Ear Cover | `ear_state_changed` so dialogue UI can duck |

## Dependencies

- None. Other plugins optionally extend this hub.

## Structure

- `core/` — autoload + client helper other addons copy
- `examples/` — usage notes


---
Includes priority support for Pro owners.


## Itch.io

Upload `logo.png` as the page icon / cover thumbnail on [hyakan.itch.io](https://hyakan.itch.io).
