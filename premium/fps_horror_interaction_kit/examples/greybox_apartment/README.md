# Greybox apartment

Playable Pro demo for the FPS Horror Interaction Kit.

Open the kit folder as a Godot 4.2+ project. Main scene is this apartment.

## Rooms

- **Hall** — note on the table; doors into living room and bedroom
- **Living room** — cassette, tape deck (placement slot), TV
- **Bedroom** — two grabbable cans

## Wiring to copy

| Node | Script | Interact |
|------|--------|----------|
| `Hallway/Note` | `GaNoteInteractable` | LMB reads |
| `Hallway/LivingDoor/pivot` | `GaPhysicsDoorPivot` (via `GaInteractForward` on Body) | LMB, drag mouse |
| `LivingRoom/CassettePickup` | `GaWorldPickup` | LMB into inventory |
| `LivingRoom/TapeSlot` | `GaPlacementArea` | RMB with cassette equipped |
| `LivingRoom/TV` | `GaInteractableTV` | LMB sit, RMB leave |
| `Bedroom/CanA` | `GaGrabbable` | LMB grab, RMB throw |

The horror player prefab already has blink + ear overlays and an interaction ray with `collide_with_areas` so placement Areas are hittable.
