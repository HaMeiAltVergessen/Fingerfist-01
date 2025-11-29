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
var details_play_button: Button
var details_close_button: Button

# ============================================================================
# STATE
# ============================================================================

var level_buttons: Array[Button] = []
var selected_level_for_details: int = 0

# Level Names
const LEVEL_NAMES: Array[String] = [
	"Beginner's Trial",
	"Rising Challenge",
	"Breaking Point",
	"Relentless Assault",
	"Expert's Gauntlet",
	"Master's Ordeal",
	"Final Stand",
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

	print("[LevelSelect] Ready")

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
		button.text = "Level %d\n🔒 LOCKED" % level

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
				button.text += "\n🏆 %d" % highscore

			button.disabled = false
			button.modulate = Color.WHITE
		else:
			# Locked - Gray out
			button.text = "Level %d\n🔒 LOCKED" % level
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
	details_panel.custom_minimum_size = Vector2(500, 400)
	details_panel.position = Vector2(290, 160)  # Center of screen
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

	# Play Button
	details_play_button = Button.new()
	details_play_button.name = "DetailPlayButton"
	details_play_button.text = "START LEVEL"
	details_play_button.position = Vector2(50, 280)
	details_play_button.custom_minimum_size = Vector2(180, 60)
	details_play_button.pressed.connect(_on_detail_play_button_pressed)
	details_panel.add_child(details_play_button)

	# Close Button
	details_close_button = Button.new()
	details_close_button.name = "DetailCloseButton"
	details_close_button.text = "BACK"
	details_close_button.position = Vector2(270, 280)
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
		details_wall_hp.text = "⚔️ Endless Mode - No Wall"
	else:
		details_wall_hp.text = "🏰 Wall HP: %d / %d" % [current_hp, max_hp]

	# Highscore Info
	var highscore = Global.get_highscore(level)
	if highscore > 0:
		details_highscore.text = "🏆 Highscore: %d" % highscore
	else:
		details_highscore.text = "🏆 Highscore: Not Set"

	# Combo Info
	var highest_combo = Global.get_highest_combo(level)
	if highest_combo > 0:
		details_combo.text = "🔥 Best Combo: %d" % highest_combo
	else:
		details_combo.text = "🔥 Best Combo: Not Set"

	# Show Panel
	details_panel.visible = true

	print("[LevelSelect] Showing details for Level %d" % level)

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

	# Load GameScene
	SceneLoader.load_scene("res://Scenes/game.tscn")

func _on_detail_close_button_pressed():
	"""Close Button im Details-Panel geklickt"""
	hide_level_details()

func _on_back_button_pressed():
	"""Back Button geklickt"""
	print("[LevelSelect] Back to Main Menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
