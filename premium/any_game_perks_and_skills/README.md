# Perks & Skills Kit (Pro)

> **Perks & Skills Kit** — Modular perk drafts (selection UI, sample pack, tests) plus a skill bar/host (slots, tooltips, sample abilities, demo scenes). Priority support for Pro owners.

Game-agnostic Godot 4 bundle. Lite cores stay on AssetLib; this zip is the Pro pair in one purchase.

Suggested store price: **$12.99**.

## Install

1. Copy `addons/modular_perks/`, `addons/any_game_skill_system/`, and `addons/any_game_event_bus/` into your project’s `res://addons/`. Skip Event Bus if you already have it from another Pro package.
2. Enable **Modular Perks**, **Any Game Skill System**, and **Any Game Event Bus** in **Project → Project Settings → Plugins**.

The marker plugin `any_game_perks_and_skills` is optional; it only names the bundle in the plugin list.

## What you get (Pro)

**Modular Perks**

- Draft / selection UI, perk cards, target pick
- Sample perk pack and effect handlers
- Tests for registry, draft service, and effect bus

**Any Game Skill System**

- Skill bar, slot, tooltip UI
- Sample skills (pulse, shield, aura, force, momentum)
- Demo host / bar scenes

**Event Bus** (included)

- Same hub shipped with every Pro zip. These two addons do not hard-depend on it yet; it still connects your other Midnight Anxiety plugins.

## Lite counterparts (AssetLib / GitHub)

Cores stay separate and MIT:

- `opensource/modular_perks` — definitions, registry, draft API (no UI)
- `opensource/any_game_skill_system` — kinds, definitions, controller, host, loader (no bar UI)

Drop this Pro zip over the Lite `addons/` folders. `core/` stays compatible; `pro_features/` appears.

## Dependencies

- None between the two systems. Use perks, skills, or both.

## Structure

```
addons/
  modular_perks/              # core + pro_features (UI, samples, tests)
  any_game_skill_system/      # core + pro_features (UI, samples, demo)
  any_game_event_bus/         # included free
  any_game_perks_and_skills/  # bundle marker plugin
```

---
Includes priority support for Pro owners.

## Itch.io

Store copy: `../store_assets/any_game_perks_and_skills/itch_listing.md` (not inside the customer zip). Upload `logo.png` as the page icon on [hyakan.itch.io](https://hyakan.itch.io).
