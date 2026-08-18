# ga_force_skill

**Archetype:** Active · Timed cooldown · Bedelli (15 mana)

Area2D içindeki `RigidBody2D` gövdelere impulse uygular.

## Dosyalar

- `ga_force_skill.tres` — definition
- `ga_force_skill.tscn` — sahne (Area2D + Effect)
- `ga_force_skill.gd` — `GaForceSkill` extends `GaSkill`

## Export'lar

- `strength` — impulse büyüklüğü
- `impulse_direction` — varsayılan `Vector2.UP`
- `impact_distance` — reserved

Cast sırasında skill, caster pozisyonuna taşınır.
