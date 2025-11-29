# MainMenu.gd - Main Menu Screen
extends Node2D

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var play_button: Button = $CanvasLayer/MenuContainer/PlayButton
@onready var shop_button: Button = $CanvasLayer/MenuContainer/ShopButton
@onready var settings_button: Button = $CanvasLayer/MenuContainer/SettingsButton
@onready var quit_button: Button = $CanvasLayer/MenuContainer/QuitButton

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Connect Buttons
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if shop_button:
		shop_button.pressed.connect(_on_shop_button_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

	print("[MainMenu] Ready")

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_play_button_pressed():
	"""Play Button → Level Select"""
	print("[MainMenu] Play pressed")
	SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")

func _on_shop_button_pressed():
	"""Shop Button → Shop"""
	print("[MainMenu] Shop pressed")
	SceneLoader.load_scene("res://Scenes/Shop.tscn")

func _on_settings_button_pressed():
	"""Settings Button → Settings"""
	print("[MainMenu] Settings pressed")
	SceneLoader.load_scene("res://Scenes/Settings.tscn")

func _on_quit_button_pressed():
	"""Quit Button → Exit Game"""
	print("[MainMenu] Quit pressed")
	get_tree().quit()
