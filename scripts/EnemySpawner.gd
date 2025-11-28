# EnemySpawner.gd - Enemy Spawn Management mit Level-Kurven
extends Node2D

# ============================================================================
# CONFIGURATION
# ============================================================================

# Spawn-Position (links außerhalb Screen)
@export var spawn_x: float = -50.0
@export var spawn_y_min: float = 100.0
@export var spawn_y_max: float = 620.0

# ============================================================================
# LEVEL CURVES
# ============================================================================

# Spawn-Intervalle pro Level (Sekunden zwischen Spawns)
const SPAWN_INTERVALS = {
	1: 3.0,   # Level 1: Sehr langsam (Tutorial-Pace)
	2: 2.0,   # Level 2: Langsam
	3: 1.5,   # Level 3: Mittel
	4: 1.2,   # Level 4: Schnell
	5: 1.0,   # Level 5: Sehr schnell
	6: 0.8,   # Level 6: Extrem schnell
	7: 0.6,   # Level 7 (Endless): Maximum
}

# Enemy-Type-Verteilung pro Level (Gewichte)
# Format: { level: { Type: weight } }
const TYPE_WEIGHTS = {
	1: { Enemy.Type.INSECT: 100 },  # Nur Insekten
	2: { Enemy.Type.INSECT: 80, Enemy.Type.VASE_MONSTER: 20 },
	3: { Enemy.Type.INSECT: 60, Enemy.Type.VASE_MONSTER: 40 },
	4: { Enemy.Type.INSECT: 50, Enemy.Type.VASE_MONSTER: 40, Enemy.Type.FIRE_DEVIL: 10 },
	5: { Enemy.Type.INSECT: 40, Enemy.Type.VASE_MONSTER: 40, Enemy.Type.FIRE_DEVIL: 20 },
	6: { Enemy.Type.INSECT: 30, Enemy.Type.VASE_MONSTER: 40, Enemy.Type.FIRE_DEVIL: 30 },
	7: { Enemy.Type.INSECT: 20, Enemy.Type.VASE_MONSTER: 40, Enemy.Type.FIRE_DEVIL: 40 },
}

# Maximale gleichzeitige Enemies pro Level
const MAX_ENEMIES = {
	1: 3,
	2: 5,
	3: 7,
	4: 10,
	5: 12,
	6: 15,
	7: 20,  # Endless Mode
}

# ============================================================================
# PRELOADS
# ============================================================================

var EnemyScene = preload("res://Scenes/Enemy.tscn")

# ============================================================================
# STATE
# ============================================================================

var is_spawning: bool = false
var spawn_timer: float = 0.0
var current_interval: float = 3.0
var current_level: int = 1
var spawned_enemies: Array[Enemy] = []

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Setup basierend auf Global.selected_level
	current_level = Global.selected_level
	current_interval = SPAWN_INTERVALS.get(current_level, 2.0)

	print("[EnemySpawner] Ready - Level: ", current_level, " Interval: ", current_interval)

# ============================================================================
# PROCESS
# ============================================================================

func _process(delta: float):
	if not is_spawning:
		return

	# Update Timer
	spawn_timer -= delta

	if spawn_timer <= 0:
		# Spawn Enemy (wenn unter Max-Limit)
		if get_active_enemy_count() < MAX_ENEMIES.get(current_level, 10):
			spawn_enemy()
			spawn_timer = current_interval
		else:
			# Warte bis Slot frei wird
			spawn_timer = 0.2  # Check alle 200ms

# ============================================================================
# SPAWNING API
# ============================================================================

func start_spawning():
	"""Startet Enemy-Spawning"""
	is_spawning = true
	spawn_timer = current_interval
	print("[EnemySpawner] Started - Interval: ", current_interval)

func stop_spawning():
	"""Stoppt Enemy-Spawning"""
	is_spawning = false
	print("[EnemySpawner] Stopped")

func clear_all_enemies():
	"""Entfernt alle gespawnten Enemies"""
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	print("[EnemySpawner] All enemies cleared")

# ============================================================================
# SPAWNING LOGIC
# ============================================================================

func spawn_enemy():
	"""Spawnt einen Enemy basierend auf Level-Gewichten"""
	# Wähle Type basierend auf Gewichten
	var enemy_type = select_weighted_type()

	# Wähle zufällige Y-Position
	var spawn_y = randf_range(spawn_y_min, spawn_y_max)
	var spawn_pos = Vector2(spawn_x, spawn_y)

	# Instanziiere Enemy
	var enemy = EnemyScene.instantiate() as Enemy
	enemy.enemy_type = enemy_type
	enemy.position = spawn_pos

	# Füge zum Parent hinzu (GameScene)
	get_parent().get_parent().add_child(enemy)  # Spawners -> Game -> add

	# Tracke Enemy
	spawned_enemies.append(enemy)

	# Connect Death-Signal für Cleanup
	enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))

	print("[EnemySpawner] Spawned: ", Enemy.Type.keys()[enemy_type], " at ", spawn_pos)

func select_weighted_type() -> Enemy.Type:
	"""Wählt Enemy-Type basierend auf Level-Gewichten

	Verwendet Weighted Random Selection:
	- Level 1: 100% Insekt
	- Level 4: 50% Insekt, 40% Vase, 10% Fire
	- Level 7: 20% Insekt, 40% Vase, 40% Fire
	"""
	var weights = TYPE_WEIGHTS.get(current_level, { Enemy.Type.INSECT: 100 })

	# Berechne Total Weight
	var total_weight = 0
	for weight in weights.values():
		total_weight += weight

	# Zufällige Zahl zwischen 0 und total_weight
	var rand_value = randf() * total_weight

	# Finde entsprechenden Type
	var cumulative_weight = 0
	for type in weights:
		cumulative_weight += weights[type]
		if rand_value < cumulative_weight:
			return type

	# Fallback (sollte nie erreicht werden)
	return Enemy.Type.INSECT

# ============================================================================
# UTILITY
# ============================================================================

func get_active_enemy_count() -> int:
	"""Zählt aktive Enemies (cleaned up invalid references)"""
	# Cleanup invalid Enemies
	spawned_enemies = spawned_enemies.filter(func(e): return is_instance_valid(e))
	return spawned_enemies.size()

func set_spawn_interval(interval: float):
	"""Ändert Spawn-Intervall (für dynamische Schwierigkeit)"""
	current_interval = max(0.3, interval)  # Minimum 300ms
	print("[EnemySpawner] Interval changed to: ", current_interval)

func increase_difficulty():
	"""Erhöht Schwierigkeit (reduziert Intervall um 10%)"""
	current_interval *= 0.9
	current_interval = max(0.3, current_interval)
	print("[EnemySpawner] Difficulty increased - New interval: ", current_interval)

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_enemy_removed(enemy: Enemy):
	"""Enemy wurde aus Tree entfernt (Tod oder Despawn)"""
	if spawned_enemies.has(enemy):
		spawned_enemies.erase(enemy)
