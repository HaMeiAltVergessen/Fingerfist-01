# Enemy.gd - Gegner-Basisklasse mit 3 Typen
extends CharacterBody2D
class_name Enemy

# ============================================================================
# ENEMY TYPES
# ============================================================================

enum Type { INSECT, VASE_MONSTER, FIRE_DEVIL }

@export var enemy_type: Type = Type.INSECT

# ============================================================================
# TYPE CONFIGURATION
# ============================================================================

const TYPE_CONFIG = {
	Type.INSECT: {
		"speed": 150.0,
		"score": 10,
		"hitbox_radius": 12.0,
		"color": Color(0.3, 0.8, 0.3),  # Green
		"coin_drop_chance": 0.05,
		"sfx_death": ["insect_death_01.ogg", "insect_death_02.ogg", "insect_death_03.ogg"]
	},
	Type.VASE_MONSTER: {
		"speed": 80.0,
		"score": 25,
		"hitbox_size": Vector2(16, 20),
		"color": Color(0.8, 0.5, 0.3),  # Brown/Terra
		"coin_drop_chance": 0.15,
		"attack_windup_time": 0.35,
		"attack_range": 100.0,
		"sfx_death": ["vase_break_01.ogg", "vase_break_02.ogg", "vase_break_03.ogg"],
		"sfx_windup": "vase_windup.ogg",
		"sfx_attack": ["vase_attack_01.ogg", "vase_attack_02.ogg"]
	},
	Type.FIRE_DEVIL: {
		"speed": 30.0,
		"score": 40,
		"hitbox_radius": 14.0,
		"color": Color(0.9, 0.3, 0.2),  # Orange-Red
		"coin_drop_chance": 0.25,
		"projectile_interval": 5.0,
		"projectile_telegraph_time": 0.4,
		"projectile_range": 700.0,
		"sfx_death": ["fire_extinguish_01.ogg", "fire_extinguish_02.ogg", "fire_extinguish_03.ogg"],
		"sfx_charge": "projectile_charge.ogg",
		"sfx_fire": "projectile_fire.ogg"
	}
}

# ============================================================================
# STATS
# ============================================================================

var speed: float = 150.0
var score_value: int = 10
var is_alive: bool = true
var coin_drop_chance: float = 0.05

# ============================================================================
# VASE MONSTER SPECIFIC
# ============================================================================

var is_attacking: bool = false
var attack_windup_timer: float = 0.0
var attack_target: Player = null

# ============================================================================
# FIRE DEVIL SPECIFIC
# ============================================================================

var projectile_timer: float = 0.0
var is_charging_projectile: bool = false

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var sprite: Sprite2D = $EnemySprite
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitboxShape

# ============================================================================
# PRELOADS
# ============================================================================

var ProjectileScene = preload("res://Scenes/Projectile.tscn")
var CoinScene = preload("res://Scenes/Coin.tscn")

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Load Type Config
	var config = TYPE_CONFIG[enemy_type]
	speed = config.speed
	score_value = config.score
	coin_drop_chance = config.get("coin_drop_chance", 0.05)

	# Visual Setup
	sprite.modulate = config.color

	# Hitbox Setup
	_setup_hitbox(config)

	# Add to Group
	add_to_group("enemies")

	# Type-specific initialization
	if enemy_type == Type.FIRE_DEVIL:
		projectile_timer = randf_range(2.0, 5.0)  # Random initial delay

	print("[Enemy] Spawned: ", Type.keys()[enemy_type], " Speed: ", speed)

func _setup_hitbox(config: Dictionary):
	"""Konfiguriert Hitbox basierend auf Typ"""
	if config.has("hitbox_radius"):
		# Circle Hitbox (Insect, Fire Devil)
		var shape = CircleShape2D.new()
		shape.radius = config.hitbox_radius
		hitbox_shape.shape = shape
	elif config.has("hitbox_size"):
		# Rectangle Hitbox (Vase Monster)
		var shape = RectangleShape2D.new()
		shape.size = config.hitbox_size
		hitbox_shape.shape = shape

# ============================================================================
# PHYSICS PROCESS
# ============================================================================

func _physics_process(delta: float):
	if not is_alive:
		return

	# Type-specific behavior
	match enemy_type:
		Type.INSECT:
			_process_insect(delta)
		Type.VASE_MONSTER:
			_process_vase_monster(delta)
		Type.FIRE_DEVIL:
			_process_fire_devil(delta)

	# Apply movement
	move_and_slide()

# ============================================================================
# INSECT BEHAVIOR
# ============================================================================

func _process_insect(delta: float):
	"""Einfache lineare Bewegung nach rechts"""
	velocity.x = speed
	velocity.y = 0

# ============================================================================
# VASE MONSTER BEHAVIOR
# ============================================================================

