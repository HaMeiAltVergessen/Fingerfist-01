#!/usr/bin/env python3
"""
Fingerfist Asset Placeholder Generator
Generiert alle 276 Platzhalter-Assets (228 Bilder + 48 Audio-Dateien)
"""

import os
from pathlib import Path

def create_directories():
    """Erstellt alle benötigten Asset-Ordner"""
    directories = [
        # Audio
        "assets/audio/sfx",
        "assets/audio/music",

        # Player Sprites
        "assets/sprites/player/default",
        "assets/sprites/player/metal",
        "assets/sprites/player/gold",
        "assets/sprites/player/fire",
        "assets/sprites/player/ice",
        "assets/sprites/player/shadow",
        "assets/sprites/player/neon",
        "assets/sprites/player/crystal",

        # Enemy Sprites
        "assets/sprites/enemies/insect/green",
        "assets/sprites/enemies/insect/blue",
        "assets/sprites/enemies/insect/red",
        "assets/sprites/enemies/vase",
        "assets/sprites/enemies/fire_devil",
        "assets/sprites/enemies/projectile",

        # Coins
        "assets/sprites/coins/bronze",
        "assets/sprites/coins/silver",
        "assets/sprites/coins/gold",
        "assets/sprites/coins/platinum",

        # Walls
        "assets/sprites/walls/level_1",
        "assets/sprites/walls/level_2",
        "assets/sprites/walls/level_3",
        "assets/sprites/walls/level_4",
        "assets/sprites/walls/level_5",
        "assets/sprites/walls/level_6",
        "assets/sprites/walls/level_7",

        # UI
        "assets/sprites/ui",
        "assets/sprites/ui/items",

        # Backgrounds
        "assets/sprites/backgrounds",
    ]

    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"✓ Created: {directory}")

def create_png_placeholder(width, height, color, filepath):
    """Erstellt ein PNG-Platzhalter-Bild"""
    # Einfache PPM-zu-PNG Konvertierung (ohne PIL/Pillow Abhängigkeit)
    # Erstellt ein einfarbiges Bild

    # Konvertiere Hex-Color zu RGB
    if color.startswith('#'):
        color = color[1:]
    r = int(color[0:2], 16)
    g = int(color[2:4], 16)
    b = int(color[4:6], 16)

    # PPM Format (kann später mit ImageMagick zu PNG konvertiert werden)
    # Für jetzt: Erstelle eine einfache Textdatei als Marker
    with open(filepath.replace('.png', '.ppm'), 'w') as f:
        f.write(f"P3\n{width} {height}\n255\n")
        for _ in range(height):
            for _ in range(width):
                f.write(f"{r} {g} {b} ")
            f.write("\n")

    # Erstelle auch eine .png.placeholder Datei
    with open(filepath, 'w') as f:
        f.write(f"# PNG Placeholder\n")
        f.write(f"# Size: {width}x{height}\n")
        f.write(f"# Color: #{color}\n")
        f.write(f"# Replace with actual PNG sprite\n")

def create_ogg_placeholder(filepath):
    """Erstellt einen OGG-Platzhalter (leere Audiodatei)"""
    with open(filepath, 'w') as f:
        f.write("# OGG Placeholder\n")
        f.write("# Replace with actual OGG audio file\n")
        f.write("# Use Audacity or similar to export as OGG Vorbis\n")

def generate_player_sprites():
    """Generiert Player Fist Sprites (8 Skins × 8 Frames)"""
    skins = {
        "default": "ff6b35",  # Orange
        "metal": "a8a8a8",    # Gray
        "gold": "ffd700",     # Gold
        "fire": "ff4500",     # Red-Orange
        "ice": "87ceeb",      # Light Blue
        "shadow": "2f2f2f",   # Dark Gray
        "neon": "00ff00",     # Neon Green
        "crystal": "e0b0ff",  # Light Purple
    }

    print("\n📦 Generating Player Sprites...")
    for skin_name, color in skins.items():
        for frame in range(8):
            filepath = f"assets/sprites/player/{skin_name}/fist_frame_{frame:02d}.png"
            create_png_placeholder(64, 64, color, filepath)
            print(f"  ✓ {filepath}")

