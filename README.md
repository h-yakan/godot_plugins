# godot_plugins

Game-agnostic modular Godot plugins extracted from Midnight Anxiety 2.

These packages live outside `addons/` so the main project is untouched. Copy any folder to `res://addons/` and enable in **Project Settings > Plugins**, or register autoloads manually.

## Naming

| Prefix | Use case |
|--------|----------|
| `any_game_*` | 2D/3D general |
| `3d_*` | 3D world required |
| `fps_3d_*` | First-person 3D |
| `fps_horror_*` | FPS horror niche |

## Plugins

- **fps_horror_interaction_kit** (Pro) — Flagship bundle: blink, ear cover, physics doors, grab, placement, TV, notes, horror player prefab, greybox apartment (`premium/fps_horror_interaction_kit/`)
- **any_game_perks_and_skills** (Pro) — Modular Perks + Skill System as one SKU (`premium/any_game_perks_and_skills/`)
- **any_game_event_bus** — GaEventBus (Pro-only hub that connects the other plugins; bundled free with every Pro package)
- **any_game_quest_system** — GaQuestManager, GaQuest, GaQuestUI
- **any_game_dialogue_subtitles** — GaDialogueManager, GaDialogueUI
- **any_game_inventory** — GaInventoryManager, GaItemData
- **any_game_settings_persistence** — GaPersistence
- **any_game_save_system** — GaSaveManager
- **any_game_notes_documents** — GaNoteData, GaReadNoteUI
- **any_game_progress_tracker_ui** — GaProgressTracker
- **fps_3d_camera_shake** — GaCameraShake
- **fps_3d_interaction_ray** — GaInteractionRay
- **fps_3d_player_controller** — GaFpsPlayerController
- **3d_fps_grabbable_physics** — GaGrabbable
- **3d_fps_physics_doors** — GaPhysicsDoor
- **3d_item_placement_slots** — GaPlacementArea
- **3d_interactable_tv_viewport** — GaInteractableTV
- **fps_horror_eye_blink** — GaEyeBlink
- **fps_horror_ear_cover** — GaEarMechanic
