# GameCamera.gd - Camera mit Screenshake-System
extends Camera2D
class_name GameCamera

# ============================================================================
# SCREENSHAKE PARAMETERS
# ============================================================================

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_frequency: float = 30.0  # Hz
var shake_timer: float = 0.0

var original_offset: Vector2 = Vector2.ZERO

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Set as current camera
	enabled = true

	# Center in viewport (1280×720)
	position = Vector2(640, 360)

	# Save original offset
	original_offset = offset

	print("[GameCamera] Ready")

# ============================================================================
# PROCESS
# ============================================================================

func _process(delta: float):
	if shake_timer > 0:
		# Active Shake
		shake_timer -= delta

		# Random offset based on intensity
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)

		offset = original_offset + shake_offset

		# Check if shake finished
		if shake_timer <= 0:
			offset = original_offset
			shake_intensity = 0.0
	elif offset != original_offset:
		# Smooth return to original position
		offset = offset.lerp(original_offset, delta * 10.0)
		if offset.distance_to(original_offset) < 0.1:
			offset = original_offset

# ============================================================================
# SCREENSHAKE API
# ============================================================================

func apply_shake(intensity: float, duration: float, frequency: float = 30.0):
	"""Wendet Screenshake an

	Args:
		intensity: Shake-Stärke in Pixeln (0-10)
		duration: Shake-Dauer in Sekunden (0.05-1.0)
		frequency: Shake-Frequenz in Hz (default 30)
	"""
	if not Global.screenshake_enabled:
		return

	# Addiere zu existierendem Shake (nicht ersetzen)
	shake_intensity = max(shake_intensity, intensity)
	shake_duration = max(shake_duration, duration)
	shake_frequency = frequency
	shake_timer = shake_duration

# ============================================================================
# PRESET SHAKES
# ============================================================================

func shake_light_hit():
	"""Leichter Hit (Insekt getroffen)"""
	apply_shake(1.0, 0.08, 30.0)

func shake_normal_hit():
	"""Normaler Hit (Vase getroffen)"""
	apply_shake(2.0, 0.1, 30.0)

func shake_heavy_hit():
	"""Schwerer Hit (Fire Devil getroffen)"""
	apply_shake(3.0, 0.15, 35.0)

func shake_player_hurt():
	"""Player nimmt Schaden"""
	apply_shake(4.0, 0.15, 40.0)

func shake_wall_destroyed():
	"""Wand zerstört"""
	apply_shake(8.0, 0.4, 25.0)

func shake_explosion():
	"""Explosion (Items, Meteor)"""
	apply_shake(5.0, 0.25, 30.0)

# ============================================================================
# UTILITY
# ============================================================================

func is_shaking() -> bool:
	"""Prüft ob gerade Shake aktiv ist"""
	return shake_timer > 0

func stop_shake():
	"""Stoppt Shake sofort"""
	shake_timer = 0.0
	shake_intensity = 0.0
	offset = original_offset
