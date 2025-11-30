# SaveIndicator.gd - Visual Save/Load Feedback
extends CanvasLayer

# ============================================================================
# NODE REFERENCES
# ============================================================================

var indicator_panel: Panel
var icon_label: Label
var text_label: Label

# ============================================================================
# STATE
# ============================================================================

var fade_tween: Tween

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create UI dynamically
	create_indicator_ui()

	# Connect to SaveSystem
	SaveSystem.saved.connect(_on_save_complete)
	SaveSystem.loaded.connect(_on_load_complete)

	visible = false
	print("[SaveIndicator] Ready")

# ============================================================================
# UI CREATION
# ============================================================================

func create_indicator_ui():
	"""Erstellt Save-Indicator UI dynamisch"""
	# Main Panel
	indicator_panel = Panel.new()
	indicator_panel.name = "IndicatorPanel"
	indicator_panel.custom_minimum_size = Vector2(200, 60)

	# Position in top-right corner
	indicator_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	indicator_panel.offset_left = -220
	indicator_panel.offset_top = 20
	indicator_panel.offset_right = -20
	indicator_panel.offset_bottom = 80

	add_child(indicator_panel)

	# Icon Label (emoji)
	icon_label = Label.new()
	icon_label.name = "Icon"
	icon_label.position = Vector2(10, 10)
	icon_label.custom_minimum_size = Vector2(40, 40)
	icon_label.add_theme_font_size_override("font_size", 28)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.text = "💾"
	indicator_panel.add_child(icon_label)

	# Text Label
	text_label = Label.new()
	text_label.name = "Text"
	text_label.position = Vector2(55, 10)
	text_label.custom_minimum_size = Vector2(135, 40)
	text_label.add_theme_font_size_override("font_size", 16)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.text = "Saved"
	indicator_panel.add_child(text_label)

	print("[SaveIndicator] UI created")

# ============================================================================
# SAVE/LOAD FEEDBACK
# ============================================================================

func _on_save_complete(is_auto: bool):
	"""Save abgeschlossen - zeige Indicator"""
	var text = "Auto-Saved" if is_auto else "Game Saved"
	show_indicator(text, "💾", Color(0.3, 1.0, 0.3))

func _on_load_complete():
	"""Load abgeschlossen"""
	show_indicator("Game Loaded", "📂", Color(0.3, 0.8, 1.0))

func show_indicator(text: String, emoji: String, color: Color):
	"""Zeigt Save-Indicator

	Args:
		text: Text to display
		emoji: Icon emoji
		color: Color tint
	"""
	text_label.text = text
	icon_label.text = emoji
	indicator_panel.modulate = color

	visible = true

	# Cancel existing tween
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	# Fade-in
	indicator_panel.modulate.a = 0.0
	fade_tween = create_tween()
	fade_tween.tween_property(indicator_panel, "modulate:a", 1.0, 0.2)

	# Wait 2s
	fade_tween.tween_interval(2.0)

	# Fade-out
	fade_tween.tween_property(indicator_panel, "modulate:a", 0.0, 0.3)
	fade_tween.tween_callback(_on_fade_complete)

func _on_fade_complete():
	"""Fade abgeschlossen - verstecke Indicator"""
	visible = false
