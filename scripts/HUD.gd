# HUD.gd - Heads-Up Display
extends CanvasLayer

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var score_label: Label = $TopBar/ScoreLabel
@onready var coins_label: Label = $TopBar/CoinsLabel
@onready var combo_label: Label = $ComboLabel
@onready var hp_container: HBoxContainer = $TopBar/HPContainer

# ============================================================================
# STATE
# ============================================================================

var current_combo: int = 0

# HP Icons (filled/empty hearts)
var hp_icons: Array[TextureRect] = []

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Connect to Global Signals
	Global.score_changed.connect(_on_score_changed)
	Global.coins_changed.connect(_on_coins_changed)

	# Hide Combo initially
	combo_label.visible = false

	# Setup HP Icons
	setup_hp_icons()

	# Initial Display
	update_display()

	print("[HUD] Ready")

# ============================================================================
# HP ICONS SETUP
# ============================================================================

func setup_hp_icons():
	"""Erstellt HP-Icons basierend auf Player-Max-HP"""
	# Get Player
	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		push_warning("[HUD] Player not found")
		return

	# Connect Player Signals
	player.took_damage.connect(_on_player_took_damage)
	player.died.connect(_on_player_died)
	player.combo_increased.connect(_on_combo_increased)
	player.combo_reset.connect(_on_combo_reset)

	# Create HP Icons
	for i in range(player.max_hp):
		var icon = TextureRect.new()
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(32, 32)

		# TODO: Später Texture laden
		# icon.texture = load("res://assets/sprites/ui/hp_icon.png")

		# Placeholder: ColorRect
		icon.modulate = Color(1.0, 0.2, 0.2)  # Red

		hp_container.add_child(icon)
		hp_icons.append(icon)

	# Update Display
	update_hp_display(player.hp)

# ============================================================================
# DISPLAY UPDATES
# ============================================================================

func update_display():
	"""Updated Score + Coins Display"""
	score_label.text = "Score: %d" % Global.current_round_score
	coins_label.text = "Coins: %d" % Global.coins

func update_hp_display(current_hp: int):
	"""Updated HP-Icons (filled vs empty)"""
	for i in range(hp_icons.size()):
		if i < current_hp:
			# Filled Heart
			hp_icons[i].modulate = Color(1.0, 0.2, 0.2)  # Red
			hp_icons[i].scale = Vector2(1.0, 1.0)
		else:
			# Empty Heart
			hp_icons[i].modulate = Color(0.3, 0.3, 0.3)  # Gray
			hp_icons[i].scale = Vector2(0.8, 0.8)

func update_combo_display(combo: int):
	"""Updated Combo-Counter"""
	current_combo = combo

	if combo >= 10:
		# Show Combo (ab 10er Combo)
		combo_label.visible = true
		combo_label.text = "COMBO x%d" % combo

		# Scale Animation (Ping)
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)

		# Color based on Combo Level
		if combo >= 30:
			combo_label.modulate = Color(1.0, 0.5, 0.0)  # Orange (Call of Wrath)
		elif combo >= 20:
			combo_label.modulate = Color(1.0, 1.0, 0.0)  # Yellow (Thunder Charge)
		elif combo >= 10:
			combo_label.modulate = Color(0.7, 0.3, 1.0)  # Purple (Time Crystal)
	else:
		# Hide Combo (unter 10)
		combo_label.visible = false

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_score_changed(new_score: int):
	"""Score hat sich geändert"""
	update_display()

func _on_coins_changed(new_coins: int):
	"""Coins haben sich geändert"""
	update_display()

func _on_player_took_damage(remaining_hp: int):
	"""Player nahm Schaden"""
	update_hp_display(remaining_hp)

	# Flash HP Bar (Red → White)
	flash_hp_bar()

func _on_player_died():
	"""Player ist gestorben"""
	update_hp_display(0)

func _on_combo_increased(combo: int):
	"""Combo erhöht"""
	update_combo_display(combo)

func _on_combo_reset():
	"""Combo zurückgesetzt"""
	update_combo_display(0)

# ============================================================================
# VISUAL EFFECTS
# ============================================================================

func flash_hp_bar():
	"""Lässt HP-Bar kurz aufblitzen (Damage Feedback)"""
	for icon in hp_icons:
		icon.modulate = Color(1.0, 1.0, 1.0)  # White

	# Tween zurück zu Normal
	await get_tree().create_timer(0.1).timeout

	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		update_hp_display(player.hp)
