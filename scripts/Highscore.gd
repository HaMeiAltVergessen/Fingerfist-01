# Highscore.gd - Highscore / Statistik Screen
# UI komplett in Code aufgebaut (kein .tscn-Knoten -> kein $onready-Desync-Risiko).
extends Node2D

# Level-Namen (parallel zu LevelSelect.gd, Index 0 = Level 1)
const LEVEL_NAMES: Array[String] = [
	"Beginner's Trial",
	"Rising Challenge",
	"Breaking Point",
	"Relentless Assault",
	"Expert's Gauntlet",
	"Master's Ordeal",
	"Final Stand (Endless)",
]

func _ready():
	create_background()
	create_title()
	create_level_rows()
	create_totals()
	create_back_button()
	print("[Highscore] Ready")

# ============================================================================
# UI CREATION
# ============================================================================

func create_background():
	"""Vollflächiger dunkler Hintergrund für Lesbarkeit"""
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.1, 0.1, 0.15)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1280, 720)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func create_title():
	"""Titel-Label"""
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "HIGHSCORES"
	title.position = Vector2(0, 40)
	title.size = Vector2(1280, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	add_child(title)

func create_level_rows():
	"""Eine Zeile pro Level mit Score + bestem Combo"""
	var start_y := 140
	var row_h := 56

	for level in range(1, 8):
		var row = Label.new()
		row.name = "LevelRow%d" % level
		row.position = Vector2(240, start_y + (level - 1) * row_h)
		row.size = Vector2(800, row_h)
		row.add_theme_font_size_override("font_size", 22)

		var label_name := LEVEL_NAMES[level - 1]
		var score := Global.get_highscore(level)
		var combo := Global.get_highest_combo(level)

		var score_text := "%d" % score if score > 0 else "—"
		var combo_text := "%d" % combo if combo > 0 else "—"

		row.text = "Level %d  %s" % [level, label_name]
		row.text += "\n      Score: %s     Best Combo: %s" % [score_text, combo_text]

		# Gesperrte Level dezent ausgrauen
		if not Global.is_level_unlocked(level):
			row.modulate = Color(0.5, 0.5, 0.5)

		add_child(row)

func create_totals():
	"""Gesamt-Statistiken unten"""
	var totals = Label.new()
	totals.name = "TotalsLabel"
	totals.position = Vector2(240, 560)
	totals.size = Vector2(800, 100)
	totals.add_theme_font_size_override("font_size", 20)
	totals.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))

	totals.text = "Total Score: %d        Coins: %d" % [Global.total_highscore, Global.coins]
	totals.text += "\nRounds Played: %d        Playtime: %s" % [
		Global.total_rounds_played,
		_format_playtime(Global.total_playtime)
	]
	add_child(totals)

func create_back_button():
	"""Back Button → Main Menu"""
	var back = Button.new()
	back.name = "BackButton"
	back.text = "Back"
	back.position = Vector2(540, 650)
	back.custom_minimum_size = Vector2(200, 50)
	back.add_theme_font_size_override("font_size", 20)
	back.pressed.connect(_on_back_pressed)
	add_child(back)

# ============================================================================
# HANDLERS / UTILITY
# ============================================================================

func _on_back_pressed():
	print("[Highscore] Back to main menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")

func _format_playtime(seconds: float) -> String:
	"""Sekunden → 'Hh Mm' bzw. 'Mm Ss'"""
	var total := int(seconds)
	var h := total / 3600
	var m := (total % 3600) / 60
	var s := total % 60
	if h > 0:
		return "%dh %dm" % [h, m]
	return "%dm %ds" % [m, s]
