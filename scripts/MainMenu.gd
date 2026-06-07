# MainMenu.gd - Main Menu Screen
extends Node2D

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var play_button: Button = $CanvasLayer/MenuContainer/PlayButton
@onready var new_game_button: Button = $CanvasLayer/MenuContainer/NewGameButton
@onready var shop_button: Button = $CanvasLayer/MenuContainer/ShopButton
@onready var settings_button: Button = $CanvasLayer/MenuContainer/SettingsButton
@onready var quit_button: Button = $CanvasLayer/MenuContainer/QuitButton

# Title (created dynamically)
var title_label: Label

# New Game Confirmation Dialog (created dynamically)
var confirm_dialog: Panel
var confirm_yes_button: Button
var confirm_no_button: Button

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create Title
	create_title()

	# Create New Game Confirmation Dialog
	create_confirm_dialog()

	# Connect Buttons
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_button_pressed)
	if shop_button:
		shop_button.pressed.connect(_on_shop_button_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

	# Main Theme (läuft über Menü-Unterszenen weiter, kein Neustart dank Guard)
	Audio.play_music("Main Menu.mp3")

	print("[MainMenu] Ready")

# ============================================================================
# UI CREATION
# ============================================================================

func create_title():
	"""Erstellt Titel-Label"""
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "FINGERFIST"
	title_label.position = Vector2(440, 80)
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # Gold
	add_child(title_label)

	print("[MainMenu] Title created")

func create_confirm_dialog():
	"""Erstellt Bestätigungsdialog für New Game (dynamisch)"""
	confirm_dialog = Panel.new()
	confirm_dialog.name = "ConfirmDialog"
	confirm_dialog.visible = false
	confirm_dialog.custom_minimum_size = Vector2(440, 220)
	confirm_dialog.position = Vector2(420, 250)
	# In den CanvasLayer hängen, damit der Dialog ÜBER den Menü-Buttons liegt
	canvas_layer.add_child(confirm_dialog)

	var title = Label.new()
	title.text = "NEW GAME"
	title.position = Vector2(20, 20)
	title.add_theme_font_size_override("font_size", 24)
	confirm_dialog.add_child(title)

	var message = Label.new()
	message.text = "Neues Spiel starten?\nAller Fortschritt geht verloren."
	message.position = Vector2(20, 70)
	message.custom_minimum_size = Vector2(400, 60)
	message.add_theme_font_size_override("font_size", 16)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirm_dialog.add_child(message)

	confirm_yes_button = Button.new()
	confirm_yes_button.text = "YES, RESET"
	confirm_yes_button.position = Vector2(30, 150)
	confirm_yes_button.custom_minimum_size = Vector2(170, 50)
	confirm_yes_button.modulate = Color(1.0, 0.5, 0.5)
	confirm_yes_button.pressed.connect(_on_confirm_yes_pressed)
	confirm_dialog.add_child(confirm_yes_button)

	confirm_no_button = Button.new()
	confirm_no_button.text = "CANCEL"
	confirm_no_button.position = Vector2(240, 150)
	confirm_no_button.custom_minimum_size = Vector2(170, 50)
	confirm_no_button.modulate = Color(0.5, 1.0, 0.5)
	confirm_no_button.pressed.connect(_on_confirm_no_pressed)
	confirm_dialog.add_child(confirm_no_button)

	print("[MainMenu] Confirm dialog created")

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_play_button_pressed():
	"""Play Button → Level Select"""
	print("[MainMenu] Play pressed")
	SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")

func _on_new_game_button_pressed():
	"""New Game Button → Bestätigungsdialog"""
	print("[MainMenu] New Game pressed")
	confirm_dialog.visible = true

func _on_confirm_yes_pressed():
	"""Reset bestätigt → kompletter Reset, dann Level Select"""
	print("[MainMenu] New Game confirmed - resetting all progress")
	Global.reset_all_progress()
	SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")

func _on_confirm_no_pressed():
	"""Reset abgebrochen"""
	confirm_dialog.visible = false

func _on_shop_button_pressed():
	"""Shop Button → Shop"""
	print("[MainMenu] Shop pressed")
	SceneLoader.load_scene("res://Scenes/shop.tscn")

func _on_settings_button_pressed():
	"""Settings Button → Settings"""
	print("[MainMenu] Settings pressed")
	SceneLoader.load_scene("res://Scenes/Settings.tscn")

func _on_quit_button_pressed():
	"""Quit Button → Exit Game"""
	print("[MainMenu] Quit pressed")
	get_tree().quit()
