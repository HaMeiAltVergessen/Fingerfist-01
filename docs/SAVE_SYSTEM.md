# Save System Documentation

## Overview

Fingerfist uses a robust save system with support for:
- **3 Save Slots** per player
- **Auto-Save** with debouncing
- **Manual Save/Load** via UI
- **Backup System** for data recovery
- **Slot-Specific** save files

## Architecture

### SaveSystem (Autoload)

The `SaveSystem` autoload manages all save/load operations.

**Key Variables:**
- `current_slot: int` - Active save slot (0-2)
- `SAVE_SLOT_COUNT: int = 3` - Total number of slots
- `AUTO_SAVE_DELAY: float = 2.0` - Debounce timer for auto-saves

**Save File Locations:**
- Slot 0: `user://fingerfist_save_slot_0.cfg`
- Slot 1: `user://fingerfist_save_slot_1.cfg`
- Slot 2: `user://fingerfist_save_slot_2.cfg`
- Backups: `user://fingerfist_save_slot_X_backup.cfg`

### Data Sections

Each save file contains the following sections:

#### [game]
- `total_highscore: int` - Total score across all levels
- `total_rounds_played: int` - Total number of rounds played
- `total_playtime: float` - Total playtime in seconds
- `highscores: Array` - (Deprecated) Legacy array
- `highest_combos: Array` - (Deprecated) Legacy array

#### [progression]
- `unlocked_levels: Array[int]` - Unlocked level indices
- `selected_level: int` - Currently selected level
- `level_highscores: Array[int]` - Highscores per level (8 levels)
- `level_highest_combos: Array[int]` - Highest combos per level
- `wall_hp: Dictionary` - Current wall HP per level

#### [economy]
- `coins: int` - Total coins collected

#### [items]
- `data: Dictionary` - Item ownership and activation status

#### [settings]
- `sfx_volume: float` - SFX volume (0.0-1.0)
- `music_volume: float` - Music volume (0.0-1.0)
- `screenshake_enabled: bool` - Screen shake toggle
- `pixel_perfect: bool` - Pixel-perfect rendering toggle

#### [meta]
- `save_version: String` - Save format version (currently "1.0")
- `save_time: String` - ISO timestamp of last save
- `is_auto_save: bool` - Whether save was auto or manual
- `slot: int` - Slot number

## Auto-Save System

### Triggers

Auto-saves are triggered at the following events:

1. **Every 10 Enemy Kills**
   - Triggered in `game.gd::_on_player_hit_enemy()`
   - Prevents progress loss during combat

2. **Wall Destroyed (Victory)**
   - Triggered in `game.gd::_on_wall_destroyed()`
   - Saves progression unlock immediately

3. **Round End**
   - Triggered in `game.gd::end_round()`
   - Saves final round stats and wall HP

### Debouncing

The auto-save system uses a **2-second debounce timer** to prevent excessive disk writes.

**How it works:**
1. `Global.trigger_auto_save()` is called
2. `SaveSystem.request_auto_save()` starts a 2s timer
3. Multiple requests within 2s are merged into one save
4. After 2s, `_perform_auto_save()` executes the actual save

**Benefits:**
- Reduces disk I/O during intense combat
- Prevents save spam
- Merges multiple triggers into single operation

### Code Example

```gdscript
# In game.gd
func _on_player_hit_enemy(enemy: Enemy):
    enemies_killed_this_round += 1

    # Auto-Save every 10 kills
    if enemies_killed_this_round % 10 == 0:
        Global.trigger_auto_save()
```

## Manual Save/Load

### Save Button (Pause Menu)

- **Location:** Pause Menu (ESC key)
- **Button:** "💾 Save"
- **Action:** Immediately saves to current slot
- **Feedback:** Save indicator appears in top-right

**Code:**
```gdscript
# In game.gd
func _on_save_button_pressed():
    SaveSystem.save_game(false)  # Manual save
```

### Continue Button (Main Menu)

- **Location:** Main Menu
- **Visibility:** Only shown if any save slot has data
- **Action:** Opens Save Slot Select menu

**Code:**
```gdscript
# In MainMenu.gd
func create_continue_button():
    if not SaveSystem.any_save_exists():
        return  # Hide if no saves

    # Create continue button...
```

## Save Slot System