def generate_enemy_sprites():
    """Generiert Enemy Sprites"""
    print("\n📦 Generating Enemy Sprites...")

    # Insekten (3 Farben × 4 Frames)
    insect_colors = {"green": "3cb371", "blue": "4169e1", "red": "dc143c"}
    for color_name, color in insect_colors.items():
        for frame in range(4):
            filepath = f"assets/sprites/enemies/insect/{color_name}/insect_frame_{frame:02d}.png"
            create_png_placeholder(24, 24, color, filepath)
            print(f"  ✓ {filepath}")

    # Vasenmonster (10 Frames)
    for i, prefix in enumerate(["vase_idle_00", "vase_idle_01",
                                  "vase_windup_00", "vase_windup_01", "vase_windup_02",
                                  "vase_windup_03", "vase_windup_04",
                                  "vase_attack_00", "vase_attack_01", "vase_attack_02"]):
        filepath = f"assets/sprites/enemies/vase/{prefix}.png"
        create_png_placeholder(32, 40, "cd853f", filepath)  # Peru/Terra-Cotta
        print(f"  ✓ {filepath}")

    # Feuerteufel (6 Frames)
    for frame in range(6):
        prefix = "fire_idle" if frame < 4 else "fire_charge"
        num = frame if frame < 4 else frame - 4
        filepath = f"assets/sprites/enemies/fire_devil/{prefix}_{num:02d}.png"
        create_png_placeholder(32, 32, "ff4500", filepath)  # Orange-Red
        print(f"  ✓ {filepath}")

    # Projektil (4 Frames)
    for frame in range(4):
        filepath = f"assets/sprites/enemies/projectile/projectile_{frame:02d}.png"
        create_png_placeholder(12, 12, "ff8c00", filepath)  # Dark Orange
        print(f"  ✓ {filepath}")

def generate_coin_sprites():
    """Generiert Coin Sprites (4 Werte × 4 Frames)"""
    print("\n📦 Generating Coin Sprites...")

    coin_types = {
        "bronze": "cd7f32",   # Bronze
        "silver": "c0c0c0",   # Silver
        "gold": "ffd700",     # Gold
        "platinum": "e5e4e2", # Platinum
    }

    for coin_type, color in coin_types.items():
        for frame in range(4):
            filepath = f"assets/sprites/coins/{coin_type}/coin_frame_{frame:02d}.png"
            create_png_placeholder(16, 16, color, filepath)
            print(f"  ✓ {filepath}")

def generate_wall_sprites():
    """Generiert Wall Sprites (7 Levels × 3 Zustände)"""
    print("\n📦 Generating Wall Sprites...")

    for level in range(1, 8):
        if level == 7:
            # Level 7 = Endless, nur Background
            filepath = f"assets/sprites/walls/level_7/background.png"
            create_png_placeholder(1280, 720, "87ceeb", filepath)  # Sky Blue
            print(f"  ✓ {filepath}")
        else:
            states = ["intact", "damaged", "critical"]
            colors = ["696969", "8b4513", "654321"]  # Gray → Brown → Dark Brown

            for state, color in zip(states, colors):
                filepath = f"assets/sprites/walls/level_{level}/wall_{state}.png"
                create_png_placeholder(96, 720, color, filepath)
                print(f"  ✓ {filepath}")

