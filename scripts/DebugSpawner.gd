# DebugSpawner.gd - Manuelles Enemy-Spawning für Tests
extends Node2D

# ============================================================================
# CONFIGURATION
# ============================================================================

@export var spawn_position: Vector2 = Vector2(200, 360)
@export var auto_spawn: bool = false
@export var spawn_interval: float = 2.0

# ============================================================================
# PRELOADS
# ============================================================================

var EnemyScene = preload("res://Scenes/Enemy.tscn")

# ============================================================================
# STATE
# ============================================================================

var spawn_timer: float = 0.0

# ============================================================================
# PROCESS
# ============================================================================

func _process(delta: float):
	if auto_spawn:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_random_enemy()
			spawn_timer = spawn_interval

func _input(event: InputEvent):
	# Keyboard Shortcuts für manuelles Spawning
	if event.is_action_pressed("ui_accept"):  # Space
		spawn_random_enemy()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				spawn_enemy(Enemy.Type.INSECT)
			KEY_2:
				spawn_enemy(Enemy.Type.VASE_MONSTER)
			KEY_3:
				spawn_enemy(Enemy.Type.FIRE_DEVIL)

# ============================================================================
# SPAWNING
# ============================================================================

func spawn_random_enemy():
	"""Spawnt zufälligen Enemy-Typ"""
	var types = [Enemy.Type.INSECT, Enemy.Type.VASE_MONSTER, Enemy.Type.FIRE_DEVIL]
	var random_type = types[randi() % types.size()]
	spawn_enemy(random_type)

func spawn_enemy(type: Enemy.Type):
	"""Spawnt spezifischen Enemy-Typ"""
	var enemy = EnemyScene.instantiate() as Enemy
	enemy.enemy_type = type
	enemy.position = spawn_position
	get_parent().add_child(enemy)

	print("[DebugSpawner] Spawned: ", Enemy.Type.keys()[type], " at ", spawn_position)

# ============================================================================
# DEBUG INFO
# ============================================================================

func _ready():
	print("=== DEBUG SPAWNER READY ===")
	print("Controls:")
	print("  SPACE - Spawn random enemy")
	print("  1 - Spawn Insect")
	print("  2 - Spawn Vase Monster")
	print("  3 - Spawn Fire Devil")
	print("  Auto-Spawn: ", auto_spawn)
