# player.gd - Static Punching System
extends Node2D
class_name Player

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var sprite: Sprite2D = $PlayerSprite
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var punch_hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $Hitbox/HitboxShape
@onready var hurtbox: Area2D = $Hurtbox
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer

# ============================================================================
# STATS
# ============================================================================

var hp: int = 5
var max_hp: int = 5
var is_invulnerable: bool = false
var invulnerability_duration: float = 1.0

# ============================================================================
# PUNCH STATE
# ============================================================================

var is_punching: bool = false

# ============================================================================
# COMBO
# ============================================================================

var combo_counter: int = 0
var highest_combo: int = 0
const COMBO_SMALL_RAIN: int = 10
const COMBO_MEDIUM_RAIN: int = 20
const COMBO_BIG_RAIN: int = 30
var last_rain_combo: int = 0

# ============================================================================
# ITEMS
# ============================================================================

var attack_radius_multiplier: float = 1.0  # Shockwave Fist
var has_knockback: bool = false            # Iron Knuckles
var coin_magnet_radius: float = 0.0        # Greed Magnet
var extra_lives: int = 0                   # Golem Skin
var time_crystal_active: bool = false      # Time Crystal
var fire_shield_charges: int = 0           # Fire Shield
var thunder_charge_active: bool = false    # Thunder Charge
var thunder_hit_counter: int = 0
var call_of_wrath_active: bool = false     # Call of Wrath

# ============================================================================
# SIGNALS
# ============================================================================

signal hit_enemy(enemy: Enemy)
signal took_damage(current_hp: int)
signal died
signal combo_increased(combo: int)
signal combo_reset

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	add_to_group("player")

	# STATIC POSITION - NO MOVEMENT!
	position = Vector2(100, 360)  # Fixed position on left side of screen

	# Hitbox initial deaktiviert
	punch_hitbox.monitoring = false
	punch_hitbox.monitorable = false

	# Connect Hitbox Signal
	punch_hitbox.area_entered.connect(_on_hitbox_area_entered)

	# Connect Hurtbox Signal
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	# Connect Invulnerability Timer
	invulnerability_timer.timeout.connect(_on_invulnerability_timeout)

	# Apply Items
	apply_item_effects()

	print("[Player] Static position: %s - HP: %d, NO MOVEMENT" % [position, hp])

# ============================================================================
# INPUT - NUR PUNCH
# ============================================================================

func _input(event: InputEvent):
	"""Nur Punch-Input (Click/Tap)"""
	# Mouse Click
	if event is InputEventMouseButton and event.pressed:
		perform_punch()

	# Touch (Mobile)
	if event is InputEventScreenTouch and event.pressed:
		perform_punch()

# ============================================================================
# PUNCH SYSTEM
# ============================================================================

func perform_punch():
	"""Führt Punch aus"""
	if is_punching:
		return  # Animation läuft noch

	is_punching = true

	# Play Animation
	if anim:
		anim.play("attack")

	# SFX
	var punch_num = randi() % 10 + 1
	Audio.play_sfx("punch_%02d.ogg" % punch_num, 0.1)

	# Hitbox-Fenster aktivieren (Frame 3-5)
	# Note: activate_hitbox() wird via AnimationPlayer aufgerufen

	print("[Player] PUNCH!")

func activate_hitbox():
	"""Aktiviert Hitbox für Frame 3-5 (~40ms) - Called by AnimationPlayer"""
	# Hitbox aktivieren
	punch_hitbox.monitoring = true
	punch_hitbox.monitorable = true

	# Apply Shockwave Fist (radius multiplier)
	var base_radius = 32.0
	var radius = base_radius * attack_radius_multiplier

	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius

func deactivate_hitbox():
	"""Deaktiviert Hitbox - Called by AnimationPlayer"""
	# Hitbox deaktivieren
	punch_hitbox.monitoring = false
	punch_hitbox.monitorable = false

	is_punching = false

