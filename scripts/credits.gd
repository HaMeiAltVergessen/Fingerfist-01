# credits.gd - Credits Screen
# UI komplett in Code aufgebaut (Scene CreditScreen.tscn hängt nur das Script an).
extends Node2D

func _ready():
	create_background()
	create_title()
	create_credits_text()
	create_back_button()
	print("[Credits] Ready")

# ============================================================================
# UI CREATION
# ============================================================================

func create_background():
	"""Vollflächiger dunkler Hintergrund"""
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1280, 720)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func create_title():
	"""Titel-Label"""
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "FINGERFIST"
	title.position = Vector2(0, 80)
	title.size = Vector2(1280, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	add_child(title)

func create_credits_text():
	"""Credits-Inhalt (Platzhalter, später ersetzbar)"""
	var credits = Label.new()
	credits.name = "CreditsLabel"
	credits.position = Vector2(0, 220)
	credits.size = Vector2(1280, 380)
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.add_theme_font_size_override("font_size", 26)

	# Platzhalter-Credits — Namen vom Nutzer, später anpassen
	var lines := [
		"— A Game By —",
		"",
		"Sebastian",
		"Claude",
		"Omnia Vortex",
		"",
		"",
		"Made with Godot 4.4",
	]
	credits.text = "\n".join(lines)
	add_child(credits)

func create_back_button():
	"""Back Button → Main Menu"""
	var back = Button.new()
	back.name = "BackButton"
	back.text = "Back"
	back.position = Vector2(540, 640)
	back.custom_minimum_size = Vector2(200, 50)
	back.add_theme_font_size_override("font_size", 20)
	back.pressed.connect(_on_back_pressed)
	add_child(back)

# ============================================================================
# HANDLERS
# ============================================================================

func _on_back_pressed():
	print("[Credits] Back to main menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
