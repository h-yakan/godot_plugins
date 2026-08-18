# FPS Horror Interaction Kit (Pro)

> Packed greybox apartment, horror player prefab (blink + ear cover), physics doors, grab, placement, in-world TV, and notes — wired through **Any Game Event Bus**. Priority support for Pro owners.

Godot 4.2+ first-person horror toolkit extracted from Midnight Anxiety 2. Open this folder as a project and press **Play**.

## Install

**As a playable project**

1. Unzip. In Godot 4.2+, **Import** this folder (`fps_horror_interaction_kit/`).
2. Press Play. The greybox apartment is the main scene.

**Into an existing game**

1. Copy every folder inside `addons/` into your project’s `res://addons/`.
2. Enable the plugins in **Project → Project Settings → Plugins**. That registers `GaEventBus` and `GaInventoryManager`.
3. Copy `examples/greybox_apartment/default_bus_layout.tres` (or add a **World** audio bus with a LowPass effect) so ear-cover muffling works.
4. Instance `addons/fps_horror_interaction_kit/pro_features/scenes/ga_horror_player.tscn`.

## What you get (Pro)

| Piece | Role |
|--------|------|
| **GaHorrorPlayer** prefab | FPS controller + interaction ray + eyelid overlay + ear-cover overlay |
| **Eye blink** | Shader lids, full blackout, afterimage flash, `eyes_toggle` / `eyes_closed` |
| **Ear cover** | Hold both ears: vignette, camera stress shake, World-bus low-pass, `ear_state_changed` |
| **Physics doors** | Mouse-drag push, auto open/close, look lock while pushing |
| **Grab / throw** | RigidBody3D follow-hand + throw |
| **Placement slots** | Equip an item, secondary-interact to seat it in a 3D deck |
| **Interactable TV** | Camera flies to the screen; SubViewport content |
| **Notes** | World note → fullscreen read UI, freezes look/move |
| **Event Bus** | Included. This is the hub that makes the pieces talk |
| **Greybox apartment** | Hall + living room + bedroom, already wired |

## Demo loop (apartment)

1. Read the note on the hall table (LMB).
2. Push the living-room door (LMB, then drag the mouse).
3. Pick up the cassette. Press **1** to equip. RMB the deck under the TV.
4. LMB the TV to sit in front of it. RMB / Esc to pull back.
5. Bedroom: grab a can (LMB), throw (RMB).
6. **C** / **V** to close / open the lids. Hold **Q+E** to cover your ears.

## Controls

| Action | Default |
|--------|---------|
| Move | WASD |
| Interact / grab | LMB |
| Throw / place / leave TV | RMB |
| Blink close / open | C / V |
| Cover ears | Q + E together |
| Equip first item | 1 |
| Pause / close note | Esc |

The apartment scene registers these actions at runtime if they are missing, so you can drop the demo into another project without hand-authoring Input Map first.

## Event Bus (included)

Standalone hub (placeholder): [https://hyakan.itch.io/any-game-event-bus](https://hyakan.itch.io/any-game-event-bus)

This zip already contains `addons/any_game_event_bus/`. Enable it. Cross-plugin features:

- Notes / TV freeze look and movement (`player_look_switch`, `player_move_switch`)
- Locked-door and bad-placement warnings (`show_warning`)
- Blink and ear-cover broadcasts (`eyes_closed`, `ear_state_changed`)
- Inventory equip / pickup (`inventory_changed`, `equipped_changed`)

## Structure

```
addons/
  fps_horror_interaction_kit/   # horror player prefab
  fps_horror_eye_blink/
  fps_horror_ear_cover/
  fps_3d_player_controller/     # Pro prefab + core
  fps_3d_interaction_ray/
  3d_fps_physics_doors/
  3d_fps_grabbable_physics/
  3d_item_placement_slots/
  3d_interactable_tv_viewport/
  any_game_notes_documents/
  any_game_inventory/           # required by placement slots
  any_game_event_bus/
examples/greybox_apartment/     # playable demo
```

`core/` scripts match the Lite editions where those exist. `pro_features/` is convenience: prefabs, UI, samples.

## Drop-in pieces

- Player: `res://addons/fps_horror_interaction_kit/pro_features/scenes/ga_horror_player.tscn`
- Demo: `res://examples/greybox_apartment/ga_horror_apartment.tscn`
- Optional heartbeat / breath: assign `AudioStream`s on the player’s `Heartbeat` and `Breath` nodes (bus **World**)

## Support

Priority support for Pro owners (email / Discord as listed on the itch page).

---
Includes priority support for Pro owners.

## Itch.io

Store copy and screenshot shot list live in `../store_assets/` (not inside this zip). Upload a square cover as the page icon on [hyakan.itch.io](https://hyakan.itch.io).
