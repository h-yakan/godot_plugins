# scripts/ui/

Skill bar UI binding resource'ları.

## Dosyalar

| Dosya | Sınıf | Rol |
|-------|-------|-----|
| `ga_skill_slot_binding.gd` | `GaSkillSlotBinding` | Slot index → skill_id + input_action eşlemesi |

## Kullanım

`GaSkillBar.slot_bindings` dizisine resource ekle:

```gdscript
var binding := GaSkillSlotBinding.new()
binding.skill_id = "ga_force_skill"
binding.input_action = &"PrimarySkill"
binding.slot_index = 0
bar.slot_bindings = [binding]
bar.bind_skills()
```

Alternatif: her `GaSkillSlot` node'unda doğrudan `skill_id` export'u (önerilen).
