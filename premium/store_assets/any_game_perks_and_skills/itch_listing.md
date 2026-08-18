# Perks & Skills Kit — itch.io listing

Paste the blocks below into the itch project page. Do not ship this file inside the customer zip.

**URL slug (suggested):** `perks-and-skills-kit`  
**Price:** `$12.99`  
**Classification:** Game asset / tool / plugin  
**Kind of project:** Tools  
**Release status:** Released  
**Engine:** Godot 4.2+

This is the **second SKU** (after FPS Horror Interaction Kit). Different audience: roguelike / ARPG / ability-bar games, not horror.

---

## Title

Perks & Skills Kit

## Short description (itch limit ~50 characters)

```
Draft a perk. Slot a skill. Ship the run.
```

Backup if the field is longer:

```
Godot 4: modular perk drafts plus a skill bar, UI, and samples.
```

## Tags

`godot` `godot4` `addon` `plugin` `gdscript` `roguelike` `rpg` `skills` `perks` `ui`

## Genre

Role Playing, Survival

## Cover / icon

Square `logo.png` (512×512 or 630×500). Subject: a three-card perk draft next to a skill bar with cooldown sweeps. Readable at thumbnail size. Not the horror kit cover.

The zip already includes a placeholder `logo.png`; replace it before publish if you have a better mark.

---

## Description (HTML — paste into itch)

```html
<p><strong>Two systems, one purchase, for Godot 4.</strong> Lite cores are free on AssetLib. This Pro zip is the time you would spend wiring draft UI, a skill bar, tooltips, sample content, and tests.</p>

<h2>Modular Perks</h2>
<ul>
  <li>Definitions, registry, draft offers, runtime state, effect bus (same core as Lite)</li>
  <li><strong>Pro:</strong> selection screen, perk cards, target pick, sample pack, tests</li>
</ul>

<h2>Skill System</h2>
<ul>
  <li>Skill kinds, definitions, controller, host, loader (same core as Lite)</li>
  <li><strong>Pro:</strong> skill bar, slots, tooltips, sample abilities (pulse, shield, aura, force, momentum), demo scenes</li>
</ul>

<h2>What you are paying for</h2>
<p>Time. Drop <code>pro_features/</code> on top of the Lite addons you already installed. Cores stay compatible. <strong>Any Game Event Bus</strong> is included so the rest of the Midnight Anxiety suite can talk to your project; these two addons also run standalone.</p>

<h2>Included addons</h2>
<ul>
  <li>Modular Perks (Pro)</li>
  <li>Any Game Skill System (Pro)</li>
  <li>Any Game Event Bus (included, no extra purchase)</li>
</ul>

<h2>Requirements</h2>
<ul>
  <li>Godot <strong>4.2+</strong></li>
  <li>Optional: the MIT Lite packages from AssetLib / GitHub if you want to prototype the API first</li>
</ul>

<h2>Support</h2>
<p>Priority support for Pro owners via the contact methods on this page.</p>
```

---

## Screenshot shot list (minimum 5)

1. Perk draft screen, three cards (hero).  
2. Perk card hover / target pick.  
3. Skill bar with cooldown sweep, tooltip open.  
4. Skill demo scene running (pulse / shield).  
5. Editor: `GaSkillDefinition` / `PerkDefinition` in the Inspector.  
6. Optional: Lite vs Pro folder tree (`core/` same, `pro_features/` only in Pro).

Capture at 1920×1080. No debugger spam.

---

## Zip checklist

Include:

- `addons/` (`modular_perks`, `any_game_skill_system`, `any_game_event_bus`, `any_game_perks_and_skills`)
- `README.md`
- `LICENSE`
- `logo.png`

Exclude:

- `premium/store_assets/`
- `.godot/`
- this markdown file
- the old standalone `premium/modular_perks` and `premium/any_game_skill_system` folders (removed)

Suggested zip name: `perks-and-skills-kit-1.0.0.zip`

---

## After publish

Put the live itch URL into:

- `premium/any_game_perks_and_skills/README.md`
- `opensource/modular_perks/README.md`
- `opensource/any_game_skill_system/README.md`
