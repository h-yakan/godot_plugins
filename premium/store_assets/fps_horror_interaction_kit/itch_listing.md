# FPS Horror Interaction Kit — itch.io listing

Paste the blocks below into the itch project page. Do not ship this file inside the customer zip.

**URL slug (suggested):** `fps-horror-interaction-kit`  
**Price:** `$12.99` (range $12–15)  
**Classification:** Game asset / tool / plugin  
**Kind of project:** Tools  
**Release status:** Released  
**Engine:** Godot 4.2+ (Forward Plus)

---

## Title

FPS Horror Interaction Kit

## Short description (itch limit ~50 characters)

```
Close your eyes. Cover your ears. Push the door.
```

Backup if the field is longer:

```
Godot 4 FPS horror kit: blink, ear cover, physics doors, grab, TV, notes.
```

## Tags

`godot` `godot4` `horror` `fps` `first-person` `addon` `plugin` `survival-horror` `gdscript` `3d`

## Genre

Physical Simulation, Survival, Horror

## Cover / icon

Square `logo.png` (recommended 512×512 or 630×500). Subject: first-person view, eyelids half-shut over a greybox hallway, one hand-shape vignette. No logos from other engines. Dark, readable at thumbnail size.

File ready: `logo.png` in this folder (also copied into the Pro zip root).

## Banner

Wide `banner.png` (16:9) for **Edit theme → Banner**. Same look as the cover: eyelid vignette, greybox hall, warm lamp at the end. No text. Upload under the project’s theme/customization, not as a screenshot.

---

## Description (HTML — paste into itch)

GIFs are hosted on the public repo [`h-yakan/itch-store-gifs`](https://github.com/h-yakan/itch-store-gifs) (`walk`, `read_note`, `open_door`, `grab_throw`, `inventory`, `watch_tv`). Itch’s own image upload often freezes GIFs; these `src`s are GitHub raw URLs.

```html
<p><strong>A first-person horror interaction kit for Godot 4.</strong> Not another inventory. Not another FPS controller with a sprint slider. This is the body-and-room layer from <em>Midnight Anxiety 2</em>: eyelids, covered ears, doors you actually push, objects you throw, a tape you seat in a deck, a TV you sit down to watch, notes that freeze the world.</p>

<p>Open the folder in Godot 4.2+, press Play. The greybox apartment is already wired.</p>

<p><img src="https://raw.githubusercontent.com/h-yakan/itch-store-gifs/main/walk.gif" alt="Walk the apartment" width="100%"></p>

<h2>Flagship mechanics</h2>
<ul>
  <li><strong>Eye blink</strong> — shader lids, vein afterimage, full blackout. The world can go dark because <em>you</em> closed them.</li>
  <li><strong>Ear cover</strong> — hold both ears. Vignette, stress shake, World-bus low-pass. Heartbeat and breath slots are ready for your streams.</li>
</ul>

<h2>The apartment</h2>

<p><strong>Physics doors</strong> — lean in, drag the mouse, let the door swing.</p>
<p><img src="https://raw.githubusercontent.com/h-yakan/itch-store-gifs/main/open_door.gif" alt="Physics doors" width="100%"></p>

<p><strong>Grab / throw</strong> — RigidBody3D follow-hand, then throw.</p>
<p><img src="https://raw.githubusercontent.com/h-yakan/itch-store-gifs/main/grab_throw.gif" alt="Grab and throw" width="100%"></p>

<p><strong>Placement slots</strong> — pick up the cassette, equip, seat it in the deck.</p>
<p><img src="https://raw.githubusercontent.com/h-yakan/itch-store-gifs/main/inventory.gif" alt="Placement slots" width="100%"></p>

<p><strong>Interactable TV</strong> — camera flies to the screen; SubViewport content (demo: lost signal → broadcast).</p>
<p><img src="https://raw.githubusercontent.com/h-yakan/itch-store-gifs/main/watch_tv.gif" alt="Interactable TV" width="100%"></p>

<p><strong>Notes</strong> — world document, fullscreen read, look and move locked until you close it.</p>
<p><img src="https://raw.githubusercontent.com/h-yakan/itch-store-gifs/main/read_note.gif" alt="Read notes" width="100%"></p>

<h2>What you are paying for</h2>
<p>Time. A packed <strong>GaHorrorPlayer</strong> prefab (controller + interaction ray + blink overlay + ear overlay), a playable greybox apartment, and <strong>Any Game Event Bus</strong> so notes, doors, TV, blink, and ears talk to each other without you writing the glue.</p>

<h2>Included addons</h2>
<ul>
  <li>FPS Horror Eye Blink</li>
  <li>FPS Horror Ear Cover</li>
  <li>FPS 3D Player Controller (Pro prefab)</li>
  <li>FPS 3D Interaction Ray</li>
  <li>3D FPS Physics Doors</li>
  <li>3D FPS Grabbable Physics</li>
  <li>3D Item Placement Slots</li>
  <li>3D Interactable TV Viewport</li>
  <li>Any Game Notes Documents</li>
  <li>Any Game Inventory (needed by placement)</li>
  <li>Any Game Event Bus (included, no extra purchase)</li>
</ul>

<h2>Requirements</h2>
<ul>
  <li>Godot <strong>4.2+</strong></li>
  <li>A <strong>World</strong> audio bus with a LowPass effect (demo ships the bus layout)</li>
</ul>

<h2>Support</h2>
<p>Priority support for Pro owners via the contact methods on this page. If a mechanic in the apartment demo does not behave, that is a ticket, not a forum post you hope someone sees.</p>

<p><em>MIT-licensed cores where noted inside the zip. You can drop the addons into an existing project or run the kit as its own Godot project.</em></p>
```

---

## Demo loop (for GIFs / trailer, ~45s)

1. Spawn in the hall. Lids half-closed, C/V.  
2. LMB the note. Freeze. Close.  
3. Push the living-room door (drag).  
4. Grab cassette, press 1, RMB the deck.  
5. Sit at the TV. Cut to ear-cover (Q+E) as the screen changes.  
6. Bedroom: grab a can, throw it at the wall.  
7. End card: title + Godot 4 + price.

## Screenshot shot list (minimum 5)

1. Hall, note on the table, lids slightly shut (hero).  
2. Hands-on-door, mouse-drag, look locked.  
3. Cassette in hand / equipped HUD, deck highlighted.  
4. TV close-up, camera parked on the screen, “NO SIGNAL” then the later broadcast.  
5. Ear-cover vignette + bedroom cans in mid-air.  
6. Optional: editor screenshot of `ga_horror_apartment.tscn` (sells “this is wired, not a code dump”).

Capture at 1920×1080. No debug collision shapes. HUD can stay; it is part of the product.

---

## Zip checklist

Include:

- `addons/`
- `examples/`
- `README.md`
- `LICENSE`
- `project.godot`
- `icon.svg`

Exclude:

- `premium/store_assets/`
- `.godot/`
- this markdown file

Suggested zip name: `fps-horror-interaction-kit-1.0.0.zip`

---

## After publish

Put the live itch URL into:

- `premium/fps_horror_interaction_kit/README.md`
- Lite READMEs that should funnel here
- Event Bus table (“Horror Kit”)
