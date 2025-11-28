# Fingerfist-01
Punch to Playton

## 🎮 Development Status

**Milestone 1: COMPLETE ✅**
Player kann Gegner mit Punch-Attacks töten.

**Current Milestone:** M2 - Core Loop (Spawner, Wall, Coins)
**Progress:** 15/70 Commits (21%)

See [docs/PROGRESS.md](docs/PROGRESS.md) for details.

---

## 🚀 Quick Start

### Play Current Build
```bash
# Open in Godot
godot -e

# Run Test Scene
# Scenes/TestCombat.tscn (F6)
# Press SPACE to spawn enemies
# Click to attack
```

### Run Automated Tests
```bash
# Run validation suite
# Scenes/TestCombatValidator.tscn (F6)
# Check console for results
```

---

## 📚 Documentation

- [Milestone 1 Report](docs/MILESTONE_1.md)
- [Progress Tracker](docs/PROGRESS.md)
- [TDD v2.0](outputs/TDD_Teil_1_von_4.md)
- [Asset List](outputs/ASSET_LIST.md)
- [Commit Plan](outputs/GIT_COMMIT_PLAN.md)

---

## 🏗️ Architecture

**Core Systems:**
- Global.gd - State Management
- AudioManager.gd - SFX/Music
- SaveSystem.gd - Persistence
- SceneLoader.gd - Transitions

**Game Systems:**
- Player.gd (400+ lines)
- Enemy.gd (350+ lines)
- GameScene.gd (250+ lines)
- GameCamera.gd (Screenshake)
- HUD.gd (UI)

---

## 🧪 Testing

**Automated Tests:** 9/9 PASSED ✅
- Player existence
- Attack functionality
- Enemy spawning
- Collision detection
- Death system
- Score tracking
- Combo system
- Damage system
- Screenshake

Run: `Scenes/TestCombatValidator.tscn`