### Slot Selection Menu

The `SaveSlotSelect` scene displays all 3 save slots.

**For Each Slot:**

If **Save Exists:**
- Shows: Level, Score, Coins, Last Save Time
- Buttons: **Load**, **Delete**

If **Empty:**
- Shows: "Empty Slot"
- Button: **New Game**

### Slot Operations

#### Load Slot
```gdscript
SaveSystem.set_current_slot(slot)
SaveSystem.load_game()
SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")
```

#### New Game
```gdscript
SaveSystem.set_current_slot(slot)
_reset_to_new_game()  # Reset Global state
SaveSystem.save_game(false)
SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")
```

#### Delete Slot
```gdscript
SaveSystem.delete_slot(slot)
get_tree().reload_current_scene()  # Refresh UI
```

### Slot Info Retrieval

```gdscript
var info = SaveSystem.get_slot_info(0)

# Returns:
# {
#     exists: bool,
#     save_time: String,
#     level: int,
#     total_score: int,
#     coins: int
# }
```

## Backup System

### Automatic Backups

**When:**
- Before every save operation
- Old save is copied to `*_backup.cfg`

**Why:**
- Protects against corruption
- Allows recovery of previous state

### Manual Restore

```gdscript
SaveSystem.restore_backup()  # Restores previous save
```

**Use Cases:**
- Corrupted save file
- Accidental deletion
- Rolling back unwanted changes

## Save Indicator

Visual feedback for save/load operations.

**Location:** Top-right corner of screen

**Appearance:**
- **Green (💾):** "Game Saved" / "Auto-Saved"
- **Blue (📂):** "Game Loaded"

**Animation:**
1. Fade in (0.2s)
2. Display (2.0s)
3. Fade out (0.3s)

**Implementation:**
```gdscript
# In SaveIndicator.gd
SaveSystem.saved.connect(_on_save_complete)
SaveSystem.loaded.connect(_on_load_complete)
```

## API Reference

### SaveSystem Functions

#### Save/Load
```gdscript
save_game(is_auto: bool = false) -> bool
load_game() -> bool
```

#### Slot Management
```gdscript
set_current_slot(slot: int) -> void
get_slot_info(slot: int) -> Dictionary
delete_slot(slot: int) -> bool
```

#### Utilities
```gdscript
save_exists() -> bool              # Check current slot
any_save_exists() -> bool          # Check all slots
restore_backup() -> bool
get_save_path() -> String
```

#### Auto-Save
```gdscript
request_auto_save() -> void        # Debounced auto-save
```

### Signals

```gdscript
signal saved(is_auto: bool)        # Emitted after save completes
signal loaded()                    # Emitted after load completes
```

## Testing

Run manual tests using `SaveSystemTests.gd`:

```gdscript
# Attach to a Node and call:
var tests = SaveSystemTests.new()
await tests.run_all_tests()
```

**Available Tests:**
- `test_auto_save_triggers()` - Auto-save debouncing
- `test_slot_switching()` - Multi-slot save/load
- `test_save_load_integrity()` - Data preservation
- `test_backup_restore()` - Backup functionality
- `test_slot_info()` - Slot metadata retrieval

## Best Practices

1. **Always use Global.trigger_auto_save()** instead of calling SaveSystem directly
2. **Check any_save_exists()** before showing Continue button
3. **Use manual saves** for critical moments (before boss fights, etc.)
4. **Test save/load** regularly during development
5. **Never delete backups** - they're your safety net

## Troubleshooting

### Save Not Working
- Check console for "[SaveSystem] Save complete" message
- Verify `SaveSystem.is_saving` is false
- Check file permissions in `user://` directory

### Load Not Restoring Data
- Verify save file exists: `SaveSystem.save_exists()`
- Check slot number: `SaveSystem.current_slot`
- Review console for load errors

### Corrupt Save File
- Use `SaveSystem.restore_backup()` to recover
- Delete corrupt file: `SaveSystem.delete_slot(slot)`
- Start new game in that slot

## Future Enhancements

Potential improvements for the save system:

- [ ] Cloud save synchronization
- [ ] Compressed save files
- [ ] Save encryption
- [ ] Import/Export save files
- [ ] Save file migration for version updates
- [ ] Auto-save slot rotation (keep last N auto-saves)