func _process_vase_monster(delta: float):
	"""Bewegt sich nach rechts, stoppt bei Player-Nähe für Attack"""

	# Finde Player
	if not attack_target:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			attack_target = players[0]

	if not attack_target:
		# Kein Player gefunden, normale Bewegung
		velocity.x = speed
		velocity.y = 0
		return

	var distance_to_player = global_position.distance_to(attack_target.global_position)
	var config = TYPE_CONFIG[Type.VASE_MONSTER]

	if is_attacking:
		# Windup Phase
		velocity.x = 0
		velocity.y = 0
		attack_windup_timer -= delta

		if attack_windup_timer <= 0:
			# Attack ausführen
			_execute_vase_attack()
			is_attacking = false

	elif distance_to_player < config.attack_range:
		# In Attack Range - starte Windup
		if not is_attacking:
			is_attacking = true
			attack_windup_timer = config.attack_windup_time
			Audio.play_sfx(config.sfx_windup)

	else:
		# Außerhalb Range - normale Bewegung
		velocity.x = speed
		velocity.y = 0

func _execute_vase_attack():
	"""Führt Vase Monster Attack aus (schneller Dash)"""
	var config = TYPE_CONFIG[Type.VASE_MONSTER]

	# SFX
	var sfx_list = config.sfx_attack
	Audio.play_sfx(sfx_list[randi() % sfx_list.size()])

	# Dash nach rechts (3x normale Speed)
	velocity.x = speed * 3.0
	velocity.y = 0

	# Nach 0.3s zurück zu normaler Speed
	await get_tree().create_timer(0.3).timeout
	if is_alive:
		velocity.x = speed

# ============================================================================
# FIRE DEVIL BEHAVIOR
# ============================================================================

func _process_fire_devil(delta: float):
	"""Langsame Bewegung + periodische Projektile"""
	# Langsame Bewegung
	velocity.x = speed
	velocity.y = 0

	# Projektil-Timer
	if not is_charging_projectile:
		projectile_timer -= delta
		if projectile_timer <= 0:
			_start_projectile_charge()

func _start_projectile_charge():
	"""Startet Projektil-Telegraph"""
	is_charging_projectile = true
	var config = TYPE_CONFIG[Type.FIRE_DEVIL]

	# SFX
	Audio.play_sfx(config.sfx_charge)

	# Visual Telegraph (TODO: Add particle effect in later commit)
	sprite.modulate = Color(1.0, 1.0, 0.5)  # Yellow tint

	# Nach Telegraph-Zeit: Feuere Projektil
	await get_tree().create_timer(config.projectile_telegraph_time).timeout

	if is_alive:
		_fire_projectile()
		sprite.modulate = TYPE_CONFIG[enemy_type].color  # Reset color
		is_charging_projectile = false
		projectile_timer = TYPE_CONFIG[Type.FIRE_DEVIL].projectile_interval

func _fire_projectile():
	"""Spawnt Projektil Richtung Player"""
	var config = TYPE_CONFIG[Type.FIRE_DEVIL]

	# Finde Player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return

	var player = players[0] as Player

	# Prüfe Range
	var distance = global_position.distance_to(player.global_position)
	if distance > config.projectile_range:
		return  # Zu weit weg

	# Spawn Projectile
	var projectile = ProjectileScene.instantiate()
	projectile.global_position = global_position
	projectile.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(projectile)

	# SFX
	Audio.play_sfx(config.sfx_fire)

# ============================================================================
# DEATH
# ============================================================================

func die():
	"""Enemy stirbt"""
	if not is_alive:
		return

	is_alive = false

	# Score
	var score = score_value
	if Global.score_multiplier > 1.0:
		score = int(score * Global.score_multiplier)
	Global.add_score(score)

	# SFX
	var config = TYPE_CONFIG[enemy_type]
	var sfx_list = config.sfx_death
	Audio.play_sfx(sfx_list[randi() % sfx_list.size()])

	# Coin Drop
	if randf() < coin_drop_chance:
		spawn_coin()

	# TODO: Death Particles (Commit 59)

	# Cleanup
	queue_free()

# ============================================================================
# KNOCKBACK (IRON KNUCKLES ITEM)
# ============================================================================

func apply_knockback(direction: Vector2, force: float):
	"""Wendet Knockback an (von Iron Knuckles Item)"""
	velocity += direction * force

# ============================================================================
# COIN SPAWNING
# ============================================================================

func spawn_coin():
	"""Spawnt Coin an Enemy-Position"""
	if not CoinScene:
		return

	var coin = CoinScene.instantiate()
	coin.global_position = global_position
	coin.global_position.y -= 20  # Leicht über Enemy

	# Random horizontale Velocity
	coin.velocity.x = randf_range(-100, 100)
	coin.velocity.y = randf_range(-200, -100)

	get_parent().add_child(coin)

# ============================================================================
# DESPAWN (OFF-SCREEN)
# ============================================================================

func _on_visible_on_screen_notifier_2d_screen_exited():
	"""Despawnt Enemy wenn off-screen (rechts)"""
	if global_position.x > 1400:  # Rechts außerhalb
		queue_free()
