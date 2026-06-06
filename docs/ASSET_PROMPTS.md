# Fingerfist — Asset-Prompt-Liste

> **Produktions-Roadmap für alle Sprites & Audio.** Stand: 2026-06-04.
> Aktuell ist **jedes** Asset nur ein Platzhalter (Sprites = 1309-Byte-Farbquadrate, Audio =
> 105-Byte-Text-Fakes). Diese Liste ersetzt sie Set für Set: pro Eintrag Zielpfad(e), empfohlene
> Quell-Auflösung, Frame-Spec und ein **copy-paste-fertiger Prompt**.

---

## 0. Globale Vorgaben (gelten für jeden Sprite-Prompt)

**Stil-Anker:** *One Finger Death Punch × Hyper Light Drifter* — kontrastreiche Pixel-Art, kräftige
lesbare Silhouetten, dunkles Höhlen-Setting (Thema: Aufstieg aus einer Höhle), satte Neon-Akzente bei
Treffern/FX.

**Konventionen (in jedem Prompt mitdenken, hier einmal definiert):**
- **Pixel-Art, 1× Pixel-Dichte, kein Anti-Aliasing**, harte Kanten, klare Outline.
- **Transparenter Hintergrund** (Ausnahme: Backgrounds & Wall-Backgrounds = deckend).
- **Sprite-Sheet horizontal**, Frames links→rechts, gleichmäßige Zellengröße, Pivot zentriert.
- **Begrenzte Palette** (~8–16 Farben), konsistent pro Gegner-/Skin-Familie.
- **Seitenansicht** (Gameplay läuft 1-dimensional entlang der X-Achse; Spieler rechts, Gegner kommen
  von links).
- **Größen** unten sind empfohlene *Quell*-Auflösungen. Aktuelle Platzhalter: 96×96 (Fäuste 64×64).
  Der Import-Scale ist in Godot frei justierbar; die Kollisions-Hitboxen (CLAUDE.md §16) bleiben
  unberührt — Sprites dürfen also größer/detaillierter sein als die Hitbox.

**Generator-Hinweis:** Prompts sind für Pixel-Art-Generatoren formuliert (z.B. Retro Diffusion /
PixelLab). Bei Sheets das Frame-Layout explizit fordern; bei Einzel-Icons „single sprite, centered".

---

## Status-Übersicht

| ID | Set | Pfad(e) | Maße (Quelle) | Frames | Status |
|---|---|---|---|---|---|
| A1 | Backgrounds | `assets/sprites/backgrounds/level_{1..7}_bg.png` | 1280×720 | 1×7 | ☐ |
| A2 | Walls | `assets/sprites/walls/level_{1..7}/*` | 256×512 (Wand), 1280×720 (BG) | 3 States ×7 | ☐ |
| A3 | Coins | `assets/sprites/coins/<tier>/coin_frame_{00..03}.png` | 32×32 | 4 ×4 Tiers | ☐ |
| A4 | Insekt | `assets/sprites/enemies/insect/<color>/insect_frame_{00..03}.png` | 48×48 | 4 ×3 Farben | ☐ |
| A5 | Vasenmonster | `assets/sprites/enemies/vase/*` | 64×80 | 2+5+3 | ☐ |
| A6 | Feuerteufel | `assets/sprites/enemies/fire_devil/*` | 64×64 | 4+2 | ☐ |
| A7 | Projektil | `assets/sprites/enemies/projectile/projectile_{00..03}.png` | 24×16 | 4 | ☐ |
| A8 | Spieler-Fäuste | `assets/sprites/player/<skin>/fist_frame_{00..07}.png` | 64×64 | 8 ×8 Skins | ☐ |
| A9 | UI-Buttons | `assets/sprites/ui/button_{normal,hover,pressed,disabled}.png` | 64×64 (9-slice) | 4 States | ☐ |
| A10 | UI-Icons | `assets/sprites/ui/{coin,combo,hp}_icon.png` | 32×32 | 3 | ☐ |
| A11 | UI-Panels | `assets/sprites/ui/{panel_bg,panel_border}.png` | 64×64 (9-slice) | 2 | ☐ |
| A12 | Item-Icons | `assets/sprites/ui/items/*.png` | 48×48 | 8 | ☐ |
| B1 | Musik | `assets/audio/music/*.ogg` | — | 5 Tracks | ☐ |
| B2 | Punches | `assets/audio/sfx/punch_{01..10}.ogg` | — | 10 | ☐ |
| B3 | Insekt-Tod | `assets/audio/sfx/insect_death_{01..03}.ogg` | — | 3 | ☐ |
| B4 | Vase-SFX | `assets/audio/sfx/vase_*.ogg` | — | 6 | ☐ |
| B5 | Feuerteufel-SFX | `assets/audio/sfx/{projectile_*,fire_extinguish_*,meteor_rain}.ogg` | — | 7 | ☐ |
| B6 | Spieler Hurt/Death | `assets/audio/sfx/{hurt_01..03,death}.ogg` | — | 4 | ☐ |
| B7 | Coins-SFX | `assets/audio/sfx/{coin_bounce,coin_collect_01..03}.ogg` | — | 4 | ☐ |
| B8 | Wall-SFX | `assets/audio/sfx/{wall_crack_01..02,wall_break}.ogg` | — | 3 | ☐ |
| B9 | UI-SFX | `assets/audio/sfx/{button_*,menu_*,shop_*}.ogg` | — | 6 | ☐ |
| B10 | Item-FX-SFX | `assets/audio/sfx/{fire_shield,thunder_chain,slow_motion,whoosh}.ogg` | — | 4 | ☐ |
| V1 | Punch Hit-Spark | `assets/sprites/vfx/hit_spark/hit_spark_{00..05}.png` | 48×48 | 6 | ☐ |
| V2 | Insekt-Tod-FX | `assets/sprites/vfx/death_insect/death_insect_{00..03}.png` | 48×48 | 4 | ☐ |
| V3 | Vase-Shatter-FX | `assets/sprites/vfx/death_vase/death_vase_{00..05}.png` | 64×80 | 6 | ☐ |
| V4 | Feuerteufel-Tod-FX | `assets/sprites/vfx/death_fire/death_fire_{00..05}.png` | 64×64 | 6 | ☐ |
| V5 | Wand-Treffer-FX | `assets/sprites/vfx/wall_hit/wall_hit_{00..05}.png` | 64×64 | 6 | ☐ |
| V6 | Wand-Break-FX | `assets/sprites/vfx/wall_break/wall_break_{00..07}.png` | 256×512 | 8 | ☐ |
| V7 | Coin-Bounce-Dust | `assets/sprites/vfx/coin_dust/coin_dust_{00..03}.png` | 32×32 | 4 | ☐ |
| V8 | Coin-Collect-Pop | `assets/sprites/vfx/coin_pop/coin_pop_{00..04}.png` | 48×48 | 5 | ☐ |
| V9 | Projektil-Spawn-Flash | `assets/sprites/vfx/proj_spawn/proj_spawn_{00..03}.png` | 32×32 | 4 | ☐ |
| V10 | Projektil-Impact | `assets/sprites/vfx/proj_hit/proj_hit_{00..04}.png` | 48×48 | 5 | ☐ |
| V11 | Item Shockwave-Ring | `assets/sprites/vfx/fx_shockwave/fx_shockwave_{00..05}.png` | 128×128 | 6 | ☐ |
| V12 | Item Chain-Lightning | `assets/sprites/vfx/fx_thunder/fx_thunder_{00..04}.png` | 128×64 | 5 | ☐ |
| V13 | Item Meteor-Impact | `assets/sprites/vfx/fx_meteor/fx_meteor_{00..07}.png` | 128×128 | 8 | ☐ |
| V14 | Item Time-Ripple | `assets/sprites/vfx/fx_slowmo/fx_slowmo_{00..04}.png` | 256×256 | 5 | ☐ |
| V15 | Item Fire-Shield-Burst | `assets/sprites/vfx/fx_shield/fx_shield_{00..05}.png` | 96×96 | 6 | ☐ |
| V16 | Player-Hurt-Flash | `assets/sprites/vfx/hurt_flash/hurt_flash_{00..03}.png` | 64×64 | 4 | ☐ |

