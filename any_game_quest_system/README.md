# Any Game Quest System

Game-agnostic Godot plugin.

## Dependencies
- `any_game_event_bus (GaEventBus)`

## Autoload
GaQuestManager

## Usage
Set `quest_directory` export on GaQuestManager. Add `GaQuestUI` scene to your HUD and call `GaQuestManager.set_quest_ui(node)`.
