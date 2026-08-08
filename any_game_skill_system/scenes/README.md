# scenes/

Hazır skill sistemi sahneleri.

## Sahneler

| Sahne | Açıklama |
|-------|----------|
| `ga_skill_demo.tscn` | Tam demo: host + bar + mana provider |
| `ga_skill_demo.gd` | Demo kök script (100 mana, cost provider bağlar) |
| `ga_skill_host.tscn` | `GaSkillHost` + `GaSkillController` + örnek skill'ler |
| `ga_skill_bar.tscn` | 5 slot'lu bar (primary/secondary/tertiary/passive/aura) |
| `ga_skill_slot.tscn` | Tek skill butonu (cooldown, hotkey, tooltip) |

## Demo kurulumu

1. `ga_skill_demo.tscn` instance et
2. InputMap: `PrimarySkill` (Q), `SecondarySkill` (W), `TertiarySkill` (E)
3. Oyna

## Manuel kurulum

```
GameRoot
├── GaSkillHost          ← ga_skill_host.tscn
└── CanvasLayer
    └── GaSkillBar       ← ga_skill_bar.tscn
        controller_path = ../../GaSkillHost/GaSkillController
```

Her `GaSkillSlot` için `skill_id` ve isteğe bağlı `input_action` ayarla.
