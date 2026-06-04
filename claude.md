# FINGERFIST — claude.md
> Projektgedächtnis für Claude. Dieser Stand basiert auf GOD v1.0 + TDD v1.0.
> Beim Projektstart: Abgleich mit tatsächlichem Code-Stand durchführen.

---

## 1. Was ist Fingerfist?

Arcade-Brawler, mobile-first. Der Spieler steuert eine übergroße FingerFaust und boxt Gegnerhorden weg.
Inspiriert von: One Finger Death Punch + Hyper Light Drifter Combat Feel.

**Engine:** Godot 4.x | **Sprache:** GDScript | **Architektur:** Scene-Composition

---

## 2. Core Loop

```
Spawns erscheinen
    → Spieler tippt → Faustschlag → One-Hit-Kill
    → Combo / Tempo / Flow
    → Coins sammeln (unterbricht Attacke)
    → Wand nimmt Schaden durch Score
    → Wand zerstört → nächstes Level
    → Endscreen → Shop → Retry / Weiter
```

---

## 3. Player

- 5 HP, keine Stamina
- Tap anywhere → Attack (Hitbox kurz aktiv)
- Faust orientiert sich zur Maus/Touch-Position
- Keine eigene Bewegung (nur Knockback)
- Coins sammeln unterbricht Attacke

**Wichtige Variablen:**
- `hp: int = 5`
- `attack_cooldown: float = 0.08`
- `combo_counter: int`
- `invulnerable_frames: float = 0.1`

---

## 4. Gegner

| Typ | Verhalten | Besonderheit |
|---|---|---|
| Insekt | Läuft direkt auf Spieler zu | Schnell, kleiner Radius |
| Vasenmonster | Langsamer, Schlagwarnung ~0.35s | One-Hit-Kill bleibt |
| Feuerteufel | Stationär/wandernd, Projektile | Ranged, Distanz-Angriff |

Alle Gegner: **One-Hit-Kill durch Spieler.**
FSM: Spawn → Orient → Chase → Attack

**Feuerteufel Projektil:**
- Speed: 7 px/ms | Range: 700 px | Cooldown: 5s
- Warn-Animation: 0.4s | Schaden: 1 HP | Kein Tracking

---

## 5. Spawnkurven (Level 1–8)

| Level | Insekten | Vasenmonster | Feuerteufel |
|---|---|---|---|
| 1 | 1–5 | – | – |
| 2 | 3–7 | – | – |
| 3 | 5–10 | 2–5 | – |
| 4 | 7–12 | 3–7 | – |
| 5 | 5–10 | 5–10 | 2–5 |
| 6 | 7–14 | 6–12 | 3–7 |
| 7 | 8–16 | 7–14 | 4–9 |
| 8+ | 5–10 | 5–10 | 5–10 |

Wave-Dauer: 10–45 Sekunden. Level 1: nur Insekten, 1/sek → 3–4/sek (Lernkurve).

---

## 6. Arena

- Durchmesser: **1111 px**, kreisförmig
- Spieler: rechtes Ende der X-Achse
- Gegner: spawnen am linken Rand / Arena-Rand
- Bewegung: eindimensional entlang X-Achse
- Keine NavigationNodes, kein Terrain, keine Hindernisse
- **Wand:** wird durch Score beschädigt → bei Schwellenwert zerstört → Level Up

---

## 7. Coin System

- Fallen von oben, bouncen am Boden (abnehmende Sprünge)
- Wert: 10–50 Münzen pro Coin
- Sammeln per Tap (unterbricht Attacke)
- Spawnen nur wenn Runde aktiv (kein Pause/Endscreen)

**Wichtige Variablen:** `velocity`, `bounce_factor`, `min_bounce_threshold`, `is_collectible`

---

## 8. Progression & Level

- 8 Level, Thema: Aufstieg aus einer Höhle
- Level 1 immer verfügbar
- Höhere Level durch `total_score` freischalten
- Levelauswahl im Hauptmenü (LevelSelect.tscn): Buttons enabled/disabled je nach `unlocked_levels`
- Gesperrte Level: ausgegraut + Schloss-Icon

---

## 9. Shop & Items

**Shop (kosmetisch):**
- Skins kaufen und auswählen
- Währung: Coins
- Persistent gespeichert

**Item-System (gameplay-modifizierend, nice to have):**
- Items permanent kaufen, aber Effekte nur für 1 Runde
- Spieler aktiviert Items vor Rundenstart
- Effekte: AoE Punch, Crit Punch, Money Booster, Punch Speed Up, Shield/Leben+1, Enemy Slowdown
- Lebenszyklus: Kaufen → Aktivieren → Rundenstart → Effekte anwenden → Rundenende → deaktivieren

---

## 10. Highscore & Save

**Gespeichert in:** `user://progression.save` (Godot `FileAccess.store_var()`)

**Datenstruktur:**
```gdscript
{
  "highscores": [],
  "highest_combos": [],  # Top 3
  "total_score": 0,
  "unlocked_levels": 1,
  "unlocked_gloves": [],
  "coins": 0,
  "skins": {},
  "current_skin": ""
}
```

---

## 11. Combo System (optional)

- Zählt jeden Treffer
- Angezeigt ab 10 Treffern in Folge
- Reset bei Schadentreffer oder zu langer Pause
- Top 3 Combos im Highscore gespeichert

---

## 12. Szenenstruktur (Soll-Zustand)

