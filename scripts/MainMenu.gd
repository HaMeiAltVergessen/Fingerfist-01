# MainMenu.gd - Main Menu Screen
extends Node2D

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var play_button: Button = $CanvasLayer/MenuContainer/PlayButton
@onready var shop_button: Button = $CanvasLayer/MenuContainer/ShopButton
@onready var settings_button: Button = $CanvasLayer/MenuContainer/SettingsButton
@onready var highscore_button: Button = $CanvasLayer/MenuContainer/HighscoreButton
@onready var credits_button: Button = $CanvasLayer/MenuContainer/CreditsButton
@onready var quit_button: Button = $CanvasLayer/MenuContainer/QuitButton

# Stats Display (created dynamically)
var title_label: Label
var stats_panel: Panel
var total_score_label: Label
var coins_label: Label
var levels_unlocked_label: Label

# Continue Button (created dynamically)
var continue_button: Button

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create Title
	create_title()

	# Create Stats Display
	create_stats_display()

	# Create Continue Button (if save exists)
	create_continue_button()

	# Update Stats
	update_stats_display()

	# Connect Buttons
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if shop_button:
		shop_button.pressed.connect(_on_shop_button_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	if highscore_button:
		highscore_button.pressed.connect(_on_highscore_button_pressed)
	if credits_button:
		credits_button.pressed.connect(_on_credits_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_button_pressed)

	# Connect Global Signals
	Global.coins_changed.connect(_on_stats_changed)
	Global.score_changed.connect(_on_stats_changed)

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

func create_stats_display():
	"""Erstellt Stats-Display-Panel"""
	# Stats Panel
	stats_panel = Panel.new()
	stats_panel.name = "StatsPanel"
	stats_panel.position = Vector2(820, 100)
	stats_panel.custom_minimum_size = Vector2(240, 180)
	add_child(stats_panel)

	# Total Score Label
	total_score_label = Label.new()
	total_score_label.name = "TotalScoreLabel"
	total_score_label.position = Vector2(10, 10)
	total_score_label.add_theme_font_size_override("font_size", 16)
	stats_panel.add_child(total_score_label)

	# Coins Label
	coins_label = Label.new()
	coins_label.name = "CoinsLabel"
	coins_label.position = Vector2(10, 60)
	coins_label.add_theme_font_size_override("font_size", 16)
	stats_panel.add_child(coins_label)

	# Levels Unlocked Label
	levels_unlocked_label = Label.new()
	levels_unlocked_label.name = "LevelsUnlockedLabel"
	levels_unlocked_label.position = Vector2(10, 110)
	levels_unlocked_label.add_theme_font_size_override("font_size", 16)
	stats_panel.add_child(levels_unlocked_label)

	print("[MainMenu] Stats display created")

func create_continue_button():
	"""Erstellt Continue Button (nur wenn irgendein Save existiert)"""
	# Only show if any save file exists
	if not SaveSystem.any_save_exists():
		print("[MainMenu] No save files - Continue button hidden")
		return

	# Create Continue Button
	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = "📂 Continue"
	continue_button.position = Vector2(440, 160)
	continue_button.custom_minimum_size = Vector2(200, 50)
	continue_button.add_theme_font_size_override("font_size", 20)
	add_child(continue_button)

	print("[MainMenu] Continue button created")

func update_stats_display():
	"""Updated Stats-Anzeige"""
	# Total Score
	total_score_label.text = "🏆 Total Score:\n   %d" % Global.total_highscore

	# Coins
	coins_label.text = "💰 Coins:\n   %d" % Global.coins

	# Levels Unlocked
	var unlocked_count = Global.unlocked_levels.size()
	levels_unlocked_label.text = "🗝️ Levels Unlocked:\n   %d / 7" % unlocked_count

func _on_stats_changed(_value):
	"""Stats haben sich geändert"""
	update_stats_display()

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_continue_button_pressed():
	"""Continue Button → Save Slot Select"""
	print("[MainMenu] Continue pressed - Going to slot select")
	SceneLoader.load_scene("res://Scenes/SaveSlotSelect.tscn")

func _on_play_button_pressed():
	"""Play Button → Level Select"""
	print("[MainMenu] Play pressed")
	SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")

func _on_shop_button_pressed():
	"""Shop Button → Shop"""
	print("[MainMenu] Shop pressed")
	SceneLoader.load_scene("res://Scenes/shop.tscn")

func _on_settings_button_pressed():
	"""Settings Button → Settings"""
	print("[MainMenu] Settings pressed")
	SceneLoader.load_scene("res://Scenes/Settings.tscn")

func _on_highscore_button_pressed():
	"""Highscore Button → Highscore Screen"""
	print("[MainMenu] Highscore pressed")
	SceneLoader.load_scene("res://Scenes/highscore.tscn")

func _on_credits_button_pressed():
	"""Credits Button → Credits Screen"""
	print("[MainMenu] Credits pressed")
	SceneLoader.load_scene("res://Scenes/CreditScreen.tscn")

func _on_quit_button_pressed():
	"""Quit Button → Exit Game"""
	print("[MainMenu] Quit pressed")
	get_tree().quit()
