# Wall.gd - Wand-System mit HP-Tracking
extends Node2D
class_name Wall

# ============================================================================
# SIGNALS
# ============================================================================

signal hp_changed(current_hp: float, max_hp: float)
signal state_changed(new_state: WallState)
signal destroyed()

# ============================================================================
# WALL STATES
# ============================================================================

enum WallState {
	INTACT,    # >67% HP
	DAMAGED,   # 34-67% HP
	CRITICAL,  # <34% HP
}

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var sprite: Sprite2D = $WallSprite
@onready var hp_bar: ProgressBar = $HPBar
@onready var crack_particles: CPUParticles2D = $CrackParticles

# ============================================================================
# STATE
# ============================================================================

var max_hp: float = 1000.0
var current_hp: float = 1000.0
var current_state: WallState = WallState.INTACT
var level: int = 1

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Setup basierend auf Global.selected_level
	level = Global.selected_level

	# Max HP aus Global
	max_hp = Global.WALL_HP_PER_LEVEL.get(level, 1000.0)

	# Current HP (kann reduziert sein durch vorherige Runs)
	current_hp = Global.get_wall_remaining_hp(level)

	# Setup HP Bar
	setup_hp_bar()

	# Initiale State
	update_visual_state()

	print("[Wall] Initialized - Level: ", level, " HP: ", current_hp, "/", max_hp)

# ============================================================================
# HP MANAGEMENT
# ============================================================================

func take_damage(amount: float):
	"""Wand nimmt Schaden (Score erhöht sich)"""
	if current_hp <= 0:
		return

	# Reduziere HP
	var old_hp = current_hp
	current_hp = max(0, current_hp - amount)

	# Update Global
	Global.set_wall_hp(level, current_hp)

	# Emit Signal
	hp_changed.emit(current_hp, max_hp)

	# Update Visuals
	update_visual_state()
	update_hp_bar()

	# Check Destruction
	if current_hp <= 0:
		destroy_wall()

	print("[Wall] Damage: -", amount, " HP: ", current_hp, "/", max_hp, " (", get_hp_percent(), "%)")

func heal(amount: float):
	"""Heilt Wand (für Items/Powerups)"""
	var old_hp = current_hp
	current_hp = min(max_hp, current_hp + amount)

	# Update Global
	Global.set_wall_hp(level, current_hp)

	hp_changed.emit(current_hp, max_hp)
	update_visual_state()
	update_hp_bar()

	print("[Wall] Healed: +", amount, " HP: ", current_hp, "/", max_hp)

func get_hp_percent() -> float:
	"""Gibt HP in Prozent zurück"""
	return (current_hp / max_hp) * 100.0

# ============================================================================
# VISUAL STATES
# ============================================================================

func update_visual_state():
	"""Updated Sprite basierend auf HP-Prozent"""
	var hp_percent = get_hp_percent()

	# Determine State
	var new_state: WallState
	if hp_percent > 67:
		new_state = WallState.INTACT
	elif hp_percent > 34:
		new_state = WallState.DAMAGED
	else:
		new_state = WallState.CRITICAL

	# State Changed?
	if new_state != current_state:
		var old_state = current_state
		current_state = new_state
		state_changed.emit(new_state)

		# Visual Update
		apply_state_visuals()

		# SFX
		play_state_sfx(new_state)

		print("[Wall] State changed: ", WallState.keys()[old_state], " → ", WallState.keys()[new_state])

func apply_state_visuals():
	"""Wendet State-spezifische Visuals an"""
	match current_state:
		WallState.INTACT:
			sprite.modulate = Color(1.0, 1.0, 1.0)  # Normal
			if crack_particles:
				crack_particles.emitting = false

		WallState.DAMAGED:
			sprite.modulate = Color(0.9, 0.8, 0.7)  # Leicht gelblich
			if crack_particles:
				crack_particles.emitting = true
				crack_particles.amount = 5

		WallState.CRITICAL:
			sprite.modulate = Color(0.8, 0.6, 0.5)  # Rötlich
			if crack_particles:
				crack_particles.emitting = true
				crack_particles.amount = 15

func play_state_sfx(state: WallState):
	"""Spielt State-Change SFX"""
	match state:
		WallState.DAMAGED:
			# Audio.play_sfx("wall_crack_01.ogg")
			pass
		WallState.CRITICAL:
			# Audio.play_sfx("wall_crack_02.ogg")
			pass

# ============================================================================
# HP BAR
# ============================================================================

func setup_hp_bar():
	"""Initialisiert HP-Bar"""
	if not hp_bar:
		return

	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

	# Style
	hp_bar.show_percentage = false

func update_hp_bar():
	"""Updated HP-Bar Value"""
	if not hp_bar:
		return

	hp_bar.value = current_hp

	# Color basierend auf HP%
	var hp_percent = get_hp_percent()
	if hp_percent > 67:
		hp_bar.modulate = Color(0.3, 0.8, 0.3)  # Green
	elif hp_percent > 34:
		hp_bar.modulate = Color(0.9, 0.7, 0.2)  # Yellow
	else:
		hp_bar.modulate = Color(0.9, 0.3, 0.2)  # Red

# ============================================================================
# DESTRUCTION
# ============================================================================

func destroy_wall():
	"""Wand wird zerstört"""
	print("[Wall] DESTROYED!")

	# Emit Signal
	destroyed.emit()

	# SFX + Screenshake
	# Audio.play_sfx("wall_break.ogg")
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake_wall_destroyed"):
		camera.shake_wall_destroyed()

	# Particles (später)
	# spawn_destruction_particles()

	# Hide Wall
	visible = false

	# Reset HP (für Endless Mode Restart)
	Global.set_wall_hp(level, max_hp)

# ============================================================================
# UTILITY
# ============================================================================

func reset_hp():
	"""Setzt HP zurück auf Max (für Restarts)"""
	current_hp = max_hp
	Global.set_wall_hp(level, max_hp)
	update_visual_state()
	update_hp_bar()
	visible = true
	print("[Wall] HP Reset")
