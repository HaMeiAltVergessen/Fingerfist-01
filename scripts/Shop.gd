# Shop.gd - Item Shop Screen
extends Control

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var title_label: Label = $TitleLabel
@onready var coins_label: Label = $CoinsLabel
@ontml:parameter>
@onready var item_grid: GridContainer = $ItemGrid
@onready var back_button: Button = $BackButton

# ============================================================================
# STATE
# ============================================================================

var item_buttons: Array[Button] = []

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	title_label.text = "ITEM SHOP"

	# Update Coins Display
	update_coins_display()

	# Connect Back Button
	back_button.pressed.connect(_on_back_button_pressed)

	# Create Item Buttons
	create_item_buttons()

	# Connect Global Signals
	Global.coins_changed.connect(_on_coins_changed)

	print("[Shop] Ready")

# ============================================================================
# ITEM GRID
# ============================================================================

func create_item_buttons():
	"""Erstellt Item-Buttons im Grid (4 per row)"""
	# Clear existing buttons
	for child in item_grid.get_children():
		child.queue_free()

	item_buttons.clear()

	# Get all items from SaveSystem
	var items = SaveSystem.ITEMS

	# Create button for each item
	for item_id in items.keys():
		var item_data = items[item_id]
		var button = create_item_button(item_id, item_data)
		item_grid.add_child(button)
		item_buttons.append(button)

	print("[Shop] Created %d item buttons" % item_buttons.size())

func create_item_button(item_id: String, item_data: Dictionary) -> Button:
	"""Erstellt einzelnen Item-Button"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(220, 140)
	button.name = "%sButton" % item_id

	# Check if owned
	var is_owned = Global.is_item_owned(item_id)
	var can_afford = Global.coins >= item_data.cost

	# Button Text
	var button_text = "%s\n\n" % item_data.name
	button_text += "💰 %d Coins\n" % item_data.cost

	if is_owned:
		button_text += "✅ OWNED"
		button.modulate = Color(0.7, 1.0, 0.7)  # Green tint
	elif not can_afford:
		button_text += "❌ Cannot Afford"
		button.disabled = true
		button.modulate = Color(0.6, 0.6, 0.6)  # Gray
	else:
		button_text += "🛒 BUY"

	button.text = button_text

	# Connect Signal
	button.pressed.connect(_on_item_button_pressed.bind(item_id))

	return button

func update_item_buttons():
	"""Updated Item-Button-Zustände basierend auf Coins"""
	var items = SaveSystem.ITEMS

	for i in range(item_buttons.size()):
		var item_id = items.keys()[i]
		var item_data = items[item_id]
		var button = item_buttons[i]

		var is_owned = Global.is_item_owned(item_id)
		var can_afford = Global.coins >= item_data.cost

		# Update Button Text
		var button_text = "%s\n\n" % item_data.name
		button_text += "💰 %d Coins\n" % item_data.cost

		if is_owned:
			button_text += "✅ OWNED"
			button.modulate = Color(0.7, 1.0, 0.7)
			button.disabled = false
		elif not can_afford:
			button_text += "❌ Cannot Afford"
			button.disabled = true
			button.modulate = Color(0.6, 0.6, 0.6)
		else:
			button_text += "🛒 BUY"
			button.disabled = false
			button.modulate = Color.WHITE

		button.text = button_text

# ============================================================================
# COINS DISPLAY
# ============================================================================

func update_coins_display():
	"""Updated Coins-Anzeige"""
	coins_label.text = "💰 Coins: %d" % Global.coins

func _on_coins_changed(new_amount: int):
	"""Coins haben sich geändert"""
	update_coins_display()
	update_item_buttons()

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_item_button_pressed(item_id: String):
	"""Item Button geklickt"""
	var item_data = SaveSystem.ITEMS.get(item_id)

	if not item_data:
		print("[Shop] Invalid item: %s" % item_id)
		return

	# Check if already owned
	if Global.is_item_owned(item_id):
		print("[Shop] Item already owned: %s" % item_id)
		# TODO: Show "Activate/Deactivate" in C34
		return

	# Check if can afford
	if Global.coins < item_data.cost:
		print("[Shop] Cannot afford item: %s" % item_id)
		return

	# Purchase Item
	purchase_item(item_id, item_data)

func purchase_item(item_id: String, item_data: Dictionary):
	"""Kauft Item"""
	# Deduct Coins
	Global.add_coins(-item_data.cost)

	# Add to Owned Items
	Global.purchase_item(item_id)

	# Save
	SaveSystem.save_game()

	# Update Buttons
	update_item_buttons()

	print("[Shop] Purchased: %s for %d coins" % [item_data.name, item_data.cost])

func _on_back_button_pressed():
	"""Back Button geklickt"""
	print("[Shop] Back to Main Menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