func _on_hitbox_area_entered(area: Area2D):
	"""Hitbox trifft Enemy"""
	# Prüfe ob Enemy (via parent check)
	var parent = area.get_parent()
	if not parent is Enemy:
		return

	var enemy = parent as Enemy

	# Emit Signal
	hit_enemy.emit(enemy)

	# Combo
	combo_counter += 1
	highest_combo = max(highest_combo, combo_counter)
	combo_increased.emit(combo_counter)
	check_combo_rewards()

	# Thunder Charge (every 10th hit)
	if thunder_charge_active:
		thunder_hit_counter += 1
		if thunder_hit_counter >= 10:
			thunder_hit_counter = 0
			# TODO: 3× damage effect (visual only, enemy dies anyway)
			print("[Player] THUNDER CHARGE! ⚡")

	# Apply Knockback (Iron Knuckles Item)
	if has_knockback:
		var knockback_dir = global_position.direction_to(enemy.global_position)
		enemy.apply_knockback(knockback_dir, 300.0)

	# Kill Enemy (ONE-HIT-KO!)
	enemy.die()

	print("[Player] Enemy hit! Combo: %d" % combo_counter)

# ============================================================================
# COMBO REWARDS
# ============================================================================

func check_combo_rewards():
	"""Prüft Combo-Thresholds für Coin Rain"""
	# Big Rain (30+)
	if combo_counter >= COMBO_BIG_RAIN and last_rain_combo < COMBO_BIG_RAIN:
		trigger_coin_rain(20)
		last_rain_combo = COMBO_BIG_RAIN
		print("[Player] BIG COMBO RAIN! (30+)")

	# Medium Rain (20+)
	elif combo_counter >= COMBO_MEDIUM_RAIN and last_rain_combo < COMBO_MEDIUM_RAIN:
		trigger_coin_rain(10)
		last_rain_combo = COMBO_MEDIUM_RAIN
		print("[Player] Medium Combo Rain (20+)")

	# Small Rain (10+)
	elif combo_counter >= COMBO_SMALL_RAIN and last_rain_combo < COMBO_SMALL_RAIN:
		trigger_coin_rain(5)
		last_rain_combo = COMBO_SMALL_RAIN
		print("[Player] Small Combo Rain (10+)")

func trigger_coin_rain(count: int):
	"""Triggert Coin-Rain via CoinSpawner"""
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		return

	var coin_spawner = game.get_node_or_null("Spawners/CoinSpawner")
	if not coin_spawner:
		return

	if coin_spawner.has_method("spawn_coin_rain"):
		coin_spawner.spawn_coin_rain(count)

	# Screenshake
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake_explosion"):
		camera.shake_explosion()

# ============================================================================
# DAMAGE SYSTEM
# ============================================================================

func take_damage(amount: int):
	"""Nimmt Schaden"""
	if is_invulnerable:
		return

	# Fire Shield
	if fire_shield_charges > 0:
		fire_shield_charges -= 1
		Audio.play_sfx("fire_shield.ogg")
		print("[Player] Fire Shield absorbed hit! Charges: %d" % fire_shield_charges)
		return

	# Apply Damage
	hp -= amount
	hp = max(0, hp)
	took_damage.emit(hp)

	# Reset Combo
	if combo_counter > 0:
		combo_reset.emit()
		combo_counter = 0
		last_rain_combo = 0

	# SFX
	var hurt_num = randi() % 3 + 1
	Audio.play_sfx("hurt_%02d.ogg" % hurt_num)

	print("[Player] Took %d damage - HP: %d/%d" % [amount, hp, max_hp])

	# Invulnerability
	if hp > 0:
		is_invulnerable = true
		sprite.modulate.a = 0.5
		invulnerability_timer.start(invulnerability_duration)

	# Death
	if hp <= 0:
		die()

func _on_hurtbox_area_entered(area: Area2D):
	"""Hurtbox wird getroffen (Enemy oder Projektil)"""
	if is_invulnerable:
		return

	# Prüfe ob Fire Shield verfügbar ist
	if fire_shield_charges > 0:
		# Negiere Projektil-Schaden
		if area.get_parent() and area.get_parent().is_in_group("projectiles"):
			fire_shield_charges -= 1
			Audio.play_sfx("fire_shield.ogg")
			# TODO: Spawn Fire Explosion Particles (Commit 59)
			area.get_parent().queue_free()
			return

	# Normaler Schaden
	take_damage(1)

func _on_invulnerability_timeout():
	"""Invulnerability endet"""
	is_invulnerable = false
	sprite.modulate.a = 1.0

func die():
	"""Player stirbt"""
	set_process_input(false)
	set_process(false)

	# SFX
	Audio.play_sfx("death.ogg")

	# Save highest combo
	if combo_counter > 0:
		Global.highest_combos.append(combo_counter)
		Global.highest_combos.sort()
		Global.highest_combos.reverse()
		if Global.highest_combos.size() > 3:
			Global.highest_combos.resize(3)

	print("[Player] DIED")
	died.emit()

