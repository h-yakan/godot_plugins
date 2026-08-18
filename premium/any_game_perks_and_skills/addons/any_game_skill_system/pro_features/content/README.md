# content/

Örnek skill içerikleri ve referans implementasyonlar.

## Klasörler

| Klasör | Archetype |
|--------|-----------|
| [sample/](sample/README.md) | Tüm örnek skill'ler |

## Yeni skill paketi ekleme

```
content/my_pack/my_skill/
  my_skill.tres    ← GaSkillDefinition
  my_skill.tscn    ← GaSkill scene
  my_skill.gd      ← davranış script'i
```

Runtime yükleme:

```gdscript
host.load_skill("my_skill", NodePath("Slots"), "res://.../content/my_pack")
# veya
controller.register_definitions_from_directory("res://.../content/my_pack")
controller.instantiate_and_register(definition, host, NodePath("Slots"))
```
