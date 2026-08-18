# ga_always_aura

**Archetype:** Always active · Tick while active

Register'da otomatik başlar; bar'dan cast edilemez.

## Export'lar

- `dps` — saniye başına biriken aura hasarı sayacı

## Davranış

`_process_skill` her frame `context.data["aura_damage"]` biriktirir. Gerçek hasar uygulaması host oyuna bırakılır.

Bar'da aura slot olarak sürekli aktif renkte gösterilir.
