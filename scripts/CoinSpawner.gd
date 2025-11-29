# CoinSpawner.gd - Periodic Coin Spawning
extends Node2D

# ============================================================================
# CONFIGURATION
# ============================================================================

# Spawn-Bereich (über dem Screen)
@export var spawn_x_min: float = 100.0
@export var spawn_x_max: float = 1180.0
@export var spawn_y: float = -50.0  # Über Screen

# ============================================================================
# LEVEL CURVES
# ============================================================================

# Spawn-Intervalle pro Level (Sekunden zwischen Coin-Spawns)
const SPAWN_INTERVALS = {
	1: 8.0,   # Level 1: Sehr selten
	2: 6.0,   # Level 2: Selten
	3: 5.0,   # Level 3: Mittel
	4: 4.0,   # Level 4: Oft
	5: 3.5,   # Level 5: Sehr oft
	6: 3.0,   # Level 6: Häufig
	7: 2.5,   # Level 7 (Endless): Maximum
}

# Coin-Type-Verteilung pro Level (Gewichte)
const TYPE_WEIGHTS = {
	1: { Coin.CoinType.BRONZE: 100 },  # Nur Bronze
	2: { Coin.CoinType.BRONZE: 85, Coin.CoinType.SILVER: 15 },
	3: { Coin.CoinType.BRONZE: 70, Coin.CoinType.SILVER: 25, Coin.CoinType.GOLD: 5 },
	4: { Coin.CoinType.BRONZE: 60, Coin.CoinType.SILVER: 30, Coin.CoinType.GOLD: 10 },
	5: { Coin.CoinType.BRONZE: 50, Coin.CoinType.SILVER: 35, Coin.CoinType.GOLD: 13, Coin.CoinType.PLATINUM: 2 },
	6: { Coin.CoinType.BRONZE: 45, Coin.CoinType.SILVER: 35, Coin.CoinType.GOLD: 17, Coin.CoinType.PLATINUM: 3 },
	7: { Coin.CoinType.BRONZE: 40, Coin.CoinType.SILVER: 35, Coin.CoinType.GOLD: 20, Coin.CoinType.PLATINUM: 5 },
}

# Coins pro Spawn (min-max Range)
const COINS_PER_SPAWN = {
	1: Vector2i(1, 1),    # Immer 1 Coin
	2: Vector2i(1, 2),    # 1-2 Coins
	3: Vector2i(1, 2),
	4: Vector2i(1, 3),    # 1-3 Coins
	5: Vector2i(2, 3),    # 2-3 Coins
	6: Vector2i(2, 4),    # 2-4 Coins
	7: Vector2i(2, 5),    # 2-5 Coins (Coin-Regen)
}

# ============================================================================
# PRELOADS
# ============================================================================

var CoinScene = preload("res://Scenes/Coin.tscn")

# ============================================================================
# STATE
# ============================================================================

var is_spawning: bool = false
var spawn_timer: float = 0.0
var current_interval: float = 8.0
var current_level: int = 1

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Setup basierend auf Global.selected_level
	current_level = Global.selected_level
	current_interval = SPAWN_INTERVALS.get(current_level, 6.0)

	print("[CoinSpawner] Ready - Level: ", current_level, " Interval: ", current_interval)

# ============================================================================
# PROCESS
# ============================================================================

func _process(delta: float):
	if not is_spawning:
		return

	# Update Timer
	spawn_timer -= delta

	if spawn_timer <= 0:
		spawn_coins()
		spawn_timer = current_interval

# ============================================================================
# SPAWNING API
# ============================================================================

func start_spawning():
	"""Startet Coin-Spawning"""
	is_spawning = true
	spawn_timer = current_interval
	print("[CoinSpawner] Started - Interval: ", current_interval)

func stop_spawning():
	"""Stoppt Coin-Spawning"""
	is_spawning = false
	print("[CoinSpawner] Stopped")

func clear_all_coins():
	"""Entfernt alle gespawnten Coins"""
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		if is_instance_valid(coin):
			coin.queue_free()
	print("[CoinSpawner] All coins cleared")

# ============================================================================
# SPAWNING LOGIC
# ============================================================================

