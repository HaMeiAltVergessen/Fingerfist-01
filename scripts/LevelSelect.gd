# LevelSelect.gd - Level Selection Screen
extends Control

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var title_label: Label = $TitleLabel
@onready var level_grid: GridContainer = $LevelGrid
@onready var back_button: Button = $BackButton

# Details Panel (created dynamically)
var details_panel: Panel
var details_title: Label
var details_wall_hp: Label
var details_highscore: Label
var details_combo: Label
var details_items_header: Label
var details_items_container: VBoxContainer
var details_play_button: Button
var details_close_button: Button

# Pre-Round Item Toggle Buttons (rebuilt each time panel opens)
var item_toggle_buttons: Array[Button] = []

# Stats Display (created dynamically) - Total Score / Coins / Levels Unlocked
var stats_panel: Panel
var total_score_label: Label
var coins_label: Label
var levels_unlocked_label: Label

# ============================================================================
# STATE
# ============================================================================

var level_buttons: Array[Button] = []
var selected_level_for_details: int = 0

# Level Names
const LEVEL_NAMES: Array[String] = [
	"Fire and Shadows",
	"Endless Cave",
	"Hope",
	"Holding On",
	"Willpower",
	"Into the Light",
	"Final Stand under the Sun",
]

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	title_label.text = "SELECT LEVEL"

	# Connect Back Button
	back_button.pressed.connect(_on_back_button_pressed)

	# Create Level Buttons
	create_level_buttons()

	# Update Button States
	update_button_states()

	# Create Details Panel
	create_details_panel()

	# Create Stats Display (Total Score / Coins / Levels Unlocked)
	create_stats_panel()
	update_stats_panel()

	# Live-Update bei Änderungen (z.B. Coins nach Shop-Kauf)
	Global.coins_changed.connect(_on_stats_changed)
	Global.score_changed.connect(_on_stats_changed)

	print("[LevelSelect] Ready")

# ============================================================================
# STATS DISPLAY
# ============================================================================

func create_stats_panel():
	"""Erstellt Stats-Panel oben links (Total Score / Coins / Levels Unlocked)"""
	stats_panel = Panel.new()
	stats_panel.name = "StatsPanel"
	stats_panel.position = Vector2(20, 20)
	stats_panel.custom_minimum_size = Vector2(240, 150)
	add_child(stats_panel)

	total_score_label = Label.new()
	total_score_label.name = "TotalScoreLabel"
	total_score_label.position = Vector2(12, 12)
	total_score_label.add_theme_font_size_override("font_size", 16)
	stats_panel.add_child(total_score_label)

	coins_label = Label.new()
	coins_label.name = "CoinsLabel"
	coins_label.position = Vector2(12, 60)
	coins_label.add_theme_font_size_override("font_size", 16)
	stats_panel.add_child(coins_label)

	levels_unlocked_label = Label.new()
	levels_unlocked_label.name = "LevelsUnlockedLabel"
	levels_unlocked_label.position = Vector2(12, 108)
	levels_unlocked_label.add_theme_font_size_override("font_size", 16)
	stats_panel.add_child(levels_unlocked_label)

func update_stats_panel():
	"""Aktualisiert die Stats-Anzeige"""
	total_score_label.text = "Total Score:\n   %d" % Global.total_highscore
	coins_label.text = "Coins:\n   %d" % Global.coins
	levels_unlocked_label.text = "Levels Unlocked:\n   %d / 7" % Global.unlocked_levels.size()

func _on_stats_changed(_value):
	"""Stats haben sich geändert"""
	update_stats_panel()

# ============================================================================
# LEVEL BUTTONS
# ============================================================================

func create_level_buttons():
	"""Erstellt 7 Level-Buttons"""
	# Clear existing buttons
	for child in level_grid.get_children():
		child.queue_free()

	level_buttons.clear()

	# Create 7 level buttons
	for level in range(1, 8):
		var button = create_level_button(level)
		level_grid.add_child(button)
		level_buttons.append(button)