# ============================================================================
# ITEMS
# ============================================================================

func apply_item_effects():
	"""Wendet alle Items an"""
	# Reset
	attack_radius_multiplier = 1.0
	has_knockback = false
	coin_magnet_radius = 0.0
	extra_lives = 0
	time_crystal_active = false
	fire_shield_charges = 0
	thunder_charge_active = false
	thunder_hit_counter = 0
	call_of_wrath_active = false

	# Golem Skin zuerst (erhöht max_hp)
	if Global.is_item_active("golem_skin"):
		extra_lives = 3
		max_hp = 5 + extra_lives
		hp = max_hp
	else:
		max_hp = 5
		hp = min(hp, max_hp)

	# Apply Items
	if Global.is_item_active("shockwave_fist"):
		attack_radius_multiplier = 2.0

	if Global.is_item_active("iron_knuckles"):
		has_knockback = true

	if Global.is_item_active("greed_magnet"):
		coin_magnet_radius = 200.0

	if Global.is_item_active("time_crystal"):
		time_crystal_active = true

	if Global.is_item_active("fire_shield"):
		fire_shield_charges = 1

	if Global.is_item_active("thunder_charge"):
		thunder_charge_active = true

	if Global.is_item_active("call_of_wrath"):
		call_of_wrath_active = true

	print("[Player] Items applied - Radius: %.1f×" % attack_radius_multiplier)

# ============================================================================
# COIN MAGNET
# ============================================================================

func _process(delta: float):
	"""Update Coin Magnet"""
	Global.total_playtime += delta

	if coin_magnet_radius > 0:
		_attract_nearby_coins()

	# Check Item Triggers
	_check_item_triggers()

func _attract_nearby_coins():
	"""Zieht Coins an (Greed Magnet)"""
	var coins = get_tree().get_nodes_in_group("coins")
	for coin_node in coins:
		if not coin_node.has_method("set_magnetized"):
			continue

		var distance = global_position.distance_to(coin_node.global_position)
		if distance < coin_magnet_radius:
			coin_node.set_magnetized(true, global_position)

func get_nearby_coins() -> Array[Coin]:
	"""Gibt alle Coins in Magnet-Radius zurück"""
	if coin_magnet_radius <= 0:
		return []

	var coins: Array[Coin] = []
	var all_coins = get_tree().get_nodes_in_group("coins")

	for coin_node in all_coins:
		var coin = coin_node as Coin
		if coin and not coin.is_collected:
			var distance = global_position.distance_to(coin.global_position)
			if distance < coin_magnet_radius:
				coins.append(coin)

	return coins

func _check_item_triggers():
	"""Prüft ob Item-Trigger aktiviert werden sollen"""
	# Time Crystal: Slow Motion bei 10er Combo
	if time_crystal_active and combo_counter == 10:
		trigger_slow_motion()

	# Thunder Charge: Chain Lightning bei 20er Combo
	if thunder_charge_active and combo_counter >= 20:
		trigger_chain_lightning()

	# Call of Wrath: Meteoriten + x2 bei 30+ Combo
	if call_of_wrath_active and combo_counter >= 30:
		trigger_meteor_rain()

func trigger_slow_motion():
	"""Aktiviert Slow-Motion für 2 Sekunden"""
	Engine.time_scale = 0.7
	Audio.play_sfx("slow_motion.ogg")

	# Reset nach 2s (real time, nicht game time)
	var timer = get_tree().create_timer(2.0 / 0.7, true, false, true)
	await timer.timeout
	Engine.time_scale = 1.0

func trigger_chain_lightning():
	"""Spawnt Chain Lightning Effekt"""
	Audio.play_sfx("thunder_chain.ogg")

	# Screenshake
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake_explosion"):
		camera.shake_explosion()

	# TODO: Implement Lightning Visual (Commit 60)

	# Schade allen Enemies in Range
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) < 300:
			enemy.die()

func trigger_meteor_rain():
	"""Spawnt Meteoriten-Regen"""
	Global.score_multiplier = 2.0
	Audio.play_sfx("meteor_rain.ogg")

	# Screenshake
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake_explosion"):
		camera.shake_explosion()

	# TODO: Implement Meteor Visual (Commit 60)

# ============================================================================
# RESET
# ============================================================================

func reset_state():
	"""Setzt Player zurück"""
	hp = max_hp
	combo_counter = 0
	last_rain_combo = 0
	is_invulnerable = false
	is_punching = false

	apply_item_effects()

	print("[Player] State reset")
