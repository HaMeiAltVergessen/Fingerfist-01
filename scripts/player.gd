# Player.gd - Spieler-Charakter mit Attack-System
extends CharacterBody2D
class_name Player

# ============================================================================
# CONSTANTS
# ============================================================================

const MAX_HP: int = 5
const BASE_ATTACK_COOLDOWN: float = 0.08
const INVULNERABILITY_DURATION: float = 0.1
const HITBOX_BASE_RADIUS: float = 32.0

# Animation Timing (140ms total, 8 frames @ 17.5ms each)
const ATTACK_ANIMATION_DURATION: float = 0.14
const HITBOX_ACTIVATE_FRAME: int = 3  # Frame 3-5 = Active
const HITBOX_DEACTIVATE_FRAME: int = 5

# ============================================================================
# STATS
# ============================================================================

var hp: int = MAX_HP
var max_hp: int = MAX_HP  # Kann sich durch Items ändern (Golem Skin)
var attack_cooldown: float = BASE_ATTACK_COOLDOWN
var combo_counter: int = 0
var is_attacking: bool = false
var is_invulnerable: bool = false
var attack_timer: float = 0.0

# ============================================================================
# ITEM MODIFIERS
# ============================================================================

# Shockwave Fist
var attack_radius_multiplier: float = 1.0

# Iron Knuckles
var has_knockback: bool = false

# Greed Magnet
var coin_magnet_radius: float = 0.0

# Golem Skin
var extra_lives: int = 0

# Time Crystal (handled in attack logic)
var time_crystal_active: bool = false

# Fire Shield (handled in projectile collision)
var fire_shield_charges: int = 0

# Thunder Charge (handled on hit)
var thunder_charge_active: bool = false

# Call of Wrath (handled on combo threshold)
var call_of_wrath_active: bool = false

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var sprite: Sprite2D = $PlayerSprite
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitboxShape
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/HurtboxShape
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# ============================================================================
# SIGNALS
# ============================================================================

signal hit_enemy(enemy: Enemy)
signal took_damage(remaining_hp: int)
signal died
signal combo_increased(combo: int)
signal combo_reset

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Position (rechts im Screen, zentriert vertikal)
	position = Vector2(1000, 360)

	# Setup Hitbox (deaktiviert am Start)
	hitbox.monitoring = false

	# Connect Signals
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	invulnerability_timer.timeout.connect(_on_invulnerability_timeout)

	# Apply Item Effects
	apply_item_effects()

	# Add to group
	add_to_group("player")

	print("[Player] Ready - HP: ", hp, "/", max_hp)

# ============================================================================
# PROCESS
# ============================================================================

func _process(delta: float):
	# Attack Cooldown Countdown
	if attack_timer > 0:
		attack_timer -= delta

	# Coin Magnet (wenn aktiv)
	if coin_magnet_radius > 0:
		_attract_nearby_coins()

# ============================================================================
# INPUT
# ============================================================================

func _input(event: InputEvent):
	# Touch/Click für Attack
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			attack(event.position)

# ============================================================================
# ATTACK SYSTEM
# ============================================================================

func attack(target_pos: Vector2):
	"""Führt einen Punch-Attack aus"""
	if attack_timer > 0 or is_attacking:
		return

	# Richtung berechnen
	var direction = (target_pos - global_position).normalized()
	sprite.rotation = direction.angle()

	# Attack State setzen
	is_attacking = true
	attack_timer = attack_cooldown

	# SFX (random aus 10 Variationen)
	var punch_num = randi() % 10 + 1
	Audio.play_sfx("punch_%02d.ogg" % punch_num, 0.1)

	# Animation abspielen
	animation_player.play("attack")

	# WICHTIG: Hitbox wird jetzt via Animation-Tracks aktiviert/deaktiviert
	# (activate_hitbox bei Frame 3, deactivate_hitbox bei Frame 5)

func activate_hitbox():
	"""Aktiviert die Hitbox (Gegner können getroffen werden)"""
	if not is_attacking:
		return

	hitbox.monitoring = true

	# Radius anpassen (Shockwave Fist Item)
	var shape = hitbox_shape.shape as CircleShape2D
	if shape:
		shape.radius = HITBOX_BASE_RADIUS * attack_radius_multiplier

