# Any Game Quest System (Lite)

> This is the core (Lite) version of **Any Game Quest System**. If you need advanced features (Quest HUD UI scenes and row widgets), check out the Pro Version on Itch.io: [https://hyakan.itch.io](https://hyakan.itch.io)

Game-agnostic Godot plugin packaged for AssetLib.

## Install

1. Copy the `addons/any_game_quest_system/` folder into your project’s `res://addons/` directory.
2. Enable the plugin in **Project → Project Settings → Plugins**.

## What you get (Lite)

GaQuest + GaQuestManager API (register, start, complete, follow, persistence).

## Dependencies

- None required

## Event Bus (optional)

This plugin runs standalone. Cross-plugin features below require **[Any Game Event Bus](https://hyakan.itch.io/any-game-event-bus)** (placeholder), a separate paid hub that connects Midnight Anxiety addons to each other.

Every Pro package includes Event Bus for free.

### Features unlocked by Event Bus

- Broadcasts quest started / completed / failed / progress / followed-quest changes.
- Listens to `interactable_activated` so world interactions can advance quests.
- Pro HUD updates live from those signals.


## Structure

- `core/` — shared runtime (identical between Lite and Pro where applicable)
- No `pro_features/` in Lite


---
Need Quest HUD UI scenes and row widgets? [Get the Pro version on Itch.io](https://hyakan.itch.io)

