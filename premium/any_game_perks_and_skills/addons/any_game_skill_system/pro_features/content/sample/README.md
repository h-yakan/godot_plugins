# content/sample/

LoL tarzı her archetype için örnek skill paketleri.

| Klasör | ID | Archetype |
|--------|-----|-----------|
| [ga_force_skill/](ga_force_skill/README.md) | `ga_force_skill` | Active, CD, mana cost |
| [ga_spam_pulse/](ga_spam_pulse/README.md) | `ga_spam_pulse` | Active, süresiz, bedelsiz |
| [ga_toggle_shield/](ga_toggle_shield/README.md) | `ga_toggle_shield` | Toggle, CD on deactivate |
| [ga_passive_momentum/](ga_passive_momentum/README.md) | `ga_passive_momentum` | Passive |
| [ga_always_aura/](ga_always_aura/README.md) | `ga_always_aura` | Always active aura |

## Referans dosyalar

| Dosya | Açıklama |
|-------|----------|
| `ga_simple_mana_provider.gd` | `GaSkillCostProvider` örneği (`caster.mana`) |

## Toplu kayıt

```gdscript
GaSkillCatalog.register_sample_skills(controller)
```