func create_level_button(level: int) -> Button:
	"""Erstellt einzelnen Level-Button"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(180, 120)
	button.name = "Level%dButton" % level

	var is_unlocked = Global.is_level_unlocked(level)
	if is_unlocked:
		button.text = "Level %d\n%s" % [level, LEVEL_NAMES[level - 1]]
	else:
		button.text = "Level %d\nLOCKED" % level

	button.pressed.connect(_on_level_button_pressed.bind(level))
	return button

func update_button_states():
	"""Updated Button-Zustände basierend auf Unlock-Status"""
	for i in range(level_buttons.size()):
		var level = i + 1
		var button = level_buttons[i]
		var is_unlocked = Global.is_level_unlocked(level)

		if is_unlocked:
			# Unlocked - Show name + highscore
			button.text = "Level %d\n%s" % [level, LEVEL_NAMES[level - 1]]

			var highscore = Global.get_highscore(level)
			if highscore > 0:
				button.text += "\nBest: %d" % highscore

			button.disabled = false
			button.modulate = Color.WHITE
		else:
			# Locked - Gray out
			button.text = "Level %d\nLOCKED" % level
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5)

# ============================================================================
# DETAILS PANEL
# ============================================================================

func create_details_panel():
	"""Erstellt Details-Panel (dynamisch)"""
	# Main Panel
	details_panel = Panel.new()
	details_panel.name = "DetailsPanel"
	details_panel.visible = false
	details_panel.custom_minimum_size = Vector2(500, 560)
	details_panel.position = Vector2(290, 90)  # Center of screen
	add_child(details_panel)

	# Title Label
	details_title = Label.new()
	details_title.name = "DetailTitle"
	details_title.position = Vector2(20, 20)
	details_title.add_theme_font_size_override("font_size", 24)
	details_panel.add_child(details_title)

	# Wall HP Label
	details_wall_hp = Label.new()
	details_wall_hp.name = "DetailWallHP"
	details_wall_hp.position = Vector2(20, 80)
	details_wall_hp.add_theme_font_size_override("font_size", 18)
	details_panel.add_child(details_wall_hp)

	# Highscore Label
	details_highscore = Label.new()
	details_highscore.name = "DetailHighscore"
	details_highscore.position = Vector2(20, 130)
	details_highscore.add_theme_font_size_override("font_size", 18)
	details_panel.add_child(details_highscore)

	# Combo Label
	details_combo = Label.new()
	details_combo.name = "DetailCombo"
	details_combo.position = Vector2(20, 180)
	details_combo.add_theme_font_size_override("font_size", 18)
	details_panel.add_child(details_combo)

	# Items Header
	details_items_header = Label.new()
	details_items_header.name = "DetailItemsHeader"
	details_items_header.text = "YOUR ITEMS (tap to activate for this run)"
	details_items_header.position = Vector2(20, 230)
	details_items_header.add_theme_font_size_override("font_size", 18)
	details_panel.add_child(details_items_header)

	# Items Container (toggle buttons rebuilt per open)
	details_items_container = VBoxContainer.new()
	details_items_container.name = "DetailItemsContainer"
	details_items_container.position = Vector2(20, 265)
	details_items_container.custom_minimum_size = Vector2(460, 170)
	details_panel.add_child(details_items_container)

	# Play Button
	details_play_button = Button.new()
	details_play_button.name = "DetailPlayButton"
	details_play_button.text = "START LEVEL"
	details_play_button.position = Vector2(50, 470)
	details_play_button.custom_minimum_size = Vector2(180, 60)
	details_play_button.pressed.connect(_on_detail_play_button_pressed)
	details_panel.add_child(details_play_button)

	# Close Button
	details_close_button = Button.new()
	details_close_button.name = "DetailCloseButton"
	details_close_button.text = "BACK"
	details_close_button.position = Vector2(270, 470)
	details_close_button.custom_minimum_size = Vector2(180, 60)
	details_close_button.pressed.connect(_on_detail_close_button_pressed)
	details_panel.add_child(details_close_button)

	print("[LevelSelect] Details Panel created")

func show_level_details(level: int):
	"""Zeigt Level-Details-Panel"""
	selected_level_for_details = level

	# Update Title
	details_title.text = "Level %d - %s" % [level, LEVEL_NAMES[level - 1]]

	# Wall HP Info
	var max_hp = Global.WALL_HP_PER_LEVEL.get(level, 0)
	var current_hp = Global.get_wall_remaining_hp(level)
	if level == 7:
		details_wall_hp.text = "Endless Mode - No Wall"
	else:
		details_wall_hp.text = "Wall HP: %d / %d" % [current_hp, max_hp]

	# Highscore Info
	var highscore = Global.get_highscore(level)
	if highscore > 0:
		details_highscore.text = "Highscore: %d" % highscore
	else:
		details_highscore.text = "Highscore: Not Set"

	# Combo Info
	var highest_combo = Global.get_highest_combo(level)
	if highest_combo > 0:
		details_combo.text = "Best Combo: %d" % highest_combo
	else:
		details_combo.text = "Best Combo: Not Set"

	# Render owned items as pre-round activation toggles
	render_item_toggles()

	# Show Panel
	details_panel.visible = true

	print("[LevelSelect] Showing details for Level %d" % level)

func render_item_toggles():
	"""Baut die Item-Toggle-Buttons (nur besessene Items) neu auf"""
	# Alte Buttons / Hinweistext entfernen
	for child in details_items_container.get_children():
		child.queue_free()
	item_toggle_buttons.clear()

	var any_owned := false

	for item_id in SaveSystem.ITEMS.keys():
		if not Global.is_item_owned(item_id):
			continue

		any_owned = true
		var item_data = SaveSystem.ITEMS[item_id]

		var button = Button.new()
		button.name = "ItemToggle_%s" % item_id
		button.custom_minimum_size = Vector2(440, 36)
		button.pressed.connect(_on_item_toggle_pressed.bind(item_id))
		details_items_container.add_child(button)
		item_toggle_buttons.append(button)

		update_item_toggle(button, item_id, item_data)

	if not any_owned:
		var hint = Label.new()
		hint.text = "No items owned — visit the Shop to buy items."
		hint.add_theme_font_size_override("font_size", 16)
		details_items_container.add_child(hint)

func update_item_toggle(button: Button, item_id: String, item_data: Dictionary):
	"""Aktualisiert Text/Farbe eines Item-Toggles je nach Aktiv-Status"""
	var is_active = Global.is_item_active(item_id)
	if is_active:
		button.text = "%s - ACTIVE" % item_data.name
		button.modulate = Color(0.5, 1.0, 0.5)  # Green
	else:
		button.text = "%s - inactive" % item_data.name
		button.modulate = Color.WHITE

func _on_item_toggle_pressed(item_id: String):
	"""Item-Toggle geklickt - aktiviert/deaktiviert für die nächste Runde"""
	if Global.is_item_active(item_id):
		Global.deactivate_item(item_id)
		print("[LevelSelect] Deactivated item: %s" % item_id)
	else:
		Global.activate_item(item_id)
		print("[LevelSelect] Activated item: %s" % item_id)

	# Persistieren und Toggles neu rendern
	SaveSystem.save_game()
	render_item_toggles()

func hide_level_details():
	"""Versteckt Level-Details-Panel"""
	details_panel.visible = false

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_level_button_pressed(level: int):
	"""Level Button geklickt - Zeigt Details"""
	if not Global.is_level_unlocked(level):
		print("[LevelSelect] Level %d is locked" % level)
		return

	# Show Details Panel instead of loading directly
	show_level_details(level)

func _on_detail_play_button_pressed():
	"""Play Button im Details-Panel geklickt"""
	Global.selected_level = selected_level_for_details
	print("[LevelSelect] Starting Level %d" % selected_level_for_details)

	# Levelspezifische Szene laden (eigene Spawnpunkte etc.); Fallback auf game.tscn
	var level_path := "res://Scenes/Levels/Level%d.tscn" % selected_level_for_details
	if not ResourceLoader.exists(level_path):
		level_path = "res://Scenes/game.tscn"
	SceneLoader.load_scene(level_path)

func _on_detail_close_button_pressed():
	"""Close Button im Details-Panel geklickt"""
	hide_level_details()

func _on_back_button_pressed():
	"""Back Button geklickt"""
	print("[LevelSelect] Back to Main Menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