func spawn_coins():
	"""Spawnt 1-5 Coins (abhängig von Level)"""
	var coins_range = COINS_PER_SPAWN.get(current_level, Vector2i(1, 2))
	var count = randi_range(coins_range.x, coins_range.y)

	for i in range(count):
		spawn_single_coin()

		# Kleines Delay zwischen Coins (visuell)
		if i < count - 1:
			await get_tree().create_timer(0.05).timeout

	print("[CoinSpawner] Spawned ", count, " coins")

func spawn_single_coin():
	"""Spawnt einzelnen Coin"""
	# Wähle Type basierend auf Gewichten
	var coin_type = select_weighted_type()

	# Zufällige X-Position
	var spawn_x = randf_range(spawn_x_min, spawn_x_max)
	var spawn_pos = Vector2(spawn_x, spawn_y)

	# Instanziiere Coin
	var coin = CoinScene.instantiate() as Coin
	coin.coin_type = coin_type
	coin.position = spawn_pos

	# Initiale Velocity (nach unten, leicht horizontal)
	var horizontal_force = randf_range(-30, 30)
	coin.velocity = Vector2(horizontal_force, 200)  # Sanft nach unten

	# Füge zum Parent hinzu (GameScene)
	get_parent().get_parent().add_child(coin)

func select_weighted_type() -> Coin.CoinType:
	"""Wählt Coin-Type basierend auf Level-Gewichten"""
	var weights = TYPE_WEIGHTS.get(current_level, { Coin.CoinType.BRONZE: 100 })

	var total_weight = 0
	for weight in weights.values():
		total_weight += weight

	var rand_value = randf() * total_weight
	var cumulative_weight = 0

	for type in weights:
		cumulative_weight += weights[type]
		if rand_value < cumulative_weight:
			return type

	return Coin.CoinType.BRONZE

# ============================================================================
# SPECIAL SPAWN MODES
# ============================================================================

func spawn_coin_rain(count: int = 10):
	"""Spawnt Coin-Regen (viele Coins auf einmal)

	Verwendet für:
	- Combo-Belohnung (30+ Combo)
	- Item-Effekt
	- Boss-Death
	"""
	print("[CoinSpawner] Coin Rain: ", count, " coins")

	for i in range(count):
		# Random Position über ganzer Screen-Breite
		var spawn_x = randf_range(spawn_x_min, spawn_x_max)
		var spawn_pos = Vector2(spawn_x, spawn_y)

		# Random Type (höhere Chance auf wertvolle Coins)
		var coin_type: Coin.CoinType
		var rand = randf()
		if rand < 0.3:
			coin_type = Coin.CoinType.GOLD
		elif rand < 0.6:
			coin_type = Coin.CoinType.SILVER
		else:
			coin_type = Coin.CoinType.BRONZE

		# Instanziiere Coin
		var coin = CoinScene.instantiate() as Coin
		coin.coin_type = coin_type
		coin.position = spawn_pos

		# Velocity (schneller nach unten)
		var horizontal_force = randf_range(-50, 50)
		coin.velocity = Vector2(horizontal_force, 300)

		# Füge hinzu
		get_parent().get_parent().add_child(coin)

		# Delay
		await get_tree().create_timer(0.02).timeout

func spawn_jackpot():
	"""Spawnt Jackpot (alle 4 Coin-Types gleichzeitig)"""
	print("[CoinSpawner] JACKPOT!")

	var types = [
		Coin.CoinType.BRONZE,
		Coin.CoinType.SILVER,
		Coin.CoinType.GOLD,
		Coin.CoinType.PLATINUM,
	]

	for i in range(types.size()):
		var coin_type = types[i]
		var spawn_x = spawn_x_min + (i * 300) + 150  # Gleichmäßig verteilt
		var spawn_pos = Vector2(spawn_x, spawn_y)

		var coin = CoinScene.instantiate() as Coin
		coin.coin_type = coin_type
		coin.position = spawn_pos
		coin.velocity = Vector2(0, 250)

		get_parent().get_parent().add_child(coin)

# ============================================================================
# UTILITY
# ============================================================================

func set_spawn_interval(interval: float):
	"""Ändert Spawn-Intervall"""
	current_interval = max(1.0, interval)
	print("[CoinSpawner] Interval changed to: ", current_interval)

func get_active_coin_count() -> int:
	"""Zählt aktive Coins"""
	return get_tree().get_nodes_in_group("coins").size()
