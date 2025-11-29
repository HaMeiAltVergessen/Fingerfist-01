# Wall.gd - Destructible Wall System
extends Sprite2D
class_name Wall

# ============================================================================
# SIGNALS
# ============================================================================

signal hp_changed(current_hp: float, max_hp: float)
signal wall_damaged(damage: float)
signal wall_destroyed
signal state_changed(new_state: WallState)

# ============================================================================
# ENUMS
# ============================================================================

enum WallState {
	INTACT,    # >67% HP
	DAMAGED,   # 34-67% HP
	CRITICAL,  # <34% HP
}

# ============================================================================
# PROPERTIES
# ============================================================================

var max_hp: float = 1000.0
var current_hp: float = 1000.0
var current_state: WallState = WallState.INTACT

# Particle Effects
var flash_particles: CPUParticles2D
var impact_particles: CPUParticles2D
var destruction_particles: CPUParticles2D

# Crack Overlays
var crack_sprites: Array[Sprite2D] = []
var damage_zones: Array[Dictionary] = []

# Crack Display
const MAX_CRACKS: int = 5

# HP Regeneration (Golem's Blessing)
var regeneration_enabled: bool = false
var regeneration_rate: float = 1.0  # HP per second
var max_regeneration_percent: float = 0.1  # Max 10% of total HP can regenerate

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create Particle Systems
	create_particle_systems()

	# Create Crack Sprites
	create_crack_sprites()

	# Initialize Damage Zones
	initialize_damage_zones()

	print("[Wall] Ready - HP: %d/%d" % [current_hp, max_hp])

func _process(delta: float):
	"""Process HP Regeneration"""
	if regeneration_enabled:
		regenerate_hp(delta)

# ============================================================================
# PARTICLE SYSTEMS
# ============================================================================

func create_particle_systems():
	"""Erstellt Particle-Systeme für Effekte"""
	# Flash Particles (bei Schaden)
	flash_particles = CPUParticles2D.new()
	flash_particles.name = "FlashParticles"
	flash_particles.emitting = false
	flash_particles.one_shot = true
	flash_particles.explosiveness = 1.0
	flash_particles.amount = 8
	flash_particles.lifetime = 0.3
	flash_particles.direction = Vector2(1, 0)
	flash_particles.spread = 180
	flash_particles.initial_velocity_min = 50
	flash_particles.initial_velocity_max = 100
	flash_particles.scale_amount_min = 2.0
	flash_particles.scale_amount_max = 4.0
	flash_particles.color = Color(1.0, 0.9, 0.7)  # Yellowish flash
	add_child(flash_particles)

	# Impact Particles (bei jedem Treffer)
	impact_particles = CPUParticles2D.new()
	impact_particles.name = "ImpactParticles"
	impact_particles.emitting = false
	impact_particles.one_shot = true
	impact_particles.explosiveness = 0.8
	impact_particles.amount = 12
	impact_particles.lifetime = 0.5
	impact_particles.direction = Vector2(1, 0)
	impact_particles.spread = 60
	impact_particles.initial_velocity_min = 100
	impact_particles.initial_velocity_max = 200
	impact_particles.gravity = Vector2(0, 200)
	impact_particles.scale_amount_min = 1.0
	impact_particles.scale_amount_max = 2.0
	impact_particles.color = Color(0.7, 0.7, 0.7)  # Gray debris
	add_child(impact_particles)

	# Destruction Particles (bei Zerstörung)
	destruction_particles = CPUParticles2D.new()
	destruction_particles.name = "DestructionParticles"
	destruction_particles.emitting = false
	destruction_particles.one_shot = true
	destruction_particles.explosiveness = 1.0
	destruction_particles.amount = 50
	destruction_particles.lifetime = 1.5
	destruction_particles.direction = Vector2(1, 0)
	destruction_particles.spread = 180
	destruction_particles.initial_velocity_min = 200
	destruction_particles.initial_velocity_max = 400
	destruction_particles.gravity = Vector2(0, 300)
	destruction_particles.scale_amount_min = 2.0
	destruction_particles.scale_amount_max = 6.0
	destruction_particles.color = Color(0.8, 0.8, 0.7)  # Light gray
	add_child(destruction_particles)

	print("[Wall] Particle systems created")

# ============================================================================
# CRACK TEXTURES
# ============================================================================

func create_crack_sprites():
	"""Erstellt Crack-Sprite-Overlays"""
	for i in range(MAX_CRACKS):
		var crack = Sprite2D.new()
		crack.name = "Crack%d" % i
		crack.visible = false
		crack.modulate = Color(0.3, 0.2, 0.2, 0.8)  # Dark cracks

		# Position cracks randomly on wall
		crack.position = Vector2(
			randf_range(-20, 20),
			randf_range(-40, 40)
		)

		# Random rotation
		crack.rotation = randf_range(0, TAU)

		# Random scale
		crack.scale = Vector2.ONE * randf_range(0.5, 1.5)

		add_child(crack)
		crack_sprites.append(crack)

	print("[Wall] Created %d crack sprites" % MAX_CRACKS)