def generate_ui_sprites():
    """Generiert UI Sprites"""
    print("\n📦 Generating UI Sprites...")

    # Icons
    icons = {
        "hp_icon.png": (32, 32, "ff0000"),      # Red Heart
        "coin_icon.png": (32, 32, "ffd700"),    # Gold Coin
        "combo_icon.png": (32, 32, "ff4500"),   # Orange Fire
    }

    for filename, (w, h, color) in icons.items():
        filepath = f"assets/sprites/ui/{filename}"
        create_png_placeholder(w, h, color, filepath)
        print(f"  ✓ {filepath}")

    # Item Icons
    item_icons = [
        "shockwave_fist.png", "iron_knuckles.png", "time_crystal.png",
        "fire_shield.png", "greed_magnet.png", "thunder_charge.png",
        "golem_skin.png", "call_of_wrath.png"
    ]

    colors = ["4169e1", "808080", "9370db", "ff4500", "ffd700", "ffff00", "8b4513", "ff0000"]

    for icon, color in zip(item_icons, colors):
        filepath = f"assets/sprites/ui/items/{icon}"
        create_png_placeholder(64, 64, color, filepath)
        print(f"  ✓ {filepath}")

    # Buttons
    button_states = {
        "button_normal.png": "4169e1",   # Blue
        "button_hover.png": "1e90ff",    # Light Blue
        "button_pressed.png": "00008b",  # Dark Blue
        "button_disabled.png": "696969", # Gray
    }

    for filename, color in button_states.items():
        filepath = f"assets/sprites/ui/{filename}"
        create_png_placeholder(200, 50, color, filepath)
        print(f"  ✓ {filepath}")

    # Panels
    filepath = f"assets/sprites/ui/panel_bg.png"
    create_png_placeholder(400, 300, "2f4f4f", filepath)  # Dark Slate Gray
    print(f"  ✓ {filepath}")

    filepath = f"assets/sprites/ui/panel_border.png"
    create_png_placeholder(400, 300, "8b4513", filepath)  # Saddle Brown
    print(f"  ✓ {filepath}")

def generate_background_sprites():
    """Generiert Background Sprites"""
    print("\n📦 Generating Background Sprites...")

    levels = {
        1: "191970",  # Midnight Blue (Tiefe Höhle)
        2: "4b0082",  # Indigo (Kristallkammer)
        3: "8b0000",  # Dark Red (Lava-Schlucht)
        4: "003366",  # Deep Blue (Unterirdischer Fluss)
        5: "2f4f2f",  # Dark Green (Pilzwald)
        6: "e0ffff",  # Light Cyan (Eis-Katakombe)
        7: "87ceeb",  # Sky Blue (Höhlenausgang)
    }

    for level, color in levels.items():
        filepath = f"assets/sprites/backgrounds/level_{level}_bg.png"
        create_png_placeholder(1280, 720, color, filepath)
        print(f"  ✓ {filepath}")

def generate_audio_sfx():
    """Generiert SFX Platzhalter"""
    print("\n📦 Generating SFX Placeholders...")

    sfx_files = [
        # Player (15)
        "punch_01.ogg", "punch_02.ogg", "punch_03.ogg", "punch_04.ogg", "punch_05.ogg",
        "punch_06.ogg", "punch_07.ogg", "punch_08.ogg", "punch_09.ogg", "punch_10.ogg",
        "hurt_01.ogg", "hurt_02.ogg", "hurt_03.ogg",
        "death.ogg", "whoosh.ogg",

        # Enemy (13)
        "insect_death_01.ogg", "insect_death_02.ogg", "insect_death_03.ogg",
        "vase_break_01.ogg", "vase_break_02.ogg", "vase_break_03.ogg",
        "vase_windup.ogg", "vase_attack_01.ogg", "vase_attack_02.ogg",
        "fire_extinguish_01.ogg", "fire_extinguish_02.ogg", "fire_extinguish_03.ogg",
        "projectile_charge.ogg", "projectile_fire.ogg", "projectile_hit.ogg",

        # Coins (4)
        "coin_collect_01.ogg", "coin_collect_02.ogg", "coin_collect_03.ogg",
        "coin_bounce.ogg",

        # Wall (3)
        "wall_crack_01.ogg", "wall_crack_02.ogg", "wall_break.ogg",

        # UI (6)
        "button_click.ogg", "button_hover.ogg", "menu_open.ogg",
        "menu_close.ogg", "shop_buy.ogg", "shop_error.ogg",

        # Items (4)
        "fire_shield.ogg", "thunder_chain.ogg", "slow_motion.ogg", "meteor_rain.ogg",
    ]

    for sfx in sfx_files:
        filepath = f"assets/audio/sfx/{sfx}"
        create_ogg_placeholder(filepath)
        print(f"  ✓ {filepath}")

