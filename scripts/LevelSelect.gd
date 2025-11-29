# LevelSelect.gd - Level Selection Screen
extends Control

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var title_label: Label = $TitleLabel
@onready var level_grid: GridContainer = $LevelGrid
@onready var back_button: Button = $BackButton

# ============================================================================
# STATE
# ============================================================================

var level_buttons: Array[Button] = []

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
# BUTTON HANDLERS
# ============================================================================

func _on_level_button_pressed(level: int):
	"""Level Button geklickt"""
	if not Global.is_level_unlocked(level):
		print("[LevelSelect] Level %d is locked" % level)
		return

	Global.selected_level = level
	print("[LevelSelect] Level %d selected" % level)

	# Load GameScene
	SceneLoader.load_scene("res://Scenes/game.tscn")

func _on_back_button_pressed():
	"""Back Button geklickt"""
	print("[LevelSelect] Back to Main Menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