func initialize_damage_zones():
	"""Initialisiert Schaden-Zonen auf der Wall"""
	# 3 Damage Zones: Top, Middle, Bottom
	damage_zones = [
		{
			"name": "Top",
			"area": Rect2(Vector2(-30, -50), Vector2(60, 30)),
			"damage_taken": 0.0,
		},
		{
			"name": "Middle",
			"area": Rect2(Vector2(-30, -20), Vector2(60, 40)),
			"damage_taken": 0.0,
		},
		{
			"name": "Bottom",
			"area": Rect2(Vector2(-30, 20), Vector2(60, 30)),
			"damage_taken": 0.0,
		},
	]

	print("[Wall] Initialized %d damage zones" % damage_zones.size())

func update_crack_display():
	"""Updated Crack-Display basierend auf HP"""
	var hp_percent = get_hp_percent()

	# Show cracks based on damage
	var cracks_to_show = 0
	if hp_percent < 67:
		cracks_to_show = 2  # Damaged state
	if hp_percent < 50:
		cracks_to_show = 3
	if hp_percent < 34:
		cracks_to_show = 5  # Critical state

	# Update visibility
	for i in range(MAX_CRACKS):
		crack_sprites[i].visible = (i < cracks_to_show)

# ============================================================================
# HP MANAGEMENT
# ============================================================================

func setup(level: int):
	"""Setup Wall für Level"""
	if not Global.WALL_HP_PER_LEVEL.has(level):
		push_error("Invalid level: " + str(level))
		return

	max_hp = Global.WALL_HP_PER_LEVEL[level]
	current_hp = Global.get_wall_remaining_hp(level)

	update_visual_state()

	print("[Wall] Setup Level %d - HP: %d/%d" % [level, current_hp, max_hp])

func take_damage(amount: float):
	"""Nimmt Schaden"""
	if current_hp <= 0:
		return

	current_hp -= amount
	current_hp = max(0, current_hp)

	# Emit Signals
	hp_changed.emit(current_hp, max_hp)
	wall_damaged.emit(amount)

	# Update Visual State
	update_visual_state()

	# Particle Effects
	spawn_flash_particles()
	spawn_impact_particles()

	print("[Wall] Took %d damage - HP: %d/%d" % [amount, current_hp, max_hp])

	# Check Destruction
	if current_hp <= 0:
		destroy()

func update_visual_state():
	"""Updated visuellen Zustand basierend auf HP"""
	var hp_percent = (current_hp / max_hp) * 100.0
	var old_state = current_state

	# Determine State
	if hp_percent > 67:
		current_state = WallState.INTACT
		modulate = Color(1.0, 1.0, 1.0)  # Normal
	elif hp_percent > 34:
		current_state = WallState.DAMAGED
		modulate = Color(0.9, 0.8, 0.7)  # Yellowish
	else:
		current_state = WallState.CRITICAL
		modulate = Color(0.8, 0.6, 0.5)  # Reddish

	# Update Crack Display
	update_crack_display()

	# Emit Signal if state changed
	if old_state != current_state:
		state_changed.emit(current_state)
		print("[Wall] State changed: %s → %s" % [WallState.keys()[old_state], WallState.keys()[current_state]])

func destroy():
	"""Zerstört die Wand"""
	if not visible:
		return

	print("[Wall] DESTROYED!")

	# Particle Effect
	spawn_destruction_particles()

	# Hide Wall
	visible = false

	# Emit Signal
	wall_destroyed.emit()

# ============================================================================
# PARTICLE EFFECTS
# ============================================================================

func spawn_flash_particles():
	"""Spawnt Flash-Partikel bei Schaden"""
	if flash_particles:
		flash_particles.emitting = true

func spawn_impact_particles():
	"""Spawnt Impact-Partikel bei Treffer"""
	if impact_particles:
		impact_particles.emitting = true

func spawn_destruction_particles():
	"""Spawnt Destruction-Partikel bei Zerstörung"""
	if destruction_particles:
		destruction_particles.emitting = true

# ============================================================================
# GETTERS
# ============================================================================

func get_hp_percent() -> float:
	"""Gibt HP-Prozent zurück"""
	return (current_hp / max_hp) * 100.0

func is_destroyed() -> bool:
	"""Prüft ob Wand zerstört ist"""
	return current_hp <= 0

# ============================================================================
# HP REGENERATION
# ============================================================================

func regenerate_hp(delta: float):
	"""Regeneriert HP basierend auf Golem's Blessing"""
	if current_hp >= max_hp:
		return  # Already at max HP

	# Calculate max HP we can regenerate to (10% of total)
	var max_regen_hp = max_hp * max_regeneration_percent

	# Don't regenerate if we're above the threshold
	if current_hp >= (max_hp - max_regen_hp):
		return

	# Regenerate
	var regen_amount = regeneration_rate * delta
	current_hp += regen_amount
	current_hp = min(current_hp, max_hp)

	# Emit Signal
	hp_changed.emit(current_hp, max_hp)

	# Update Visual State (reduces cracks as HP increases)
	update_visual_state()

func enable_regeneration():
	"""Aktiviert HP-Regeneration (Golem's Blessing)"""
	regeneration_enabled = true
	print("[Wall] HP Regeneration ENABLED (1 HP/s, max 10%%)")

func disable_regeneration():
	"""Deaktiviert HP-Regeneration"""
	regeneration_enabled = false
	print("[Wall] HP Regeneration DISABLED")
