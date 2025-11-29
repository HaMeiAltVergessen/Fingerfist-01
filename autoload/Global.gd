# Global.gd - Zentrale State-Verwaltung für Fingerfist
extends Node

# ============================================================================
# SCORE & PROGRESSION
# ============================================================================

var current_round_score: int = 0
var total_highscore: int = 0

# Level Progression
var unlocked_levels: Array[int] = [1]
var selected_level: int = 1

# Highscores pro Level (L1-7 + Endless)
var level_highscores: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0]
var level_highest_combos: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0]

# ============================================================================
# ECONOMY
# ============================================================================

var coins: int = 0

# ============================================================================
# WALL HP VALUES
# ============================================================================

const WALL_HP_PER_LEVEL = {
	1: 1000,
	2: 3500,
	3: 8000,
	4: 15000,
	5: 25000,
	6: 40000,
	# Level 7 = Endless Mode (keine Wand)
}

# Persistent Wall HP per Level (tracks remaining HP across sessions)
var wall_hp: Dictionary = {
	1: 1000,
	2: 3500,
	3: 8000,
	4: 15000,
	5: 25000,
	6: 40000,
}

# Difficulty Multipliers
var wall_damage_multiplier: float = 1.0

# ============================================================================
# ITEMS
# ============================================================================

var items: Dictionary = {}
var active_items: Array[String] = []

# Item-spezifische Flags
var fire_shield_used: bool = false
var score_multiplier: float = 1.0

# ============================================================================
# HIGHSCORES & STATISTICS
# ============================================================================

var highscores: Array = []
var highest_combos: Array = []
var total_rounds_played: int = 0
var total_playtime: float = 0.0

# ============================================================================
# SETTINGS
# ============================================================================

var screenshake_enabled: bool = true
var pixel_perfect: bool = false

# ============================================================================
# SIGNALS
# ============================================================================

signal score_changed(new_score: int)
signal coins_changed(new_coins: int)

# ============================================================================
# SCORE MANAGEMENT
# ============================================================================

func add_score(amount: int):
	current_round_score += amount
	score_changed.emit(current_round_score)

func reset_round_score():
	current_round_score = 0
	score_multiplier = 1.0
	fire_shield_used = false

# ============================================================================
# COIN MANAGEMENT
# ============================================================================

func add_coins(amount: int):
	coins += amount
	coins_changed.emit(coins)

# ============================================================================
# ITEM MANAGEMENT
# ============================================================================

func buy_item(item_id: String) -> bool:
	if not items.has(item_id):
		return false

	var item = items[item_id]
	if item.get("owned", false):
		return false

	if coins >= item.cost:
		coins -= item.cost
		items[item_id].owned = true
		coins_changed.emit(coins)
		return true

	return false

func activate_item(item_id: String):
	if items.get(item_id, {}).get("owned", false) and item_id not in active_items:
		active_items.append(item_id)
		items[item_id].active = true

func deactivate_item(item_id: String):
	active_items.erase(item_id)
	if items.has(item_id):
		items[item_id].active = false

func deactivate_all_items():
	for item_id in active_items:
		if items.has(item_id):
			items[item_id].active = false
	active_items.clear()
	fire_shield_used = false
	score_multiplier = 1.0

func is_item_active(item_id: String) -> bool:
	return item_id in active_items

# ============================================================================
# PROGRESSION
# ============================================================================

func get_wall_remaining_hp(level_id: int) -> float:
	"""Gibt verbleibende Wall-HP für Level zurück (persistent)"""
	if level_id == 7:
		return 0.0  # Endless Mode

	if not wall_hp.has(level_id):
		return WALL_HP_PER_LEVEL.get(level_id, 0.0)

	return wall_hp.get(level_id, 0.0)

func update_wall_hp(level_id: int, current_hp: float):
	"""Updated persistente Wall-HP für Level"""
	if level_id == 7:
		return  # Endless Mode hat keine Wall

	wall_hp[level_id] = max(0.0, current_hp)
	save_game()

func reset_wall_hp(level_id: int):
	"""Setzt Wall-HP für Level zurück (auf Max)"""
	if level_id == 7:
		return

	if WALL_HP_PER_LEVEL.has(level_id):
		wall_hp[level_id] = WALL_HP_PER_LEVEL[level_id]
		save_game()

func reset_all_wall_hp():
	"""Setzt alle Wall-HP zurück"""
	for level in WALL_HP_PER_LEVEL:
		wall_hp[level] = WALL_HP_PER_LEVEL[level]
	save_game()

# ============================================================================
# LEVEL UNLOCK SYSTEM
# ============================================================================

func unlock_next_level(current_level: int):
	"""Schaltet nächstes Level frei"""
	var next_level = current_level + 1

	if next_level > 7:
		print("[Global] All levels unlocked")
		return

	if unlocked_levels.has(next_level):
		print("[Global] Level %d already unlocked" % next_level)
		return

	unlocked_levels.append(next_level)
	unlocked_levels.sort()
	save_game()

	print("[Global] Level %d UNLOCKED! 🎉" % next_level)

func is_level_unlocked(level: int) -> bool:
	"""Prüft ob Level freigeschaltet ist"""
	return unlocked_levels.has(level)

func get_unlocked_levels() -> Array[int]:
	"""Gibt alle freigeschalteten Levels zurück"""
	return unlocked_levels.duplicate()

func reset_progression():
	"""Setzt Progression zurück (für Debug/Reset)"""
	unlocked_levels = [1]
	selected_level = 1
	level_highscores = [0, 0, 0, 0, 0, 0, 0, 0]
	level_highest_combos = [0, 0, 0, 0, 0, 0, 0, 0]
	save_game()

# ============================================================================
# HIGHSCORE SYSTEM
# ============================================================================

func update_highscore(level: int, score: int) -> bool:
	"""Updated Highscore für Level

	Returns:
		true wenn neuer Highscore, false wenn nicht
	"""
	if level < 1 or level > 7:
		return false

	var index = level
	var old_highscore = level_highscores[index]

	if score > old_highscore:
		level_highscores[index] = score
		save_game()
		print("[Global] NEW HIGHSCORE Level %d: %d" % [level, score])
		return true

	return false

func get_highscore(level: int) -> int:
	"""Gibt Highscore für Level zurück"""
	if level < 1 or level > 7:
		return 0
	return level_highscores[level]

func update_highest_combo(level: int, combo: int):
	"""Updated Highest Combo für Level"""
	if level < 1 or level > 7:
		return

	var index = level
	if combo > level_highest_combos[index]:
		level_highest_combos[index] = combo
		save_game()
		print("[Global] NEW COMBO Level %d: x%d" % [level, combo])

func get_highest_combo(level: int) -> int:
	"""Gibt Highest Combo für Level zurück"""
	if level < 1 or level > 7:
		return 0
	return level_highest_combos[level]

func end_round():
	# Update Total Highscore
	total_highscore += current_round_score

	# Update Highscores List (Top 10)
	highscores.append(current_round_score)
	highscores.sort()
	highscores.reverse()
	if highscores.size() > 10:
		highscores.resize(10)

	# Statistics
	total_rounds_played += 1

	# Reset Round Data
	reset_round_score()

# ============================================================================
# PLAYTIME TRACKING
# ============================================================================

func _process(delta: float):
	if not get_tree().paused:
		total_playtime += delta

# ============================================================================
# SAVE INTEGRATION
# ============================================================================

func save_game():
	SaveSystem.save_game()

func load_game():
	SaveSystem.load_game()