---

# Teil A — Sprites

## A1 · Backgrounds (Level 1–7)

**Pfade:** `assets/sprites/backgrounds/level_1_bg.png` … `level_7_bg.png`
**Quell-Größe:** 1280×720 · **Frames:** 1 pro Level · **Hintergrund:** deckend

**Basis-Prompt:**
> Pixel-art background, 1280x720, side-scrolling arena backdrop for a cave-ascent brawler. Dark
> moody cavern depths, dramatic depth layering (far parallax silhouette + mid wall + foreground floor
> line), limited palette with cool shadows and a single warm light source, subtle volumetric glow, no
> characters, no UI. Style: One Finger Death Punch meets Hyper Light Drifter. Clean readable shapes,
> 1x pixel density, no anti-aliasing.

**Pro-Level-Variante (Aufstieg aus der Höhle — von tief/dunkel zu hoch/hell):**
- **L1** – tiefste Höhle, fast schwarz, glimmende Kristalladern, türkise Akzente.
- **L2** – feuchte Tropfstein-Grotte, Pfützen-Reflexe, grünliches Moos.
- **L3** – unterirdischer Pilzwald, biolumineszente Sporen, violette Akzente.
- **L4** – Lava-Spalten/Magma-Adern, glühendes Orange, Hitzeflimmern.
- **L5** – verlassene Bergmine, Holzgerüste, Schienen, staubiges Braun.
- **L6** – Kristallkaverne, prismatische Reflexe, kaltes Blau-Weiß.
- **L7** – Höhlenausgang zur Oberfläche, Tageslicht-Strahl von oben, warmer Sonnen-Schein (Endless).

---

## A2 · Walls (Level 1–7)

**Pfade je Level `<L>`:**
`assets/sprites/walls/level_<L>/wall_intact.png`, `wall_damaged.png`, `wall_critical.png`,
`background.png`
**Quell-Größe:** Wand 256×512 (vertikale Barriere), `background.png` 1280×720 · **States:** 3
(intakt → beschädigt → kritisch, jeweils stärkere Risse/Bröckeln)

**Prompt (3-State-Set):**
> Pixel-art breakable wall barrier, 256x512, vertical blocking structure on the left side of an arena,
> transparent background. Three damage states as separate frames: (1) intact and solid, (2) cracked
> with chunks missing and dust, (3) critical — heavily shattered, glowing stress fractures, about to
> collapse. Consistent silhouette across all three so they swap cleanly. Material matches the level
> biome. Style: One Finger Death Punch × Hyper Light Drifter, bold outline, limited palette, 1x pixel
> density, no anti-aliasing.

