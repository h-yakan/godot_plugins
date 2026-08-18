# ga_toggle_shield

**Archetype:** Toggle · CD on deactivate · Bedelli (20 mana) · Tick while active

Açıkken `context.data["damage_reduction"]` uygular; kapalıyken siler.

## Export'lar

- `damage_reduction` — varsayılan `0.25`

## Cooldown

`cooldown_trigger = ON_DEACTIVATE` — toggle kapatıldığında 3s CD başlar.

Demo'da `SecondarySkill` (W) ile bağlı.
