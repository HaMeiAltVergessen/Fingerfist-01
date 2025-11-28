# Fingerfist Assets

## Platzhalter-Status

Diese Dateien sind automatisch generierte **PLATZHALTER**.

### Sprite-Platzhalter (.png)
- Einfarbige Rechtecke in korrekter Größe
- Farben dienen zur Identifikation der Asset-Typen
- **Ersetzen:** Mit echten PNG-Sprites (gleicher Dateiname!)

### Audio-Platzhalter (.ogg)
- Leere Text-Dateien als Marker
- **Ersetzen:** Mit echten OGG Vorbis Audio-Dateien

## Prioritäten für Ersetzung

**Phase 1 (Prototyp - sofort ersetzen):**
- `sprites/player/default/fist_frame_00-07.png` (8 Frames)
- `sprites/enemies/insect/green/insect_frame_00-03.png` (4 Frames)
- `sprites/coins/bronze/coin_frame_00-03.png` (4 Frames)
- `sprites/walls/level_1/wall_*.png` (3 States)
- `audio/sfx/punch_01.ogg`, `hurt_01.ogg`, `death.ogg`
- `audio/sfx/insect_death_01.ogg`, `coin_collect_01.ogg`

**Phase 2 (Core Loop):**
- Alle 3 Enemy-Types komplett
- Alle Coin-Varianten
- Alle Player/Enemy SFX

**Phase 3 (Polish):**
- Weitere Player-Skins
- Item-Icons
- UI-Elements
- Musik-Tracks

## Datei-Konventionen

- **Sprites:** PNG, Transparent Background, Pixel Art Style
- **Audio:** OGG Vorbis, 44.1kHz, Mono ok für SFX
- **Naming:** Lowercase, underscores, frame numbers 00-99

## Generiert mit

`generate_placeholders.py` - Fingerfist Asset Generator
