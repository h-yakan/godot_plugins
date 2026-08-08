# scripts/

Skill plugin'inin runtime script'leri.

## Dosyalar

| Dosya | Sınıf | Rol |
|-------|-------|-----|
| `ga_skill.gd` | `GaSkill` | Skill davranış tabanı; `_do_activate`, toggle, cooldown |
| `ga_skill_host.gd` | `GaSkillHost` | Skill mount noktası + slot container'ları |
| `ga_skill_loader.gd` | `GaSkillLoader` | Sahne/id veya definition'dan instantiate |
| `ga_skill_bar.gd` | `GaSkillBar` | Controller'a bağlı skill bar |
| `ga_skill_slot.gd` | `GaSkillSlot` | Tek slot UI (cooldown, hotkey, tooltip) |
| `ga_skill_tooltip.gd` | `GaSkillTooltip` | Mouse takip eden tooltip paneli |

## Alt klasörler

- [core/](core/README.md) — tanım, controller, registry, context, cost
- [ui/](ui/README.md) — slot binding resource

## GaSkill override noktaları

| Metod | Ne zaman |
|-------|----------|
| `_check_can_activate(context)` | Cast öncesi koşul (range, stun…) |
| `_check_can_deactivate(context)` | Toggle kapatma koşulu |
| `_apply_passive(context)` | Pasif register'da |
| `_do_activate(context) -> bool` | Cast / toggle aç / aura başlat |
| `_do_deactivate(context) -> bool` | Toggle kapat |
| `_process_skill(delta, context)` | Aktifken tick |

`false` döndürmek cost ve cooldown harcatmez.