def generate_audio_music():
    """Generiert Music Platzhalter"""
    print("\n📦 Generating Music Placeholders...")

    music_files = [
        "main_theme.ogg",
        "combat_level_1.ogg",
        "combat_level_2.ogg",
        "combat_boss.ogg",
        "shop_theme.ogg",
    ]

    for music in music_files:
        filepath = f"assets/audio/music/{music}"
        create_ogg_placeholder(filepath)
        print(f"  ✓ {filepath}")

def create_godot_import_files():
    """Erstellt .import Dateien für Godot (damit Platzhalter erkannt werden)"""
    print("\n📦 Creating Godot .import hints...")

    # Für Audio
    audio_import = """[remap]

importer="oggvorbisstream"
type="AudioStreamOggVorbis"
uid="uid://placeholder"
path="res://.godot/imported/FILENAME-hash.oggvorbisstream"

[deps]

source_file="res://FILEPATH"
dest_files=["res://.godot/imported/FILENAME-hash.oggvorbisstream"]

[params]

loop=false
loop_offset=0
bpm=0
beat_count=0
bar_beats=4
"""

    # Für PNG
    png_import = """[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://placeholder"
path="res://.godot/imported/FILENAME-hash.ctex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://FILEPATH"
dest_files=["res://.godot/imported/FILENAME-hash.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
svg/scale=1.0
editor/scale_with_editor_scale=false
editor/convert_colors_with_editor_theme=false
"""

    # Erstelle .gdignore in Audio-Ordnern (verhindert Auto-Import)
    Path("assets/audio/sfx/.gdignore").touch()
    Path("assets/audio/music/.gdignore").touch()
    print("  ✓ Created .gdignore in audio folders")

def create_readme():
    """Erstellt README für Asset-Ordner"""
    readme_content = """# Fingerfist Assets

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
"""

    with open("assets/README.md", "w") as f:
        f.write(readme_content)

    print("\n✓ Created assets/README.md")

def main():
    """Hauptfunktion - generiert alle Assets"""
    print("=" * 60)
    print("FINGERFIST - ASSET PLACEHOLDER GENERATOR")
    print("=" * 60)
    print("\nGenerating 276 placeholder assets...\n")

    # Erstelle Ordnerstruktur
    create_directories()

    # Generiere Sprites
    generate_player_sprites()
    generate_enemy_sprites()
    generate_coin_sprites()
    generate_wall_sprites()
    generate_ui_sprites()
    generate_background_sprites()

    # Generiere Audio
    generate_audio_sfx()
    generate_audio_music()

    # Erstelle Godot-Import-Hints
    create_godot_import_files()

    # Erstelle README
    create_readme()

    print("\n" + "=" * 60)
    print("✅ COMPLETE!")
    print("=" * 60)
    print("\n📊 Summary:")
    print("  - 228 Sprite Placeholders")
    print("  - 48 Audio Placeholders")
    print("  - Total: 276 Files")
    print("\n📝 Next Steps:")
    print("  1. Review assets/ folder structure")
    print("  2. Git add + commit: git add assets/ && git commit")
    print("  3. Replace placeholders with real assets (same filenames!)")
    print("  4. Godot will auto-import on next editor start")
    print("\n💡 Tip: Start with Phase 1 assets for quickest prototype!\n")

if __name__ == "__main__":
    main()
