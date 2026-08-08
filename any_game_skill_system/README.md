# Any Game Skill System

LoL tarzı archetype'ları destekleyen oyun-agnostik skill framework'ü (Godot 4.x).

## Klasörler

| Klasör | İçerik |
|--------|--------|
| [scripts/](scripts/README.md) | Runtime script'ler |
| [scripts/core/](scripts/core/README.md) | Tanım, controller, registry, cost provider |
| [scripts/ui/](scripts/ui/README.md) | Skill bar / slot UI |
| [scenes/](scenes/README.md) | Hazır sahneler |
| [content/](content/README.md) | Örnek skill içerikleri |

## Kurulum

1. `res://godot_plugins/any_game_skill_system/` veya `res://addons/any_game_skill_system/`
2. **Project → Project Settings → Plugins** → **Any Game Skill System**
3. Autoload gerekmez

## Hızlı başlangıç

Demo: [scenes/ga_skill_demo.tscn](scenes/ga_skill_demo.tscn)

```
GaSkillHost
├── GaSkillController
└── Slots/          ← skill sahneleri
CanvasLayer
└── GaSkillBar      ← controller_path ayarla
```

## Archetype özeti

| Tip | `kind` | Bar'dan cast? |
|-----|--------|---------------|
| Active (bedelli/bedelsiz) | `ACTIVE` | Evet |
| Süresiz | `ACTIVE` + `cooldown_mode=NONE` | Evet |
| Pasif | `PASSIVE` | Hayır |
| Sürekli aktif (aura) | `ALWAYS_ACTIVE` | Hayır |
| Toggle | `TOGGLE` | Evet (aç/kapa) |

Detaylı API: [scripts/core/README.md](scripts/core/README.md)

Ricochet orijinal dosyaları değiştirilmedi.
