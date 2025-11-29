# SaveSystem.gd - Persistente Speicherung mit ConfigFile
extends Node

# ============================================================================
# CONSTANTS
# ============================================================================

const SAVE_PATH = "user://fingerfist_save.cfg"
const BACKUP_PATH = "user://fingerfist_save_backup.cfg"

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Lade gespeicherte Daten beim Start
	load_game()

# ============================================================================
# SAVE GAME
# ============================================================================

func save_game() -> bool:
	var config = ConfigFile.new()

	# ========== GAME SECTION ==========
	config.set_value("game", "total_highscore", Global.total_highscore)
	config.set_value("game", "total_rounds_played", Global.total_rounds_played)
	config.set_value("game", "total_playtime", Global.total_playtime)

	# ========== PROGRESSION SECTION ==========
	config.set_value("progression", "unlocked_levels", Global.unlocked_levels)
	config.set_value("progression", "selected_level", Global.selected_level)
	config.set_value("progression", "level_highscores", Global.level_highscores)
	config.set_value("progression", "level_highest_combos", Global.level_highest_combos)
	config.set_value("progression", "wall_hp", Global.wall_hp)

	# Legacy arrays (deprecated but keep for compatibility)
	config.set_value("game", "highscores", Global.highscores)
	config.set_value("game", "highest_combos", Global.highest_combos)

	# ========== ECONOMY SECTION ==========
	config.set_value("economy", "coins", Global.coins)

	# ========== ITEMS SECTION ==========
	config.set_value("items", "data", Global.items)

	# ========== SETTINGS SECTION ==========
	config.set_value("settings", "sfx_volume", Audio.get_sfx_volume())
	config.set_value("settings", "music_volume", Audio.get_music_volume())
	config.set_value("settings", "screenshake_enabled", Global.screenshake_enabled)
	config.set_value("settings", "pixel_perfect", Global.pixel_perfect)

	# ========== BACKUP ==========
	# Erstelle Backup bevor wir überschreiben
	if FileAccess.file_exists(SAVE_PATH):
		var backup_error = DirAccess.copy_absolute(SAVE_PATH, BACKUP_PATH)
		if backup_error != OK:
			push_warning("Could not create backup: " + str(backup_error))

	# ========== SAVE TO DISK ==========
	var error = config.save(SAVE_PATH)
	if error != OK:
		push_error("Failed to save game: " + str(error))
		return false

	print("[SaveSystem] Game saved successfully")
	return true

# ============================================================================
# LOAD GAME
# ============================================================================

func load_game() -> bool:
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)

	if error != OK:
		print("[SaveSystem] No save file found, using defaults")
		_initialize_default_items()
		return false

	# ========== GAME SECTION ==========
	Global.total_highscore = config.get_value("game", "total_highscore", 0)
	Global.total_rounds_played = config.get_value("game", "total_rounds_played", 0)
	Global.total_playtime = config.get_value("game", "total_playtime", 0.0)

	# ========== PROGRESSION SECTION ==========
	Global.unlocked_levels = config.get_value("progression", "unlocked_levels", [1])
	Global.selected_level = config.get_value("progression", "selected_level", 1)
	Global.level_highscores = config.get_value("progression", "level_highscores", [0,0,0,0,0,0,0,0])
	Global.level_highest_combos = config.get_value("progression", "level_highest_combos", [0,0,0,0,0,0,0,0])
	Global.wall_hp = config.get_value("progression", "wall_hp", {1:1000,2:3500,3:8000,4:15000,5:25000,6:40000})

	# Legacy arrays (deprecated)
	Global.highscores = config.get_value("game", "highscores", [])
	Global.highest_combos = config.get_value("game", "highest_combos", [])

	# ========== ECONOMY SECTION ==========
	Global.coins = config.get_value("economy", "coins", 0)

	# ========== ITEMS SECTION ==========
	var saved_items = config.get_value("items", "data", {})
	_initialize_default_items()  # Stelle sicher, dass alle Items existieren

	# Merge saved data mit defaults (für neue Items)
	for item_id in saved_items:
		if Global.items.has(item_id):
			Global.items[item_id].owned = saved_items[item_id].get("owned", false)
			Global.items[item_id].active = saved_items[item_id].get("active", false)

	# ========== SETTINGS SECTION ==========
	var sfx_vol = config.get_value("settings", "sfx_volume", 1.0)
	var music_vol = config.get_value("settings", "music_volume", 0.7)
	Audio.set_sfx_volume(sfx_vol)
	Audio.set_music_volume(music_vol)
	Global.screenshake_enabled = config.get_value("settings", "screenshake_enabled", true)
	Global.pixel_perfect = config.get_value("settings", "pixel_perfect", false)

	print("[SaveSystem] Game loaded successfully")
	return true