```
/scenes
  MainMenu.tscn
  GameScene.tscn
  Player.tscn
  Enemy.tscn
  EnemySpawner.tscn
  CoinSpawner.tscn
  Coin.tscn
  HUD.tscn
  HighscoreScreen.tscn
  ShopScreen.tscn
  OptionsScreen.tscn
  CreditsScreen.tscn
  LevelSelect.tscn

/autoload
  GameManager.gd
  SceneLoader.gd
  AudioManager.gd
  DataStore.gd

/scripts
  Player.gd
  Enemy.gd
  EnemySpawner.gd
  Coin.gd
  CoinSpawner.gd
  Projectile.gd
  HUD.gd
  Shop.gd
  MainMenu.gd
  Options.gd
  Credits.gd
  Highscore.gd
  LevelSelect.gd
```

---

## 13. Autoloads (Singletons)

| Name | Datei | Verantwortung |
|---|---|---|
| `Game` | GameManager.gd | Score, HP, Combo, Level, start_round(), end_round() |
| `DataStore` | DataStore.gd | save(), load(), Datenstruktur |
| `Audio` | AudioManager.gd | play_sfx(), play_music(), set_volume(), Crossfade |
| `SceneLoader` | SceneLoader.gd | load_scene(), fade() |

---

## 14. Wichtige Signale

```gdscript
# Player
signal died
signal hit_enemy

# Coin
signal collected(amount)

# GameManager
signal score_changed
signal game_over

# HUD
signal restart_pressed
```

---

## 15. Kollisionsmatrix

| | Player | Enemy | Projektil | Münze | Wand |
|---|---|---|---|---|---|
| **Player** | – | x | x | x | – |
| **Enemy** | x | – | – | – | x |
| **Projektil** | x | – | – | – | x |
| **Münze** | x | – | – | – | – |
| **Wand** | – | x | x | – | – |

**Collision Layers:** Player=1, Enemy=2, Projectile=3, Coin=4, Wall=5

---

## 16. Hitbox-Tabelle

| Objekt | Form | Größe (px) | Offset | Anmerkung |
|---|---|---|---|---|
| Faust/Player | Circle | r=16 | 0/0 | Nur aktiv während Angriff |
| Insekt | Circle | r=12 | 0/0 | Permanent |
| Vasenmonster | Rectangle | 32×40 | 0/−4 | Größer als Sprite |
| Feuerteufel | Circle | r=14 | 0/0 | Stationär/Edge |
| Projektil | Rectangle | 12×8 | 0/0 | Während Flug |
| Münze | Circle | r=6 | 0/0 | Nur wenn is_collectible=true |
| Wand | Rectangle | 96×12 | zentriert | Ziel für Gegner |

---

## 17. Animations-Timing

| Animation | Dauer (ms) | Frames | Hit-aktiv | Sound | FX |
|---|---|---|---|---|---|
| Faust Punch | 140 | 8 | Frame 3–5 | Frame 2 | Frame 7 |
| Insekt Tod | 90 | 4 | – | – | Frame 2 |
| Vasenmonster Angriff | 350 | 10 | Frame 6–8 | Frame 8 | – |
| Feuerteufel Projektil | 400 | 6 | – | – | Frame 3 (Spawn) |
| Wand Treffer | 100 | 6 | – | – | Frame 4–6 |
| Coin Einsammeln | 60 | 4 | – | – | Frame 2–3 |

---

## 18. Combat Feedback (FX)

- **Screenshake** bei jedem Treffer
- **Hit Sparks:** 12–16 Partikel, weiß/gelb, kurze Radialexplosion
- **Time-Squeeze:** 0.05–0.1s optional
- **Enemy Death:** Pixel-Auflösung, 20ms Verzögerung
- **Coin Bounce:** Dust-Puff + goldener Funkenschweif
- **Coin Collect:** Gold Funken + Light Pop + SFX "pling"

---

## 19. Audio (Soll-Zustand)

**43 Pflicht-SFX minimum:**
- Punches: 10 Variationen
- Enemy Kills: 9 (3 pro Typ)
- Enemy Attacks: 6
- Player Hurt/Death: 4
- UI Sounds: 8
- Coins: 3
- Level-Break: 3

**5 Musik-Tracks:**
1. Main Theme (Tribal Drums + Elektro)
2. In-Game Combat (hohes Tempo, treibend)
3. Boss/Mixed Wave (ab Level 6)
4. Shop Theme (Chiptune, entspannt)
5. Credits Theme (warm, aufsteigend)

---

## 20. Implementierungsstand (laut GOD, vor Code-Abgleich)

| System | GOD-Schätzung | Code-Stand (TODO) |
|---|---|---|
| Core Loop / Tapping / Multiplier | ~90% | ? |
| Coins | ~80% | ? |
| Shop / Skins | ~65% | ? |
| Highscore / Progression | ~70% | ? |
| UI / Scenes | ~75% | ? |
| Audio | ~50% | ? |
| Camera Shake | ~70% | ? |
| Save System | ~60% | ? |
| Input (Touch/Mouse) | ~60% | ? |
| Project Structure | ~50% | ? |
| Art / Assets | ~10% | ? |
| QA / Build / Export | 0% | ? |

---

## 21. Offene Baustellen (laut TDD)

**Essentiell:**
- Exakte Attack-Timings & Animation Frames
- Exakte Coin-Bounce-Physikformel
- AudioManager fehlt komplett

**Wichtig:**
- Screenshake Preset-Tabelle implementieren
- Enemy Animation Timing Sheets
- Projektil Sprites + Frameanzahl

**Nice to Have:**
- Telemetry / Analytics
- Mobile Performance Budget
- Shader-Konzept
- Combo-System
- Item-System im Shop

---

*Nächster Schritt: claude.md mit tatsächlichem Projektstand abgleichen.*
