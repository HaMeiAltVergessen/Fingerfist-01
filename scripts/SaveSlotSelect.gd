# SaveSlotSelect.gd - Save Slot Selection Menu
extends Node2D

# ============================================================================
# UI ELEMENTS
# ============================================================================

var title_label: Label
var slot_panels: Array[Panel] = []
var back_button: Button

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create Title
	create_title()

	# Create Slot Panels
	create_slot_panels()

	# Create Back Button
	create_back_button()

	print("[SaveSlotSelect] Ready")

# ============================================================================
# UI CREATION
# ============================================================================

func create_title():
	"""Erstellt Titel"""
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Select Save Slot"
	title_label.position = Vector2(480, 80)
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	add_child(title_label)

func create_slot_panels():
	"""Erstellt 3 Save-Slot Panels"""
	for i in range(SaveSystem.SAVE_SLOT_COUNT):
		var panel = create_slot_panel(i)
		slot_panels.append(panel)
		add_child(panel)

func create_slot_panel(slot: int) -> Panel:
	"""Erstellt ein einzelnes Slot-Panel

	Args:
		slot: Slot-Index (0-2)
	"""
	var panel = Panel.new()
	panel.name = "Slot%dPanel" % slot
	panel.position = Vector2(200, 180 + slot * 140)
	panel.custom_minimum_size = Vector2(880, 120)

	# Get Slot Info
	var info = SaveSystem.get_slot_info(slot)

	# Slot Label
	var slot_label = Label.new()
	slot_label.name = "SlotLabel"
	slot_label.text = "SLOT %d" % (slot + 1)
	slot_label.position = Vector2(20, 10)
	slot_label.add_theme_font_size_override("font_size", 24)
	slot_label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	panel.add_child(slot_label)

	if info.exists:
		# Slot has save data - show info
		var info_label = Label.new()
		info_label.name = "InfoLabel"
		info_label.text = "Level %d | Score: %d | Coins: %d\nLast Save: %s" % [
			info.level,
			info.total_score,
			info.coins,
			_format_save_time(info.save_time)
		]
		info_label.position = Vector2(20, 45)
		info_label.add_theme_font_size_override("font_size", 14)
		panel.add_child(info_label)

		# Load Button
		var load_button = Button.new()
		load_button.name = "LoadButton"
		load_button.text = "Load"
		load_button.position = Vector2(680, 40)
		load_button.custom_minimum_size = Vector2(80, 40)
		load_button.pressed.connect(_on_load_slot.bind(slot))
		panel.add_child(load_button)

		# Delete Button
		var delete_button = Button.new()
		delete_button.name = "DeleteButton"
		delete_button.text = "Delete"
		delete_button.position = Vector2(780, 40)
		delete_button.custom_minimum_size = Vector2(80, 40)
		delete_button.pressed.connect(_on_delete_slot.bind(slot))
		panel.add_child(delete_button)
	else:
		# Empty Slot - show "New Game"
		var empty_label = Label.new()
		empty_label.name = "EmptyLabel"
		empty_label.text = "Empty Slot"
		empty_label.position = Vector2(20, 50)
		empty_label.add_theme_font_size_override("font_size", 16)
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		panel.add_child(empty_label)

		# New Game Button
		var new_button = Button.new()
		new_button.name = "NewButton"
		new_button.text = "New Game"
		new_button.position = Vector2(680, 40)
		new_button.custom_minimum_size = Vector2(180, 40)
		new_button.pressed.connect(_on_new_game.bind(slot))
		panel.add_child(new_button)

	return panel

func create_back_button():
	"""Erstellt Back Button"""
	back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "Back"
	back_button.position = Vector2(540, 600)
	back_button.custom_minimum_size = Vector2(200, 50)
	back_button.add_theme_font_size_override("font_size", 20)
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_load_slot(slot: int):
	"""Load-Button für Slot gedrückt"""
	print("[SaveSlotSelect] Loading slot %d" % slot)
	SaveSystem.set_current_slot(slot)
	SaveSystem.load_game()
	SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")

func _on_delete_slot(slot: int):
	"""Delete-Button für Slot gedrückt"""
	print("[SaveSlotSelect] Deleting slot %d" % slot)
	SaveSystem.delete_slot(slot)

	# Refresh UI
	get_tree().reload_current_scene()

func _on_new_game(slot: int):
	"""New-Game-Button für Slot gedrückt"""
	print("[SaveSlotSelect] Starting new game in slot %d" % slot)

	# Set active slot
	SaveSystem.set_current_slot(slot)

	# Reset Global to defaults (new game)
	_reset_to_new_game()

	# Save initial state
	SaveSystem.save_game(false)

	# Go to Level Select
	SceneLoader.load_scene("res://Scenes/LevelSelect.tscn")

func _on_back_pressed():
	"""Back Button → Main Menu"""
	print("[SaveSlotSelect] Back to main menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")

# ============================================================================
# UTILITY
# ============================================================================

func _format_save_time(time_str: String) -> String:
	"""Formatiert Save-Time für Anzeige"""
	# Format: "2024-01-15T14:30:45" → "15.01.2024 14:30"
	if time_str.is_empty() or time_str == "Unknown":
		return "Unknown"

	var parts = time_str.split("T")
	if parts.size() < 2:
		return time_str

	var date_parts = parts[0].split("-")
	var time_parts = parts[1].split(":")

	if date_parts.size() < 3 or time_parts.size() < 2:
		return time_str

	return "%s.%s.%s %s:%s" % [
		date_parts[2],  # Day
		date_parts[1],  # Month
		date_parts[0],  # Year
		time_parts[0],  # Hour
		time_parts[1]   # Minute
	]

func _reset_to_new_game():
	"""Reset Global State für New Game"""
	# Reset progression
	Global.total_highscore = 0
	Global.unlocked_levels = [1]
	Global.selected_level = 1
	Global.level_highscores = [0,0,0,0,0,0,0,0]
	Global.level_highest_combos = [0,0,0,0,0,0,0,0]
	Global.wall_hp = {1:1000, 2:3500, 3:8000, 4:15000, 5:25000, 6:40000}

	# Reset economy
	Global.coins = 0

	# Reset items
	Global.items = {}
	Global.active_items = []

	# Reset stats
	Global.total_rounds_played = 0
	Global.total_playtime = 0.0
	Global.current_round_score = 0

	# Initialize items
	for item_id in SaveSystem.ITEMS:
		var item_data = SaveSystem.ITEMS[item_id]
		Global.items[item_id] = {
			"name": item_data.name,
			"cost": item_data.cost,
			"description": item_data.description,
			"owned": false,
			"active": false
		}

	print("[SaveSlotSelect] Reset to new game state")