# ============================================================================
# DEFAULT ITEMS INITIALIZATION
# ============================================================================

func _initialize_default_items():
	"""Initialisiert alle Items mit Default-Werten (falls noch nicht vorhanden)"""

	# Item-Definitionen (aus items.json - später aus Datei laden)
	var default_items = {
		"shockwave_fist": {
			"name": "Shockwave Fist",
			"cost": 500,
			"owned": false,
			"active": false,
			"description": "Verdoppelt Attack-Radius"
		},
		"iron_knuckles": {
			"name": "Iron Knuckles",
			"cost": 400,
			"owned": false,
			"active": false,
			"description": "Knockback-Effekt auf Gegner"
		},
		"time_crystal": {
			"name": "Time Crystal",
			"cost": 600,
			"owned": false,
			"active": false,
			"description": "Slow-Motion bei 10er Combo"
		},
		"fire_shield": {
			"name": "Fire Shield",
			"cost": 800,
			"owned": false,
			"active": false,
			"description": "Negiert 1 Projektil pro Runde"
		},
		"greed_magnet": {
			"name": "Greed Magnet",
			"cost": 300,
			"owned": false,
			"active": false,
			"description": "Zieht Coins an (200px Radius)"
		},
		"thunder_charge": {
			"name": "Thunder Charge",
			"cost": 900,
			"owned": false,
			"active": false,
			"description": "Kettenblitz bei 20er Combo"
		},
		"golem_skin": {
			"name": "Golem Skin",
			"cost": 1000,
			"owned": false,
			"active": false,
			"description": "+3 Extra Leben (HP 5→8)"
		},
		"call_of_wrath": {
			"name": "Call of Wrath",
			"cost": 1200,
			"owned": false,
			"active": false,
			"description": "Meteoriten + x2 Score bei 30+ Combo"
		},
		"golem_blessing": {
			"name": "Golem's Blessing",
			"cost": 700,
			"owned": false,
			"active": false,
			"description": "Wall regeneriert 1 HP/s (max 10% Total HP)"
		}
	}

	# Merge mit existierenden Items (behalte owned/active Status)
	for item_id in default_items:
		if not Global.items.has(item_id):
			Global.items[item_id] = default_items[item_id]
		else:
			# Update nur description/name/cost (nicht owned/active)
			Global.items[item_id].name = default_items[item_id].name
			Global.items[item_id].cost = default_items[item_id].cost
			Global.items[item_id].description = default_items[item_id].description

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

func delete_save() -> bool:
	"""Löscht den Save-File komplett"""
	if FileAccess.file_exists(SAVE_PATH):
		var error = DirAccess.remove_absolute(SAVE_PATH)
		if error == OK:
			print("[SaveSystem] Save file deleted")
			# Reset Global zu Defaults
			_reset_global_to_defaults()
			return true
		else:
			push_error("Failed to delete save: " + str(error))
			return false
	return true  # Kein File = schon gelöscht

func restore_backup() -> bool:
	"""Stellt Backup wieder her"""
	if FileAccess.file_exists(BACKUP_PATH):
		var error = DirAccess.copy_absolute(BACKUP_PATH, SAVE_PATH)
		if error == OK:
			print("[SaveSystem] Backup restored")
			load_game()
			return true
		else:
			push_error("Failed to restore backup: " + str(error))
			return false
	else:
		push_warning("No backup file found")
		return false

func _reset_global_to_defaults():
	"""Setzt alle Global-Variablen auf Default zurück"""
	Global.total_highscore = 0
	Global.unlocked_levels = 1
	Global.current_round_score = 0
	Global.coins = 0
	Global.highscores = []
	Global.highest_combos = []
	Global.total_rounds_played = 0
	Global.total_playtime = 0.0
	Global.items = {}
	Global.active_items = []
	Global.screenshake_enabled = true
	Global.pixel_perfect = false

	Audio.set_sfx_volume(1.0)
	Audio.set_music_volume(0.7)

	_initialize_default_items()

func save_exists() -> bool:
	"""Prüft ob ein Save-File existiert"""
	return FileAccess.file_exists(SAVE_PATH)

func get_save_path() -> String:
	"""Gibt den absoluten Pfad zum Save-File zurück (für Debugging)"""
	return ProjectSettings.globalize_path(SAVE_PATH)
