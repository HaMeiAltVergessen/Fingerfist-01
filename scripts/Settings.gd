# Settings.gd - Settings Menu Screen
extends Control

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var title_label: Label = $TitleLabel
@onready var back_button: Button = $BackButton

# Settings Controls (created dynamically)
var settings_panel: Panel
var sfx_volume_label: Label
var sfx_volume_slider: HSlider
var music_volume_label: Label
var music_volume_slider: HSlider
var fullscreen_label: Label
var fullscreen_checkbox: CheckBox
var reset_button: Button

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	title_label.text = "SETTINGS"

	# Connect Back Button
	back_button.pressed.connect(_on_back_button_pressed)

	# Create Settings Panel
	create_settings_panel()

	# Load Current Settings
	load_settings()

	print("[Settings] Ready")

# ============================================================================
# SETTINGS PANEL
# ============================================================================

func create_settings_panel():
	"""Erstellt Settings-Panel mit Controls"""
	# Main Panel
	settings_panel = Panel.new()
	settings_panel.name = "SettingsPanel"
	settings_panel.position = Vector2(290, 150)
	settings_panel.custom_minimum_size = Vector2(500, 400)
	add_child(settings_panel)

	# SFX Volume Label
	sfx_volume_label = Label.new()
	sfx_volume_label.name = "SFXVolumeLabel"
	sfx_volume_label.text = "SFX Volume: 100%"
	sfx_volume_label.position = Vector2(20, 30)
	sfx_volume_label.add_theme_font_size_override("font_size", 18)
	settings_panel.add_child(sfx_volume_label)

	# SFX Volume Slider
	sfx_volume_slider = HSlider.new()
	sfx_volume_slider.name = "SFXVolumeSlider"
	sfx_volume_slider.position = Vector2(20, 60)
	sfx_volume_slider.custom_minimum_size = Vector2(460, 30)
	sfx_volume_slider.min_value = 0
	sfx_volume_slider.max_value = 100
	sfx_volume_slider.step = 1
	sfx_volume_slider.value = 100
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	settings_panel.add_child(sfx_volume_slider)

	# Music Volume Label
	music_volume_label = Label.new()
	music_volume_label.name = "MusicVolumeLabel"
	music_volume_label.text = "Music Volume: 100%"
	music_volume_label.position = Vector2(20, 120)
	music_volume_label.add_theme_font_size_override("font_size", 18)
	settings_panel.add_child(music_volume_label)

	# Music Volume Slider
	music_volume_slider = HSlider.new()
	music_volume_slider.name = "MusicVolumeSlider"
	music_volume_slider.position = Vector2(20, 150)
	music_volume_slider.custom_minimum_size = Vector2(460, 30)
	music_volume_slider.min_value = 0
	music_volume_slider.max_value = 100
	music_volume_slider.step = 1
	music_volume_slider.value = 100
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	settings_panel.add_child(music_volume_slider)

	# Fullscreen Label
	fullscreen_label = Label.new()
	fullscreen_label.name = "FullscreenLabel"
	fullscreen_label.text = "Fullscreen:"
	fullscreen_label.position = Vector2(20, 210)
	fullscreen_label.add_theme_font_size_override("font_size", 18)
	settings_panel.add_child(fullscreen_label)

	# Fullscreen Checkbox
	fullscreen_checkbox = CheckBox.new()
	fullscreen_checkbox.name = "FullscreenCheckbox"
	fullscreen_checkbox.position = Vector2(180, 205)
	fullscreen_checkbox.button_pressed = false
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	settings_panel.add_child(fullscreen_checkbox)

	# Reset Button
	reset_button = Button.new()
	reset_button.name = "ResetButton"
	reset_button.text = "RESET TO DEFAULTS"
	reset_button.position = Vector2(150, 300)
	reset_button.custom_minimum_size = Vector2(200, 50)
	reset_button.pressed.connect(_on_reset_button_pressed)
	settings_panel.add_child(reset_button)

	print("[Settings] Settings panel created")

# ============================================================================
# SETTINGS MANAGEMENT
# ============================================================================

func load_settings():
	"""Lädt aktuelle Settings"""
	# SFX Volume (Audio-API ist 0.0–1.0, Slider 0–100)
	var sfx_volume = Audio.get_sfx_volume() * 100.0
	sfx_volume_slider.value = sfx_volume
	sfx_volume_label.text = "SFX Volume: %d%%" % int(sfx_volume)

	# Music Volume (Audio-API ist 0.0–1.0, Slider 0–100)
	var music_volume = Audio.get_music_volume() * 100.0
	music_volume_slider.value = music_volume
	music_volume_label.text = "Music Volume: %d%%" % int(music_volume)

	# Fullscreen
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_checkbox.button_pressed = is_fullscreen

	print("[Settings] Settings loaded")

func save_settings():
	"""Speichert Settings"""
	SaveSystem.save_game()
	print("[Settings] Settings saved")

# ============================================================================
# CONTROL HANDLERS
# ============================================================================

func _on_sfx_volume_changed(value: float):
	"""SFX Volume Slider verändert (Slider 0–100 -> Audio-API 0.0–1.0)"""
	Audio.set_sfx_volume(value / 100.0)
	sfx_volume_label.text = "SFX Volume: %d%%" % int(value)
	save_settings()

func _on_music_volume_changed(value: float):
	"""Music Volume Slider verändert (Slider 0–100 -> Audio-API 0.0–1.0)"""
	Audio.set_music_volume(value / 100.0)
	music_volume_label.text = "Music Volume: %d%%" % int(value)
	save_settings()

func _on_fullscreen_toggled(toggled_on: bool):
	"""Fullscreen Checkbox getoggelt"""
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func _on_reset_button_pressed():
	"""Reset Button geklickt"""
	# Reset to defaults (siehe SaveSystem: SFX 1.0, Music 0.7)
	sfx_volume_slider.value = 100
	music_volume_slider.value = 70
	fullscreen_checkbox.button_pressed = false

	# Apply (Audio-API ist 0.0–1.0)
	Audio.set_sfx_volume(1.0)
	Audio.set_music_volume(0.7)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	save_settings()

	print("[Settings] Reset to defaults")

# ============================================================================
# NAVIGATION
# ============================================================================

func _on_back_button_pressed():
	"""Back Button geklickt"""
	print("[Settings] Back to Main Menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
