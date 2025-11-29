# Coin.gd - Collectible Coin mit Physik
extends Area2D
class_name Coin

# ============================================================================
# COIN TYPES
# ============================================================================

enum CoinType {
	BRONZE,   # 1 Coin
	SILVER,   # 5 Coins
	GOLD,     # 10 Coins
	PLATINUM, # 25 Coins
}

# Coin-Konfiguration pro Type
const COIN_CONFIG = {
	CoinType.BRONZE: {
		"value": 1,
		"color": Color(0.8, 0.5, 0.2),  # Bronze
		"drop_chance": 70,  # 70% von allen Coin-Drops
	},
	CoinType.SILVER: {
		"value": 5,
		"color": Color(0.75, 0.75, 0.75),  # Silber
		"drop_chance": 20,  # 20%
	},
	CoinType.GOLD: {
		"value": 10,
		"color": Color(1.0, 0.84, 0.0),  # Gold
		"drop_chance": 8,  # 8%
	},
	CoinType.PLATINUM: {
		"value": 25,
		"color": Color(0.9, 0.95, 1.0),  # Platin
		"drop_chance": 2,  # 2%
	},
}

# ============================================================================
# PROPERTIES
# ============================================================================

@export var coin_type: CoinType = CoinType.BRONZE

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var sprite: Sprite2D = $CoinSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var magnet_area: Area2D = $MagnetArea

# ============================================================================
# STATE
# ============================================================================

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 600.0  # Pixel/s²
var bounce_damping: float = 0.6
var ground_y: float = 650.0  # Boden-Höhe
var friction: float = 0.95

var is_on_ground: bool = false
var is_collected: bool = false
var is_magnetized: bool = false

var coin_value: int = 1

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Add to group
	add_to_group("coins")

	# Setup basierend auf Type
	var config = COIN_CONFIG[coin_type]
	coin_value = config.value

	# Sprite-Color
	sprite.modulate = config.color

	# Collision Layers
	collision_layer = 4  # Layer 3 (Coin)
	collision_mask = 1   # Mask 1 (Player)

	# Connect Signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Lifetime (10 Sekunden)
	lifetime_timer.wait_time = 10.0
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()

	print("[Coin] Spawned: ", CoinType.keys()[coin_type], " Value: ", coin_value)

# ============================================================================
# PROCESS
# ============================================================================

func _process(delta: float):
	if is_collected:
		return

	# Prüfe Magnet (Greed Magnet Item)
	check_magnet_pull()

	if is_magnetized:
		# Bewege zu Player
		move_to_player(delta)
	else:
		# Physik-Simulation
		apply_physics(delta)

# ============================================================================
# PHYSICS
# ============================================================================

func apply_physics(delta: float):
	"""Simuliert Schwerkraft, Bounce und Friction"""
	if not is_on_ground:
		# Gravity
		velocity.y += gravity * delta

		# Move
		position += velocity * delta

		# Ground Collision
		if position.y >= ground_y:
			position.y = ground_y
			is_on_ground = true

			# Bounce
			if abs(velocity.y) > 50:
				velocity.y = -velocity.y * bounce_damping
				# SFX
				# Audio.play_sfx("coin_bounce.ogg")
			else:
				velocity.y = 0
	else:
		# Friction (auf Boden)
		velocity.x *= friction

		if abs(velocity.x) < 5:
			velocity.x = 0

# ============================================================================
# MAGNET SYSTEM
# ============================================================================

func check_magnet_pull():
	"""Prüft ob Player mit Greed Magnet in Range ist"""
	if is_magnetized:
		return

	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		return

	# Prüfe Greed Magnet Radius
	var magnet_radius = player.coin_magnet_radius
	if magnet_radius <= 0:
		return

	var distance = global_position.distance_to(player.global_position)
	if distance < magnet_radius:
		is_magnetized = true
		print("[Coin] Magnetized!")

func set_magnetized(enabled: bool, player_pos: Vector2 = Vector2.ZERO):
	"""Setzt Magnetized-Status (für externe Magnet-Trigger)"""
	is_magnetized = enabled

func move_to_player(delta: float):
	"""Bewegt Coin zu Player (Magnet)"""
	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		is_magnetized = false
		return

	# Richtung zu Player
	var direction = (player.global_position - global_position).normalized()

	# Speed abhängig von Distanz (schneller wenn näher)
	var distance = global_position.distance_to(player.global_position)
	var speed = lerp(400.0, 800.0, 1.0 - (distance / 200.0))

	# Move
	position += direction * speed * delta

	# Rotation für visuelles Feedback
	rotation += delta * 10.0

# ============================================================================
# COLLECTION
# ============================================================================

func collect():
	"""Sammelt Coin ein"""
	if is_collected:
		return

	is_collected = true

	# Add Coins zu Global
	Global.add_coins(coin_value)

	# SFX
	# Audio.play_sfx("coin_collect_01.ogg")  # Später

	# Visual Feedback (Tween)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.finished.connect(queue_free)

	print("[Coin] Collected: +", coin_value, " Coins")

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_body_entered(body: Node2D):
	"""Collision mit Player-Body"""
	if body is Player:
		collect()

func _on_area_entered(area: Area2D):
	"""Collision mit Player-Hurtbox (zusätzliche Collection-Area)"""
	if area.get_parent() is Player:
		collect()

func _on_lifetime_timeout():
	"""Coin verschwindet nach Lifetime"""
	if not is_collected:
		# Fade out
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		tween.finished.connect(queue_free)

		print("[Coin] Lifetime expired")

# ============================================================================
# UTILITY
# ============================================================================

static func get_random_coin_type() -> CoinType:
	"""Wählt zufälligen Coin-Type basierend auf Drop-Chancen

	Bronze: 70%
	Silver: 20%
	Gold: 8%
	Platinum: 2%
	"""
	var rand_value = randf() * 100.0
	var cumulative = 0.0

	for type in COIN_CONFIG:
		cumulative += COIN_CONFIG[type].drop_chance
		if rand_value < cumulative:
			return type

	return CoinType.BRONZE
