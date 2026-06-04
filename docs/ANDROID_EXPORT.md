# Android-Export — Anleitung

Das Projekt enthält bereits ein fertig konfiguriertes Android-Export-Preset
(`export_presets.cfg`, Preset-Name **"Android"**). Der eigentliche APK-Build wird **im
Godot-Editor** gemacht. Diese Anleitung beschreibt das einmalige Setup.

> **Status:** Preset + Projekt-Settings sind eingerichtet. Es wurde **kein** APK gebaut —
> das machst du im Editor (Schritt 5).

---

## Voraussetzungen (einmalig einrichten)

### 1. Export-Templates installieren
Godot-Editor → **Editor → Manage Export Templates… → Download and Install**
(lädt die zur Engine-Version 4.4 passenden Templates).

### 2. OpenJDK 17 installieren
Android-Builds brauchen ein JDK (empfohlen: **Temurin / OpenJDK 17**).
Pfad merken (z. B. `C:\Program Files\Eclipse Adoptium\jdk-17...`).

### 3. Android SDK bereitstellen
Einfachster Weg: **Android Studio** installieren → einmal starten → SDK + Platform-Tools
werden eingerichtet (Standardpfad `C:\Users\<User>\AppData\Local\Android\Sdk`).
Alternativ nur die *Command-line Tools* + `sdkmanager`.

### 4. Pfade im Godot-Editor eintragen
**Editor → Editor Settings → Export → Android**:
- **Java SDK Path** → JDK-17-Ordner
- **Android SDK Path** → SDK-Ordner

Godot kann hier auch automatisch einen **Debug-Keystore** erzeugen
(Button „Create Debug Keystore"), nötig für Debug-Builds.

---

## 5. APK exportieren

**Project → Export…** → Preset **"Android"** auswählen → unten **Export Project** klicken.
Zielpfad ist im Preset auf `build/fingerfist.apk` voreingestellt.

Alternativ headless über die Konsole (Templates + SDK/JDK müssen eingerichtet sein):

```powershell
& "E:\Godot\Godot_v4.4-stable_win64_console.exe" --headless --path . --export-debug "Android" build/fingerfist.apk
```

APK aufs Gerät bringen: USB-Debugging am Telefon aktivieren, dann
`adb install build/fingerfist.apk` (oder die APK-Datei direkt aufs Gerät kopieren und öffnen).

---

## Preset-Eckdaten (in `export_presets.cfg`)

| Einstellung | Wert |
|---|---|
| Package | `com.fingerfist.game` |
| App-Name | Fingerfist |
| Architektur | `arm64-v8a` (moderne Geräte; armeabi-v7a bei Bedarf aktivieren) |
| Orientierung | **Landscape** (in `project.godot`, `window/handheld/orientation=0`) |
| Renderer | `gl_compatibility` (mobil-tauglich, bereits gesetzt) |
| Permissions | keine (Saves liegen lokal in `user://`) |
| Export-Pfad | `build/fingerfist.apk` |

## Hinweise
- **Querformat:** Die Arena ist horizontal (Viewport 1280×720), daher Landscape — trotz
  „mobile-first". Touch ist bereits aktiv (`emulate_touch_from_mouse` + echte Touch-Events).
- **Icons:** Launcher-Icons sind noch leer (nutzen Default). Wenn die finalen Sprites/Branding
  da sind, hier `launcher_icons/...` im Preset bzw. im Export-Dialog setzen.
- **Release-Build:** Für einen signierten Release-Build einen eigenen Release-Keystore anlegen
  und in den Editor-Settings/Preset hinterlegen (für reines Testen reicht der Debug-Build).
