# Global.gd - Zentrale State-Verwaltung für Fingerfist
extends Node

# ============================================================================
# SCORE & PROGRESSION
# ============================================================================

var current_round_score: int = 0
var total_highscore: int = 0
var unlocked_levels: int = 1
var selected_level: int = 1

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
	if level_id == 7:
		return 0.0  # Endless Mode

	if not WALL_HP_PER_LEVEL.has(level_id):
		return 0.0

	var max_hp = WALL_HP_PER_LEVEL[level_id]
	var remaining = max_hp - total_highscore
	return max(0.0, remaining)

func unlock_next_level(current_level: int):
	unlocked_levels = max(unlocked_levels, current_level + 1)

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
