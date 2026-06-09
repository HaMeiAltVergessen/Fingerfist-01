# EnemySpawner.gd - Enemy Spawn Management mit Level-Kurven
extends Node2D

# ============================================================================
# CONFIGURATION
# ============================================================================

# Spawn-Position (links außerhalb Screen)
@export var spawn_x: float = -50.0
@export var spawn_y_min: float = 100.0
@export var spawn_y_max: float = 620.0

# Lanes: Boden-Gegner laufen auf der Spielerlinie, Insekten fliegen darüber
const LANE_GROUND_Y: float = 550.0   # Vase, Feuerteufel (Spielerlinie)
const LANE_FLY_Y: float = 550.0      # Insekten (eigene Fluglinie)

# ============================================================================
# LEVEL CURVES
# ============================================================================

# Spawn-Intervalle pro Level (Sekunden zwischen Spawns) - halbiert (doppelter Spawn)
const SPAWN_INTERVALS = {
	1: 1.5,   # Level 1: Sehr langsam (Tutorial-Pace)
	2: 1.0,   # Level 2: Langsam
	3: 0.75,  # Level 3: Mittel
	4: 0.6,   # Level 4: Schnell
	5: 0.5,   # Level 5: Sehr schnell
	6: 0.4,   # Level 6: Extrem schnell
	7: 0.3,   # Level 7 (Endless): Maximum
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

# Maximale gleichzeitige Enemies pro Level - verdoppelt (doppelter Spawn)
const MAX_ENEMIES = {
	1: 6,
	2: 10,
	3: 14,
	4: 20,
	5: 24,
	6: 30,
	7: 40,  # Endless Mode
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

# Im Editor platzierte Spawnpunkte (Marker2D in Gruppe "spawn_points").
# Werden in start_spawning() einmalig gecacht. Leer => Default-Spawnverhalten.
var spawn_points: Array[Vector2] = []

# ============================================================================
# SPAWN PATTERNS
# ============================================================================

enum SpawnPattern {
	SINGLE,     # 1 Enemy
	WAVE_2,     # 2 Enemies vertikal
	WAVE_3,     # 3 Enemies vertikal
	CLUSTER,    # 2-3 Enemies eng zusammen
	SPREAD,     # 2-3 Enemies weit auseinander
}

# Pattern-Wahrscheinlichkeiten pro Level
const PATTERN_WEIGHTS = {
	1: { SpawnPattern.SINGLE: 100 },  # Nur Singles
	2: { SpawnPattern.SINGLE: 80, SpawnPattern.WAVE_2: 20 },
	3: { SpawnPattern.SINGLE: 60, SpawnPattern.WAVE_2: 30, SpawnPattern.CLUSTER: 10 },
	4: { SpawnPattern.SINGLE: 40, SpawnPattern.WAVE_2: 30, SpawnPattern.WAVE_3: 15, SpawnPattern.CLUSTER: 15 },
	5: { SpawnPattern.SINGLE: 30, SpawnPattern.WAVE_2: 25, SpawnPattern.WAVE_3: 20, SpawnPattern.CLUSTER: 15, SpawnPattern.SPREAD: 10 },
	6: { SpawnPattern.SINGLE: 20, SpawnPattern.WAVE_2: 20, SpawnPattern.WAVE_3: 25, SpawnPattern.CLUSTER: 20, SpawnPattern.SPREAD: 15 },
	7: { SpawnPattern.SINGLE: 10, SpawnPattern.WAVE_2: 20, SpawnPattern.WAVE_3: 30, SpawnPattern.CLUSTER: 20, SpawnPattern.SPREAD: 20 },
}

var current_pattern: SpawnPattern = SpawnPattern.SINGLE

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
		# Prüfe Pattern-spezifische Max-Limits
		var pattern = select_weighted_pattern()
		var enemies_to_spawn = get_pattern_enemy_count(pattern)

		# Spawn wenn genug Slots frei
		if get_active_enemy_count() + enemies_to_spawn <= MAX_ENEMIES.get(current_level, 10):
			spawn_enemy()
			spawn_timer = current_interval
		else:
			# Warte bis genug Slots frei
			spawn_timer = 0.2

func get_pattern_enemy_count(pattern: SpawnPattern) -> int:
	"""Gibt Anzahl Enemies zurück die ein Pattern spawnt"""
	match pattern:
		SpawnPattern.SINGLE:
			return 1
		SpawnPattern.WAVE_2:
			return 2
		SpawnPattern.WAVE_3:
			return 3
		SpawnPattern.CLUSTER:
			return randi_range(2, 3)
		SpawnPattern.SPREAD:
			return randi_range(2, 3)
	return 1

# ============================================================================
# SPAWNING API
# ============================================================================

func start_spawning():
	"""Startet Enemy-Spawning"""
	refresh_spawn_points()
	is_spawning = true
	spawn_timer = current_interval
	print("[EnemySpawner] Started - Interval: ", current_interval, " - Spawnpunkte: ", spawn_points.size())

func refresh_spawn_points():
	"""Liest die im Editor platzierten Spawnpunkte (Marker2D in Gruppe 'spawn_points')
	und cacht ihre globalen Positionen."""
	spawn_points.clear()
	for node in get_tree().get_nodes_in_group("spawn_points"):
		if node is Node2D:
			spawn_points.append((node as Node2D).global_position)

func has_spawn_points() -> bool:
	return spawn_points.size() > 0

func _pick_distinct_points(count: int) -> Array[Vector2]:
	"""Wählt count möglichst verschiedene Spawnpunkte. Sind weniger Punkte vorhanden
	als benötigt, werden Punkte mit kleinem vertikalen Offset wiederverwendet."""
	var result: Array[Vector2] = []
	if spawn_points.is_empty():
		return result

	var pool := spawn_points.duplicate()
	pool.shuffle()
	for i in range(count):
		if i < pool.size():
			result.append(pool[i])
		else:
			var base: Vector2 = pool[i % pool.size()]
			result.append(base + Vector2(0, randf_range(-40.0, 40.0)))
	return result

func _fallback_position(enemy_type: Enemy.Type) -> Vector2:
	"""Default-Spawnposition, wenn keine Spawnpunkte definiert sind.
	Insekten fliegen, alle anderen laufen auf dem Boden (altes Lane-Verhalten)."""
	var lane_y := LANE_FLY_Y if enemy_type == Enemy.Type.INSECT else LANE_GROUND_Y
	return Vector2(spawn_x, lane_y)

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
	"""Spawnt Enemy(s) basierend auf Pattern"""
	# Wähle Pattern basierend auf Level
	current_pattern = select_weighted_pattern()

	match current_pattern:
		SpawnPattern.SINGLE:
			spawn_single()
		SpawnPattern.WAVE_2:
			spawn_wave(2)
		SpawnPattern.WAVE_3:
			spawn_wave(3)
		SpawnPattern.CLUSTER:
			spawn_cluster()
		SpawnPattern.SPREAD:
			spawn_spread()

func spawn_single():
	"""Spawnt einzelnen Enemy an einem zufälligen Spawnpunkt"""
	var enemy_type = select_weighted_type()
	var spawn_pos: Vector2
	if has_spawn_points():
		spawn_pos = spawn_points.pick_random()
	else:
		spawn_pos = _fallback_position(enemy_type)

	_instantiate_enemy(enemy_type, spawn_pos)

func spawn_wave(count: int):
	"""Spawnt eine Welle von Enemies auf mehreren verschiedenen Spawnpunkten"""
	var enemy_type = select_weighted_type()

	if has_spawn_points():
		for spawn_pos in _pick_distinct_points(count):
			_instantiate_enemy(enemy_type, spawn_pos)
		return

	# Fallback: vertikale Welle wie bisher
	var spacing = 120.0 if count == 2 else 100.0
	var total_height = (count - 1) * spacing
	var center_y = (spawn_y_min + spawn_y_max) / 2.0
	var start_y = center_y - (total_height / 2.0)

	for i in range(count):
		var spawn_y = clamp(start_y + (i * spacing), spawn_y_min, spawn_y_max)
		_instantiate_enemy(enemy_type, Vector2(spawn_x, spawn_y))

func spawn_cluster():
	"""Spawnt 2-3 Enemies eng zusammen (um einen Spawnpunkt herum)"""
	var enemy_type = select_weighted_type()
	var count = randi_range(2, 3)

	if has_spawn_points():
		var center: Vector2 = spawn_points.pick_random()
		for i in range(count):
			var spawn_pos = center + Vector2(randf_range(-30.0, 30.0), randf_range(-50.0, 50.0))
			_instantiate_enemy(enemy_type, spawn_pos)
			await get_tree().create_timer(0.05).timeout
		return

	# Fallback: Cluster auf der Lane wie bisher
	var center_y = randf_range(spawn_y_min + 100, spawn_y_max - 100)
	for i in range(count):
		var spawn_y = clamp(center_y + randf_range(-50, 50), spawn_y_min, spawn_y_max)
		_instantiate_enemy(enemy_type, Vector2(spawn_x, spawn_y))
		await get_tree().create_timer(0.05).timeout

func spawn_spread():
	"""Spawnt 2-3 Enemies weit auseinander (auf verschiedenen Spawnpunkten)"""
	var enemy_type = select_weighted_type()
	var count = randi_range(2, 3)

	if has_spawn_points():
		for spawn_pos in _pick_distinct_points(count):
			_instantiate_enemy(enemy_type, spawn_pos)
		return

	# Fallback: gleichmäßige Verteilung über Screen-Höhe
	var sections = spawn_y_max - spawn_y_min
	var section_size = sections / count
	for i in range(count):
		var section_center = spawn_y_min + (i * section_size) + (section_size / 2.0)
		var spawn_y = clamp(randf_range(section_center - 30, section_center + 30), spawn_y_min, spawn_y_max)
		_instantiate_enemy(enemy_type, Vector2(spawn_x, spawn_y))

func _instantiate_enemy(enemy_type: Enemy.Type, spawn_pos: Vector2):
	"""Hilfsfunktion: Erstellt Enemy an Position.

	Verwendet die übergebene Position (x UND y) direkt - bei Spawnpunkten bestimmt
	also der im Editor platzierte Marker die Position. Kleiner X-Versatz verhindert
	exakte Überlappung bei Mehrfach-Spawns auf demselben Punkt."""
	var enemy = EnemyScene.instantiate() as Enemy
	enemy.enemy_type = enemy_type

	enemy.position = Vector2(spawn_pos.x + randf_range(-60.0, 0.0), spawn_pos.y)

	# Füge zum Parent hinzu
	get_parent().get_parent().add_child(enemy)

	# Tracke Enemy
	spawned_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))

	print("[EnemySpawner] Spawned: ", Enemy.Type.keys()[enemy_type], " at ", spawn_pos)

func select_weighted_pattern() -> SpawnPattern:
	"""Wählt Spawn-Pattern basierend auf Level-Gewichten"""
	var weights = PATTERN_WEIGHTS.get(current_level, { SpawnPattern.SINGLE: 100 })

	var total_weight = 0
	for weight in weights.values():
		total_weight += weight

	var rand_value = randf() * total_weight
	var cumulative_weight = 0

	for pattern in weights:
		cumulative_weight += weights[pattern]
		if rand_value < cumulative_weight:
			return pattern

	return SpawnPattern.SINGLE

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

# ============================================================================
# DEBUG
# ============================================================================

func get_pattern_stats() -> Dictionary:
	"""Gibt Pattern-Statistiken zurück (für Testing)"""
	return {
		"current_pattern": SpawnPattern.keys()[current_pattern],
		"active_enemies": get_active_enemy_count(),
		"max_enemies": MAX_ENEMIES.get(current_level, 10),
		"spawn_interval": current_interval,
	}