func deactivate_hitbox():
	"""Deaktiviert die Hitbox"""
	hitbox.monitoring = false
	is_attacking = false

# ============================================================================
# DAMAGE SYSTEM
# ============================================================================

func take_damage(amount: int):
	"""Nimmt Schaden"""
	if is_invulnerable:
		return

	hp -= amount
	took_damage.emit(hp)

	# Combo Reset bei Schaden
	if combo_counter > 0:
		combo_counter = 0
		combo_reset.emit()

	# SFX
	var hurt_num = randi() % 3 + 1
	Audio.play_sfx("hurt_%02d.ogg" % hurt_num)

	# Invulnerability
	is_invulnerable = true
	sprite.modulate.a = 0.5
	invulnerability_timer.start(INVULNERABILITY_DURATION)

	# Screenshake
	if Global.screenshake_enabled:
		# TODO: Implement in Commit 12 (GameCamera)
		pass

	# Check Death
	if hp <= 0:
		die()

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

	died.emit()
	print("[Player] Died - Final Combo: ", combo_counter)

# ============================================================================
# COLLISION HANDLERS
# ============================================================================

func _on_hitbox_area_entered(area: Area2D):
	"""Hitbox trifft Gegner"""
	# Prüfe ob es ein Enemy ist
	var parent = area.get_parent()
	if not parent is Enemy:
		return

	var enemy = parent as Enemy

	# Knockback anwenden (Iron Knuckles Item)
	if has_knockback:
		var knockback_dir = (enemy.global_position - global_position).normalized()
		enemy.apply_knockback(knockback_dir, 200.0)  # 200px Knockback

	# Töte Gegner
	enemy.die()

	# Combo erhöhen
	combo_counter += 1
	combo_increased.emit(combo_counter)

	# Signal emittieren
	hit_enemy.emit(enemy)

	# Item-Trigger prüfen
	_check_item_triggers()

func _on_hurtbox_area_entered(area: Area2D):
	"""Hurtbox wird getroffen (Enemy oder Projektil)"""
	if is_invulnerable:
		return

	# Prüfe ob Fire Shield verfügbar ist
	if fire_shield_charges > 0:
		# Negiere Projektil-Schaden
		if area.get_parent().is_in_group("projectiles"):
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

# ============================================================================
# ITEM SYSTEM
# ============================================================================

func apply_item_effects():
	"""Wendet aktive Item-Effekte an"""
	# Reset zu Base Values
	attack_radius_multiplier = 1.0
	has_knockback = false
	coin_magnet_radius = 0.0
	extra_lives = 0
	time_crystal_active = false
	fire_shield_charges = 0
	thunder_charge_active = false
	call_of_wrath_active = false

	# Golem Skin zuerst (erhöht max_hp)
	if Global.is_item_active("golem_skin"):
		extra_lives = 3
		max_hp = MAX_HP + extra_lives
		hp = max_hp
	else:
		max_hp = MAX_HP
		hp = min(hp, max_hp)

	# Andere Items
	if Global.is_item_active("shockwave_fist"):
		attack_radius_multiplier = 2.0

	if Global.is_item_active("iron_knuckles"):
		has_knockback = true

	if Global.is_item_active("time_crystal"):
		time_crystal_active = true

	if Global.is_item_active("fire_shield"):
		fire_shield_charges = 1

	if Global.is_item_active("greed_magnet"):
		coin_magnet_radius = 200.0

	if Global.is_item_active("thunder_charge"):
		thunder_charge_active = true

	if Global.is_item_active("call_of_wrath"):
		call_of_wrath_active = true

	print("[Player] Items applied - Radius: x", attack_radius_multiplier,
	      ", HP: ", hp, "/", max_hp)

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

func _attract_nearby_coins():
	"""Zieht Coins zum Player (Greed Magnet)"""
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		var distance = coin.global_position.distance_to(global_position)
		if distance < coin_magnet_radius:
			# Ziehe Coin zum Player
			var direction = (global_position - coin.global_position).normalized()
			coin.velocity += direction * 500.0 * get_process_delta_time()