**Material pro Level:** L1 roher Fels · L2 nasser Stein · L3 pilzüberwucherter Stein · L4 vulkanisches
Obsidian-Gestein (glüht in „critical") · L5 verbarrikadiertes Holz+Metall · L6 Kristall · L7
verwitterter Fels mit Lichtdurchbruch. `background.png` analog zu A1 als Wand-Hinterlegung.

---

## A3 · Coins (4 Tiers)

**Pfade:** `assets/sprites/coins/<tier>/coin_frame_00.png … 03.png` — `<tier>` ∈ bronze, silver,
gold, platinum
**Quell-Größe:** 32×32 · **Frames:** 4 (Rotations-Loop) · **Hitbox:** r=6 (§16), Collect-SFX „pling"

**Prompt:**
> Pixel-art spinning coin, 32x32 per frame, 4-frame horizontal sheet showing a smooth 360° rotation
> (full face → thin edge → full face → thin edge), transparent background. Chunky readable shape, soft
> specular highlight that travels with the spin, subtle sparkle. Style consistent with a cave-brawler
> HUD pickup, bold outline, 1x pixel density, no anti-aliasing.

**Tier-Farbe:** bronze = warmes Kupferbraun · silver = kühles Hellgrau mit Blaustich · gold = sattes
Goldgelb · platinum = blass weiß-cyan, dezent leuchtend (höchster Wert).

---

## A4 · Insekt (3 Farben)

**Pfade:** `assets/sprites/enemies/insect/<color>/insect_frame_00.png … 03.png` — `<color>` ∈ red,
green, blue
**Quell-Größe:** 48×48 · **Frames:** 4 (Lauf-Loop) · **Hitbox:** r=12 (§16), klein & schnell (§4)

**Prompt:**
> Pixel-art small skittering insect enemy, 48x48 per frame, 4-frame horizontal run-cycle loop, side
> view facing right (it charges toward the player), transparent background. Aggressive low silhouette,
> many fast legs, mandibles, glossy carapace. Reads instantly as a fast weak swarm enemy. Style: One
> Finger Death Punch × Hyper Light Drifter, bold outline, limited palette, 1x pixel density, no
> anti-aliasing.

**Farb-Variante:** red = aggressiv warm (rot/orange Panzer) · green = giftig (grün, leicht
schleimig) · blue = schnellste Variante (kühles Blau, elektrische Akzente). Tod-FX siehe §17 (4
Frames Auflösung) — optional als separates Death-Sheet nachreichbar.

---

## A5 · Vasenmonster

**Pfade:** `assets/sprites/enemies/vase/vase_idle_00.png…01`, `vase_windup_00.png…04`,
`vase_attack_00.png…02`
**Quell-Größe:** 64×80 · **Frames:** idle 2 · windup 5 · attack 3 · **Hitbox:** 32×40 (§16),
Schlagwarnung ~0.35s (§4)

**Prompt (3 Animationen, ein Set, gleiche Palette/Pivot):**
> Pixel-art "vase monster" enemy, 64x80, transparent background, side view. A heavy living ceramic
> vessel with stubby arms, slower and tankier than the insects. Three labeled animations as horizontal
> strips sharing one pivot and palette:
> - **idle** (2 frames): gentle breathing/wobble.
> - **windup** (5 frames): clearly telegraphed attack charge — leans back, cracks glow, ~0.35s read so
>   the player can react.
> - **attack** (3 frames): forward smash/lunge, impact pose.
> Bold outline, limited earthy ceramic palette with a warning glow on windup, 1x pixel density, no
> anti-aliasing.

---

## A6 · Feuerteufel

**Pfade:** `assets/sprites/enemies/fire_devil/fire_idle_00.png…03`, `fire_charge_00.png…01`
**Quell-Größe:** 64×64 · **Frames:** idle 4 · charge 2 · **Hitbox:** r=14 (§16), stationär/ranged,
schießt Projektile (§4)

**Prompt:**
> Pixel-art "fire devil" ranged enemy, 64x64, transparent background, side view facing right. A small
> floating/hovering fiery imp that stays at range and hurls projectiles. Two animations sharing palette
> and pivot:
> - **idle** (4 frames): hovering, flickering flames, embers rising.
> - **charge** (2 frames): winding up a projectile — gathers a bright fireball, eyes flare as a clear
>   tell.
> Hot ember palette (deep red → orange → yellow core) over a dark body, bold outline, 1x pixel density,
> no anti-aliasing.

---

## A7 · Projektil (Feuerball)

**Pfade:** `assets/sprites/enemies/projectile/projectile_00.png … 03.png`
**Quell-Größe:** 24×16 · **Frames:** 4 (Flug-Loop) · **Hitbox:** 12×8 (§16), Speed 7px/ms, 1 HP
Schaden (§4), kein Tracking

**Prompt:**
> Pixel-art flying fireball projectile, 24x16 per frame, 4-frame horizontal loop, travelling
> left-to-right with a short trailing flame tail, transparent background. Bright yellow-white hot core,
> orange-red flames, tiny ember sparks. Compact and highly readable against dark backgrounds. Bold
> outline, 1x pixel density, no anti-aliasing.

---

## A8 · Spieler-Fäuste (8 Skins)

**Pfade:** `assets/sprites/player/<skin>/fist_frame_00.png … 07.png` — `<skin>` ∈ default, fire, ice,
crystal, gold, metal, neon, shadow
**Quell-Größe:** 64×64 · **Frames:** 8 (Punch 140ms, §17: Hit Frame 3–5, SFX Frame 2, FX Frame 7) ·
**Hitbox:** r=16 (§3/§16)

**Basis-Prompt:**
> Pixel-art oversized fist (the player's weapon), 64x64 per frame, 8-frame horizontal punch sequence:
> wind-up → thrust forward → full extension impact (frames 3–5 are the hit) → recoil back to rest,
> facing right, transparent background. Exaggerated arcade "one-finger death punch" feel, strong motion,
> clean knuckle silhouette, impact flash on the extension frames. Bold outline, 1x pixel density, no
> anti-aliasing.

**Skin-Varianten (gleiche Animation, nur Material/Palette):**
- **default** – nackte Faust / schlichter Handschuh, neutrale Hauttöne.
- **fire** – brennender Handschuh, Flammen umzüngeln die Knöchel, Glut-Trail beim Impact.
- **ice** – frostbedeckte Faust, Eiskristalle, kühler Dampf, hellblaue Akzente.
- **crystal** – durchscheinende Kristallfaust, prismatische Reflexe, violett-cyan.
- **gold** – polierte goldene Faust, satte Highlights, kleine Glanzfunken.
- **metal** – schwere Stahl-Eisenhandschuh-Faust, Nieten, kühles Grau, harte Specular-Kante.
- **neon** – cyberpunk-Glühfaust, leuchtende Neon-Outlines (magenta/cyan), Bloom beim Impact.
- **shadow** – dunkle Rauchfaust, schattige Schwaden, schwache violette Innenglut.

---

## A9 · UI-Buttons

**Pfade:** `assets/sprites/ui/button_normal.png`, `button_hover.png`, `button_pressed.png`,
`button_disabled.png`
**Quell-Größe:** 64×64, als **9-slice** dehnbar · **States:** 4

**Prompt:**
> Pixel-art UI button, 64x64, designed for 9-slice stretching (solid uniform borders, no corner art
> that breaks when scaled), transparent background. Four states sharing one shape: **normal** (solid,
> inviting), **hover** (brighter rim / subtle glow), **pressed** (inset/darker, pushed-in look),
> **disabled** (desaturated, dimmed). Cave-brawler menu aesthetic, stone/metal frame with a clean
> readable inner field, bold outline, 1x pixel density, no anti-aliasing.

---

## A10 · UI-Icons

**Pfade:** `assets/sprites/ui/coin_icon.png`, `combo_icon.png`, `hp_icon.png`
**Quell-Größe:** 32×32 · **Einzel-Icons**, transparent

**Prompt (3 Einzel-Icons, gemeinsamer Stil):**
> Three pixel-art HUD icons, 32x32 each, single centered sprite, transparent background, matching style:
> - **coin_icon** – a single gold coin, front face, sparkle highlight.
> - **combo_icon** – a stylized combo/streak symbol (e.g. a flaming chevron "x" or rising spark) that
>   reads as "multiplier".
> - **hp_icon** – a heart for the life display (used filled = red, empty = greyed by code, so keep it
>   tintable/clean).
> Bold outline, limited palette, crisp at small size, 1x pixel density, no anti-aliasing.

---

## A11 · UI-Panels

**Pfade:** `assets/sprites/ui/panel_bg.png`, `panel_border.png`
**Quell-Größe:** 64×64, als **9-slice** · **Frames:** 2 (Füllung + Rahmen)

**Prompt:**
> Pixel-art UI panel set for 9-slice stretching, 64x64 each, transparent background:
> - **panel_bg** – a semi-opaque dark stone/parchment fill with subtle texture, uniform tileable
>   center.
> - **panel_border** – a decorative frame/border overlay (carved stone or runed metal) with clean
>   uniform edges and corners that survive stretching.
> Cave-brawler menu aesthetic, cohesive with the buttons (A9), bold outline, 1x pixel density, no
> anti-aliasing.

---

## A12 · Item-Icons (8)

**Pfade:** `assets/sprites/ui/items/<id>.png` · **Quell-Größe:** 48×48 · **Einzel-Icons**, transparent
**Quelle der Bedeutung:** `autoload/SaveSystem.gd` → `const ITEMS`

**Basis-Prompt:**
> Pixel-art shop item icon, 48x48, single centered emblem on a subtle dark rounded badge, transparent
> background, transparent outside the badge. Bold instantly-readable symbol, glossy highlight, limited
> palette, cohesive set. Style: cave-brawler shop UI, 1x pixel density, no anti-aliasing.

**Motiv je Datei (Effekt → Symbol):**
- **greed_magnet.png** – „Greed Magnet" (zieht Coins an): Hufeisenmagnet, der Goldmünzen anzieht.
- **iron_knuckles.png** – „Iron Knuckles" (Knockback): metallener Schlagring/Eisenhandschuh.
- **shockwave_fist.png** – „Shockwave Fist" (Attack-Radius ×2): Faust mit konzentrischer Schockwelle.
- **time_crystal.png** – „Time Crystal" (Slow-Motion bei Combo 10): leuchtender Zeit-/Sanduhr-Kristall.
- **golem_skin.png** – „Golem Skin / Golem's Blessing" (+Leben / Wand-Regen): steinerner Golem-Schild
  bzw. Felsherz.
- **fire_shield.png** – „Fire Shield" (negiert 1 Projektil): flammender Rundschild.
- **thunder_charge.png** – Blitz-/Donner-Ladung: geballte Faust mit Blitzbogen (Combo-Reward-Motiv).
- **call_of_wrath.png** – „Call of Wrath" (Meteor + ×2 Score bei 30+ Combo): herabstürzender Meteor
  über einer Faust, ultimatives, episches Symbol.

---

# Teil B — Audio

> Pixel-Art-Stil entfällt; Prompts sind **Sound-Design-Briefs** für Audio-Generatoren (Suno für Musik;
> ElevenLabs SFX / sfxr / Bfxr für Effekte). Soll-Vorgaben aus CLAUDE.md §18/§19. Alle SFX: kurz,
> trocken, mobil-tauglich gemischt, leichte Variationen damit Wiederholung nicht nervt. Format-Ziel:
> `.ogg`.

## B1 · Musik (5 Tracks)

**Pfade:** `assets/audio/music/main_theme.ogg`, `combat_level_1.ogg`, `combat_level_2.ogg`,
`combat_boss.ogg`, `shop_theme.ogg` · loopbar.

- **main_theme** – Hauptmenü. Tribal-Drums + Elektro, atmosphärisch und einladend, mittleres Tempo,
  Höhlen-/Aufstiegs-Mystik, baut Vorfreude auf. Loop ~60–90s.
- **combat_level_1** – In-Game Level 1–3. Treibend, hohes Tempo, perkussiv, fokussiert; trägt das
  schnelle Tap-Combat ohne zu ermüden. Loop ~60s.
- **combat_level_2** – In-Game Level 4–6. Intensiver, dichtere Percussion, mehr Bass/Synth-Energie als
  Level 1. Loop ~60s.
- **combat_boss** – Boss/Mixed-Wave (ab Level 6/Endless). Episch, bedrohlich, große Drums, hohe
  Spannung, härtere Synths. Loop ~60–80s.
- **shop_theme** – Shop. Entspanntes Chiptune, verspielt, warm, niedriges Tempo, Belohnungs-/
  Stöber-Gefühl. Loop ~40–60s.

## B2 · Punches (10 Variationen)

**Pfade:** `assets/audio/sfx/punch_01.ogg … punch_10.ogg`
> 10 short punchy melee impact hits, ~120–180ms each, dry and weighty with a meaty low thump + crisp
> transient, subtle variations in pitch/texture across the set so rapid repeated taps feel varied. Arcade
> brawler one-hit-kill feel.

## B3 · Insekt-Tod (3)

**Pfade:** `assets/audio/sfx/insect_death_01.ogg … 03.ogg`
> 3 short squishy/crunchy insect-death sounds, ~150ms, a small wet pop + chitinous crack, slightly
> different each, satisfying and low-key (these trigger constantly).

## B4 · Vasenmonster-SFX (6)

**Pfade:** `assets/audio/sfx/vase_windup.ogg`, `vase_attack_01.ogg`, `vase_attack_02.ogg`,
`vase_break_01.ogg … 03.ogg`
> - **vase_windup** (~0.35s): a telegraphed ceramic "charging"/groaning rise that warns the player.
> - **vase_attack** (×2, ~150ms): a heavy ceramic smash/swoosh on the strike.
> - **vase_break** (×3, ~200ms): satisfying shattering pottery, varied debris, on death.

## B5 · Feuerteufel-SFX (7)

**Pfade:** `assets/audio/sfx/projectile_charge.ogg`, `projectile_fire.ogg`, `projectile_hit.ogg`,
`fire_extinguish_01.ogg … 03.ogg`, `meteor_rain.ogg`
> - **projectile_charge** (~0.4s): rising fiery whoosh as the devil gathers a fireball.
> - **projectile_fire** (~150ms): sharp flaming launch.
> - **projectile_hit** (~150ms): fiery impact/burst when it lands.
> - **fire_extinguish** (×3, ~200ms): the devil dying — a hiss/snuff of flame going out, varied.
> - **meteor_rain** (~1–1.5s): the "Call of Wrath" ultimate — multiple meteors screaming down and
>   impacting, dramatic.

## B6 · Spieler Hurt/Death (4)

**Pfade:** `assets/audio/sfx/hurt_01.ogg … 03.ogg`, `death.ogg`
> - **hurt** (×3, ~150ms): short pained grunt/impact when the player takes damage, varied.
> - **death** (~0.8s): a heavier defeat sting / final hit, clearly signals game over.

## B7 · Coins-SFX (4)

**Pfade:** `assets/audio/sfx/coin_bounce.ogg`, `coin_collect_01.ogg … 03.ogg`
> - **coin_bounce** (~80ms): a light metallic "tink" as a coin bounces on the ground.
> - **coin_collect** (×3, ~120ms): a bright rewarding "pling"/chime on pickup, varied pitch so combos
>   of pickups arpeggiate pleasantly.

## B8 · Wall-SFX (3)

**Pfade:** `assets/audio/sfx/wall_crack_01.ogg`, `wall_crack_02.ogg`, `wall_break.ogg`
> - **wall_crack** (×2, ~200ms): stone cracking/stress as the wall takes score damage.
> - **wall_break** (~1s): big satisfying wall collapse/explosion on level-clear — triumphant, the
>   level-break payoff.

## B9 · UI-SFX (6)

**Pfade:** `assets/audio/sfx/button_click.ogg`, `button_hover.ogg`, `menu_open.ogg`, `menu_close.ogg`,
`shop_buy.ogg`, `shop_error.ogg`
> Clean, soft, non-fatiguing UI sounds (~60–120ms unless noted): **button_hover** a subtle tick;
> **button_click** a crisp confirm; **menu_open** a short rising whoosh; **menu_close** its falling
> counterpart; **shop_buy** a positive cash-register/chime (~300ms); **shop_error** a gentle negative
> "can't afford" buzz.

## B10 · Item-FX-SFX (4)

**Pfade:** `assets/audio/sfx/fire_shield.ogg`, `thunder_chain.ogg`, `slow_motion.ogg`, `whoosh.ogg`
> - **fire_shield** (~250ms): a flaring whoomph as the shield absorbs a projectile.
> - **thunder_chain** (~300ms): a crackling electric arc/zap (combo reward).
> - **slow_motion** (~400ms): a pitch-bending "time slows" warp as the Time Crystal triggers.
> - **whoosh** (~120ms): a generic fast air swipe (fist/dash movement accent).

---

# Teil VFX — Visuelle Effekte

> Treffer-/Tod-/Item-Feedback aus CLAUDE.md §17 (FX-Spalten) und §18 (Combat Feedback). Alle VFX sind
> **One-Shot-Sprite-Sheets** (kein Loop): einmal abspielen, dann `queue_free()`. Empfohlene Integration:
> kleiner wiederverwendbarer `AnimatedSprite2D`/`GPUParticles2D`-Knoten, am Effekt-Ursprung gespawnt.
> **Stil zusätzlich zu §0:** additiv/leuchtend gedacht (heller Kern → farbiger Glow → Funken), transparenter
> Hintergrund, kräftige Neon-Akzente, kurze knackige Bursts. Frames links→rechts, Pivot zentriert.
>
> **Rein code-getrieben, kein Asset nötig:** *Screenshake* (§18, `GameCamera.gd`), *Time-Squeeze/Slow-Motion-
> Zeitskalierung* (§18, `Engine.time_scale`), *Invuln-Blink* (`modulate.a`), *Coin-Rain* (spawnt vorhandene
> Coin-Sprites). V14 ist nur der **optische** Time-Ripple-Overlay zur Slow-Motion.

## V1 · Punch Hit-Spark
**Pfad:** `assets/sprites/vfx/hit_spark/hit_spark_00.png … 05.png` · **48×48** · **6 Frames** ·
Trigger: Treffer auf Gegner (Faust-Impact, §17 Frame 7 / §18 „Hit Sparks 12–16 Partikel weiß/gelb").
> Pixel-art melee impact spark burst, 48x48 per frame, 6-frame one-shot horizontal sheet, transparent
> background. A sharp radial explosion of 12–16 white-and-yellow sparks + a quick bright flash core that
> expands then dissipates over the frames. Punchy arcade hit-feedback, additive glow look, bold outline,
> 1x pixel density, no anti-aliasing.

## V2 · Insekt-Tod-FX
**Pfad:** `assets/sprites/vfx/death_insect/death_insect_00.png … 03.png` · **48×48** · **4 Frames** ·
Trigger: Insekt stirbt (§17 „Insekt Tod 4 Frames Auflösung").
> Pixel-art small enemy death poof, 48x48 per frame, 4-frame one-shot sheet, transparent background. A
> quick squishy burst — a tiny green-ish splatter + chitin shards + a puff of smoke that dissolves into
> dispersing pixels. Low-key but satisfying (triggers constantly). Bold outline, 1x pixel density, no
> anti-aliasing.

## V3 · Vase-Shatter-FX
**Pfad:** `assets/sprites/vfx/death_vase/death_vase_00.png … 05.png` · **64×80** · **6 Frames** ·
Trigger: Vasenmonster stirbt.
> Pixel-art ceramic shatter effect, 64x80 per frame, 6-frame one-shot sheet, transparent background.
> A heavy pottery vessel violently bursting into clay shards and dust that fly outward and fall, with a
> brief warning-glow flash on the first frame. Earthy ceramic palette. Bold outline, 1x pixel density,
> no anti-aliasing.

## V4 · Feuerteufel-Tod-FX
**Pfad:** `assets/sprites/vfx/death_fire/death_fire_00.png … 05.png` · **64×64** · **6 Frames** ·
Trigger: Feuerteufel stirbt (Flamme erlischt).
> Pixel-art flame snuff-out death effect, 64x64 per frame, 6-frame one-shot sheet, transparent
> background. A fiery imp's flames flaring up then collapsing into rising smoke and fading embers — a
> "extinguished" read. Hot ember palette (yellow core → orange → red → grey smoke). Bold outline, 1x
> pixel density, no anti-aliasing.

## V5 · Wand-Treffer-FX
**Pfad:** `assets/sprites/vfx/wall_hit/wall_hit_00.png … 05.png` · **64×64** · **6 Frames** ·
Trigger: Punch trifft die Wand / Wand nimmt Score-Schaden (§17 „Wand Treffer Frame 4–6").
> Pixel-art wall impact effect, 64x64 per frame, 6-frame one-shot sheet, transparent background. A
> short burst of stone chips, dust cloud and a few radiating crack flashes where a fist strikes a rock
> barrier. Neutral grey stone debris with a faint warm impact flash. Bold outline, 1x pixel density, no
> anti-aliasing.

## V6 · Wand-Break-FX
**Pfad:** `assets/sprites/vfx/wall_break/wall_break_00.png … 07.png` · **256×512** · **8 Frames** ·
Trigger: Wand zerstört → Level-Clear (§18 Payoff, größter Effekt).
> Pixel-art wall collapse/explosion, 256x512 per frame, 8-frame one-shot sheet, transparent background,
> matching the wall silhouette. The barrier violently shatters and crumbles — large chunks blast
> outward, dust plume, glowing stress-fracture flashes, then debris falls and clears. Triumphant
> level-break payoff. Bold outline, 1x pixel density, no anti-aliasing.

## V7 · Coin-Bounce-Dust
**Pfad:** `assets/sprites/vfx/coin_dust/coin_dust_00.png … 03.png` · **32×32** · **4 Frames** ·
Trigger: Coin prallt am Boden auf (§18 „Dust-Puff + goldener Funkenschweif").
> Pixel-art tiny dust puff, 32x32 per frame, 4-frame one-shot sheet, transparent background. A small
> soft kick of ground dust with a couple of golden sparkle flecks, expanding and fading quickly. Light
> and subtle. 1x pixel density, no anti-aliasing.

## V8 · Coin-Collect-Pop
**Pfad:** `assets/sprites/vfx/coin_pop/coin_pop_00.png … 04.png` · **48×48** · **5 Frames** ·
Trigger: Coin eingesammelt (§17 Frame 2–3 / §18 „Gold Funken + Light Pop").
> Pixel-art coin pickup sparkle, 48x48 per frame, 5-frame one-shot sheet, transparent background. A
> bright golden light-pop with radiating star-sparkles and a quick expanding ring that flashes then
> fades — a rewarding "collected!" pop. Warm gold palette, additive glow. 1x pixel density, no
> anti-aliasing.

## V9 · Projektil-Spawn-Flash
**Pfad:** `assets/sprites/vfx/proj_spawn/proj_spawn_00.png … 03.png` · **32×32** · **4 Frames** ·
Trigger: Feuerteufel feuert Projektil (§17 „Frame 3 Spawn").
> Pixel-art muzzle/spawn flash for a fireball launch, 32x32 per frame, 4-frame one-shot sheet,
> transparent background. A quick hot flare bursting outward as a projectile is released — bright
> yellow-white core with orange flame petals. 1x pixel density, no anti-aliasing.

## V10 · Projektil-Impact
**Pfad:** `assets/sprites/vfx/proj_hit/proj_hit_00.png … 04.png` · **48×48** · **5 Frames** ·
Trigger: Projektil trifft Spieler.
> Pixel-art fireball impact burst, 48x48 per frame, 5-frame one-shot sheet, transparent background. A
> fiery splash/explosion on hit — radial flame burst, scattering embers and a brief scorch flash. Hot
> ember palette. Bold outline, 1x pixel density, no anti-aliasing.

## V11 · Item · Shockwave-Ring (Shockwave Fist)
**Pfad:** `assets/sprites/vfx/fx_shockwave/fx_shockwave_00.png … 05.png` · **128×128** · **6 Frames** ·
Trigger: Shockwave-Fist-Item (Attack-Radius ×2).
> Pixel-art expanding shockwave ring, 128x128 per frame, 6-frame one-shot sheet, transparent
> background. A single concentric energy ring that erupts from the center and rapidly expands outward
> while thinning and fading, with a bright leading edge. Cool white-cyan energy. Additive glow, 1x pixel
> density, no anti-aliasing.

## V12 · Item · Chain-Lightning (Thunder Charge)
**Pfad:** `assets/sprites/vfx/fx_thunder/fx_thunder_00.png … 04.png` · **128×64** · **5 Frames** ·
Trigger: Thunder-Charge-Item (Chain Lightning bei 20er Combo).
> Pixel-art chain-lightning arc, 128x64 per frame, 5-frame one-shot sheet, transparent background. A
> jagged electric bolt arcing horizontally, branching and flickering between two points, bright blue-white
> core with electric-cyan glow and tiny sparks. Crackling energy feel. 1x pixel density, no anti-aliasing.

## V13 · Item · Meteor-Impact (Call of Wrath)
**Pfad:** `assets/sprites/vfx/fx_meteor/fx_meteor_00.png … 07.png` · **128×128** · **8 Frames** ·
Trigger: Call-of-Wrath-Item (Meteor + ×2 Score bei 30+ Combo) — das Ultimate.
> Pixel-art meteor strike, 128x128 per frame, 8-frame one-shot sheet, transparent background. A flaming
> meteor screams down from the top, slams into the ground and erupts in a fiery explosion with shockwave
> dust, scattering embers and a bright flash. Epic, dramatic, the game's ultimate payoff. Hot ember
> palette. Bold outline, 1x pixel density, no anti-aliasing.

## V14 · Item · Time-Ripple-Overlay (Time Crystal)
**Pfad:** `assets/sprites/vfx/fx_slowmo/fx_slowmo_00.png … 04.png` · **256×256** · **5 Frames** ·
Trigger: Time-Crystal-Item (Slow-Motion bei 10er Combo) — rein optischer Overlay zur Zeitskalierung.
> Pixel-art "time warp" ripple overlay, 256x256 per frame, 5-frame one-shot sheet, transparent
> background. A large soft concentric distortion ripple with a faint violet-cyan chromatic shimmer that
> washes outward across the screen as time slows. Subtle, ethereal, low-opacity. 1x pixel density, no
> anti-aliasing.

## V15 · Item · Fire-Shield-Burst
**Pfad:** `assets/sprites/vfx/fx_shield/fx_shield_00.png … 05.png` · **96×96** · **6 Frames** ·
Trigger: Fire-Shield-Item absorbiert ein Projektil.
> Pixel-art fire-shield absorb burst, 96x96 per frame, 6-frame one-shot sheet, transparent background.
> A circular flaming barrier flaring brightly as it catches an incoming projectile — a flame ring pulse
> that whoomphs and dissipates. Hot orange-red with a protective golden rim. Additive glow, 1x pixel
> density, no anti-aliasing.

## V16 · Player-Hurt-Flash
**Pfad:** `assets/sprites/vfx/hurt_flash/hurt_flash_00.png … 03.png` · **64×64** · **4 Frames** ·
Trigger: Spieler nimmt Schaden (ergänzend zum code-seitigen Invuln-Blink).
> Pixel-art damage/hurt flash, 64x64 per frame, 4-frame one-shot sheet, transparent background. A short
> sharp red impact flash with a few outward pain-spark slashes that snap in and fade fast. Reads as
> "took a hit". Bold outline, 1x pixel density, no anti-aliasing.

---

# Teil C — Integration / Drop-in (für den Art-Drop)

> So rutscht das eingehende Sprite-Set ohne Code-Nacharbeit ins Spiel. Stand der Pipeline-Vorbereitung:
> **2026-06-04.**

## C1 · Was bereits vorbereitet ist
- **Pixel-Art-Filter projektweit auf *Nearest*** gesetzt (`project.godot` →
  `rendering/textures/canvas_textures/default_texture_filter=0`). Neue PNGs werden damit **scharf**
  (nicht weichgezeichnet) gerendert — keine Per-Datei-Einstellung nötig.
- **Ziel-Ordnerstruktur + Frame-Benennung existieren bereits** exakt wie in der Status-Tabelle oben
  (z. B. `assets/sprites/enemies/insect/<color>/insect_frame_0N.png`,
  `assets/sprites/player/<skin>/fist_frame_0N.png`). Der Artist liefert nach **genau diesem Schema**.
- **Import ist Lossless** (`compress/mode=0`, `mipmaps/generate=false`) — passt für Pixel-Art.

## C2 · Drop-in-Vorgehen
1. PNGs **1:1 über die Platzhalter** an den dokumentierten Pfaden kopieren (gleicher Datei-/Ordnername).
2. Godot öffnen **oder** headless importieren: `… --headless --path . --import` (2×, falls neue UIDs).
3. Status-Tabelle oben pflegen (☐ → ☑).

> **Wichtig:** Pfade/Dateinamen **nicht** ändern — die Szenen referenzieren sie fix (z. B. `Enemy.tscn`
> → `insect/green/insect_frame_00.png`). Wird ein Pfad umbenannt, bricht die Referenz.

## C3 · ⚠️ Animations-Lücke (bewusst offen, Folge-Code-Aufgabe)
Aktuell gibt es **keinen `AnimatedSprite2D`** — **alle** Entities zeigen einen **einzelnen statischen
`Sprite2D`-Frame**:

| Entity | Szene | Aktuell sichtbarer Frame |
|---|---|---|
| Insekt | `Enemy.tscn` | `insect/green/insect_frame_00.png` (pro Typ per `modulate` eingefärbt) |
| Coin | `Coin.tscn` | ein einzelner `coin_frame`-Texture |
| Projektil | `Projectile.tscn` | ein einzelner `projectile`-Frame |
| Spieler-Faust | `Player.tscn` | `fist_frame_00` |

**Konsequenz für den Drop:**
- Wird **nur der jeweils sichtbare Basis-Frame** überschrieben (z. B. `insect_frame_00.png`,
  `fist_frame_00.png`), sieht man die neue Art **sofort** — ohne jede Code-Änderung. Empfohlener
  schneller Win.
- Die **restlichen Frames** (01–0N) + **Farbordner** (insect blau/rot) + Skins liegen dann zwar im
  Repo, werden aber **noch nicht abgespielt**. Echte Frame-Animation + Skin-/Farbwahl ist eine separate
  **Code-Aufgabe** (Umbau Enemy/Coin/Projectile/Player auf `AnimatedSprite2D` + `SpriteFrames` nach den
  Timings in CLAUDE.md §17). Das machen wir, wenn die Art da ist — nicht jetzt.

## C4 · Pre-Drop-Checkliste (an den Artist)
- [ ] Exakte Pfade/Dateinamen aus der Status-Tabelle einhalten (case-sensitiv behandeln).
- [ ] Quell-Auflösungen wie in Spalte „Maße" (Sprites dürfen größer als die Hitbox sein — §16 bleibt).
- [ ] Frame-Anzahl je Set wie in Spalte „Frames"; transparenter Hintergrund (außer Backgrounds/Walls).
- [ ] PNG, kein verlustbehaftetes Vorab-Resampling (Nearest/Lossless-Pipeline).

## C5 · Post-Drop-Smoke-Test
```powershell
& "E:\Godot\Godot_v4.4-stable_win64_console.exe" --headless --path . --import
& "E:\Godot\Godot_v4.4-stable_win64_console.exe" --headless --path . --quit-after 8
```
Konsole muss frei von `Failed to load`/`valid=false`/`SCRIPT ERROR` sein; dann eine echte Runde im
Editor zur Sichtprüfung starten.

---

*Abhaken: Status-Tabelle oben (☐ → ☑) pflegen, sobald ein Set durch echte Assets ersetzt ist. Nach
PNG-Ersatz Godot 2× `--import` laufen lassen; `.ogg` müssen gültige Vorbis-Dateien sein (kein Text).*
