# projectile.gd - Feuerteufel-Projektil
# Fliegt geradlinig in 'direction' (kein Tracking). Der Schaden am Player wird
# über dessen Hurtbox (_on_hurtbox_area_entered) abgewickelt; dieses Skript
# kümmert sich nur um Bewegung, Ausrichtung und Despawn nach Reichweite.
extends Area2D

# Wird vom Enemy beim Spawn gesetzt (enemy.gd:_fire_projectile)
var direction: Vector2 = Vector2.RIGHT

# CLAUDE.md §4 nennt "7 px/ms"; hier als gut sichtbarer, schneller Bolt getunt.
# Der Player kann sich ohnehin nicht bewegen (nur Fire Shield negiert), daher ist
# die Geschwindigkeit primär für Lesbarkeit gewählt und leicht anpassbar.
const SPEED: float = 700.0       # px/s
const MAX_RANGE: float = 700.0   # px, danach Despawn (CLAUDE.md §4)

var _traveled: float = 0.0

func _ready() -> void:
	add_to_group("projectiles")

	# Layer 3 = Projectile -> die Player-Hurtbox (collision_mask = 6) erkennt uns.
	collision_layer = 4   # Bit für Layer 3
	collision_mask = 0    # wir detektieren selbst nichts; die Hurtbox überwacht uns
	monitorable = true
	monitoring = false

	# Sprite in Flugrichtung ausrichten
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	var step: float = SPEED * delta
	global_position += direction * step
	_traveled += step

	if _traveled >= MAX_RANGE:
		queue_free()
