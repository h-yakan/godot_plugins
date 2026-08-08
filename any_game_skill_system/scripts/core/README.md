# scripts/core/

Skill sisteminin çekirdek API'si: data, orchestration, kaynak maliyeti.

## Dosyalar

| Dosya | Sınıf | Rol |
|-------|-------|-----|
| `ga_skill_kinds.gd` | `GaSkillKinds` | `Kind`, `CooldownMode`, `CostMode`, `CooldownTrigger` enum'ları |
| `ga_skill_definition.gd` | `GaSkillDefinition` | `.tres` skill metadata |
| `ga_skill_context.gd` | `GaSkillContext` | caster, target, world, cost_provider, data |
| `ga_skill_registry.gd` | `GaSkillRegistry` | Definition kayıt ve dizin tarama |
| `ga_skill_controller.gd` | `GaSkillController` | Register, cast, toggle, sinyal hub |
| `ga_skill_cost_provider.gd` | `GaSkillCostProvider` | Bedelli skill kaynak köprüsü (override et) |
| `ga_skill_catalog.gd` | `GaSkillCatalog` | Sample definition yükleme helper |

## GaSkillDefinition alanları

```gdscript
kind                  # ACTIVE | PASSIVE | TOGGLE | ALWAYS_ACTIVE
cooldown_mode         # TIMED | NONE
cost_mode             # NONE | RESOURCE
cooldown_trigger      # ON_ACTIVATE | ON_DEACTIVATE | NEVER
tick_while_active
cooldown
resource_id           # &"mana", &"energy" …
resource_cost
pay_cost_on_toggle_off
```

## Aktivasyon akışı

```
UI / Input
  → GaSkillController.request_activation()
    → GaSkill.try_activate()
      → cost (provider) → cooldown → _do_activate / _do_deactivate
```

## Cost provider

```gdscript
extends GaSkillCostProvider

func get_amount(caster: Node, resource_id: StringName) -> float:
    return caster.mana if resource_id == &"mana" else INF

func _apply_spend(caster: Node, resource_id: StringName, amount: float) -> void:
    caster.mana -= amount
```

```gdscript
controller.set_cost_provider(MyProvider.new())
controller.caster_path = NodePath("../Player")
```

## ActivationResult

`SUCCESS`, `FAILED`, `ON_COOLDOWN`, `DISABLED`, `INSUFFICIENT_COST`, `NOT_CASTABLE`, `NOT_TOGGLED`, `NOT_FOUND`

## Controller sinyalleri

`skill_registered`, `skill_activated`, `skill_deactivated`, `skill_toggled_on`, `skill_toggled_off`, `skill_passive_applied`, `skill_cooldown_started`, `skill_cooldown_finished`, `skill_cost_spent`, `skill_cost_insufficient`, `skill_activation_requested`
