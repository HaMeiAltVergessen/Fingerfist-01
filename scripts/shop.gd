# Shop.gd - Item Shop Screen
extends Control

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var title_label: Label = $TitleLabel
@onready var coins_label: Label = $CoinsLabel
@onready var item_grid: GridContainer = $ItemGrid
@onready var back_button: Button = $BackButton

# Details Panel (created dynamically)
var details_panel: Panel
var details_title: Label
var details_description: Label
var details_cost: Label
var details_status: Label
var details_action_button: Button
var details_close_button: Button

# Confirmation Dialog (created dynamically)
var confirm_dialog: Panel
var confirm_title: Label
var confirm_message: Label
var confirm_yes_button: Button
var confirm_no_button: Button

# Filter Buttons (created dynamically)
var filter_container: HBoxContainer
var filter_buttons: Dictionary = {}

# ============================================================================
# STATE
# ============================================================================

var item_buttons: Array[Button] = []
var selected_item_id: String = ""
var pending_purchase_item_id: String = ""
var active_filter: String = "All"  # Current category filter

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	title_label.text = "ITEM SHOP"

	# Update Coins Display
	update_coins_display()

	# Connect Back Button
	back_button.pressed.connect(_on_back_button_pressed)

	# Create Category Filters
	create_category_filters()

	# Create Item Buttons
	create_item_buttons()

	# Create Details Panel
	create_details_panel()

	# Create Confirmation Dialog
	create_confirmation_dialog()

	# Connect Global Signals
	Global.coins_changed.connect(_on_coins_changed)

	print("[Shop] Ready")

# ============================================================================
# CATEGORY FILTERS
# ============================================================================

func create_category_filters():
	"""Erstellt Category-Filter-Buttons"""
	filter_container = HBoxContainer.new()
	filter_container.name = "FilterContainer"
	filter_container.position = Vector2(100, 150)
	add_child(filter_container)

	# Categories: All, Combat, Defense, Economy, Utility, Ultimate
	var categories = ["All", "Combat", "Defense", "Economy", "Utility", "Ultimate"]

	for category in categories:
		var button = Button.new()
		button.text = category
		button.custom_minimum_size = Vector2(100, 40)
		button.name = "%sFilterButton" % category
		button.pressed.connect(_on_filter_button_pressed.bind(category))
		filter_container.add_child(button)
		filter_buttons[category] = button

	# Set initial filter (All)
	update_filter_buttons()

	print("[Shop] Category filters created")

func _on_filter_button_pressed(category: String):
	"""Filter Button geklickt"""
	active_filter = category
	update_filter_buttons()
	create_item_buttons()  # Rebuild item grid

func update_filter_buttons():
	"""Updated Filter-Button-Zustände"""
	for category in filter_buttons:
		var button = filter_buttons[category]
		if category == active_filter:
			button.modulate = Color(0.5, 1.0, 0.5)  # Green (active)
			button.disabled = true
		else:
			button.modulate = Color.WHITE
			button.disabled = false

# ============================================================================
# ITEM GRID
# ============================================================================

func create_item_buttons():
	"""Erstellt Item-Buttons im Grid (4 per row) - filtered by category"""
	# Clear existing buttons
	for child in item_grid.get_children():
		child.queue_free()

	item_buttons.clear()

	# Get all items from SaveSystem
	var items = SaveSystem.ITEMS

	# Create button for each item (filtered)
	for item_id in items.keys():
		var item_data = items[item_id]

		# Check if item matches active filter
		if active_filter != "All":
			if item_data.category != active_filter:
				continue  # Skip this item

		var button = create_item_button(item_id, item_data)
		item_grid.add_child(button)
		item_buttons.append(button)

	print("[Shop] Created %d item buttons (filter: %s)" % [item_buttons.size(), active_filter])

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
# DETAILS PANEL
# ============================================================================

func create_details_panel():
	"""Erstellt Item-Details-Panel (dynamisch)"""
	# Main Panel
	details_panel = Panel.new()
	details_panel.name = "DetailsPanel"
	details_panel.visible = false
	details_panel.custom_minimum_size = Vector2(500, 450)
	details_panel.position = Vector2(290, 135)  # Center
	add_child(details_panel)

	# Title Label
	details_title = Label.new()
	details_title.name = "DetailTitle"
	details_title.position = Vector2(20, 20)
	details_title.add_theme_font_size_override("font_size", 24)
	details_panel.add_child(details_title)

	# Description Label
	details_description = Label.new()
	details_description.name = "DetailDescription"
	details_description.position = Vector2(20, 80)
	details_description.custom_minimum_size = Vector2(460, 150)
	details_description.add_theme_font_size_override("font_size", 16)
	details_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_panel.add_child(details_description)

	# Cost Label
	details_cost = Label.new()
	details_cost.name = "DetailCost"
	details_cost.position = Vector2(20, 250)
	details_cost.add_theme_font_size_override("font_size", 20)
	details_panel.add_child(details_cost)

	# Status Label
	details_status = Label.new()
	details_status.name = "DetailStatus"
	details_status.position = Vector2(20, 290)
	details_status.add_theme_font_size_override("font_size", 18)
	details_panel.add_child(details_status)

	# Action Button (BUY or ACTIVATE/DEACTIVATE)
	details_action_button = Button.new()
	details_action_button.name = "DetailActionButton"
	details_action_button.position = Vector2(50, 350)
	details_action_button.custom_minimum_size = Vector2(180, 60)
	details_action_button.pressed.connect(_on_detail_action_button_pressed)
	details_panel.add_child(details_action_button)

	# Close Button
	details_close_button = Button.new()
	details_close_button.name = "DetailCloseButton"
	details_close_button.text = "BACK"
	details_close_button.position = Vector2(270, 350)
	details_close_button.custom_minimum_size = Vector2(180, 60)
	details_close_button.pressed.connect(_on_detail_close_button_pressed)
	details_panel.add_child(details_close_button)

	print("[Shop] Details Panel created")

func show_item_details(item_id: String):
	"""Zeigt Item-Details-Panel"""
	var item_data = SaveSystem.ITEMS.get(item_id)
	if not item_data:
		return

	selected_item_id = item_id

	# Update Title
	details_title.text = item_data.name

	# Update Description
	details_description.text = item_data.description

	# Update Cost
	details_cost.text = "💰 Cost: %d Coins" % item_data.cost

	# Update Status & Action Button
	var is_owned = Global.is_item_owned(item_id)
	var is_active = Global.is_item_active(item_id)

	if is_owned:
		details_status.text = "✅ Status: OWNED"
		details_status.modulate = Color(0.3, 1.0, 0.3)

		if is_active:
			details_action_button.text = "DEACTIVATE"
			details_action_button.modulate = Color(1.0, 0.5, 0.5)
		else:
			details_action_button.text = "ACTIVATE"
			details_action_button.modulate = Color(0.5, 1.0, 0.5)

		details_action_button.disabled = false
	else:
		var can_afford = Global.coins >= item_data.cost

		if can_afford:
			details_status.text = "❓ Status: Not Owned"
			details_status.modulate = Color(1.0, 1.0, 1.0)
			details_action_button.text = "BUY NOW"
			details_action_button.modulate = Color(1.0, 0.84, 0.0)  # Gold
			details_action_button.disabled = false
		else:
			details_status.text = "❌ Status: Cannot Afford"
			details_status.modulate = Color(1.0, 0.3, 0.3)
			details_action_button.text = "BUY NOW"
			details_action_button.modulate = Color(0.5, 0.5, 0.5)
			details_action_button.disabled = true

	# Show Panel
	details_panel.visible = true

	print("[Shop] Showing details for: %s" % item_id)

func hide_item_details():
	"""Versteckt Item-Details-Panel"""
	details_panel.visible = false
	selected_item_id = ""

# ============================================================================
# CONFIRMATION DIALOG
# ============================================================================

func create_confirmation_dialog():
	"""Erstellt Purchase-Confirmation-Dialog (dynamisch)"""
	# Main Panel
	confirm_dialog = Panel.new()
	confirm_dialog.name = "ConfirmDialog"
	confirm_dialog.visible = false
	confirm_dialog.custom_minimum_size = Vector2(400, 250)
	confirm_dialog.position = Vector2(340, 235)  # Center
	add_child(confirm_dialog)

	# Title Label
	confirm_title = Label.new()
	confirm_title.name = "ConfirmTitle"
	confirm_title.text = "CONFIRM PURCHASE"
	confirm_title.position = Vector2(20, 20)
	confirm_title.add_theme_font_size_override("font_size", 22)
	confirm_dialog.add_child(confirm_title)

	# Message Label
	confirm_message = Label.new()
	confirm_message.name = "ConfirmMessage"
	confirm_message.position = Vector2(20, 80)
	confirm_message.custom_minimum_size = Vector2(360, 80)
	confirm_message.add_theme_font_size_override("font_size", 16)
	confirm_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirm_dialog.add_child(confirm_message)

	# Yes Button
	confirm_yes_button = Button.new()
	confirm_yes_button.name = "ConfirmYesButton"
	confirm_yes_button.text = "YES, BUY IT"
	confirm_yes_button.position = Vector2(30, 170)
	confirm_yes_button.custom_minimum_size = Vector2(150, 50)
	confirm_yes_button.modulate = Color(0.5, 1.0, 0.5)
	confirm_yes_button.pressed.connect(_on_confirm_yes_button_pressed)
	confirm_dialog.add_child(confirm_yes_button)

	# No Button
	confirm_no_button = Button.new()
	confirm_no_button.name = "ConfirmNoButton"
	confirm_no_button.text = "CANCEL"
	confirm_no_button.position = Vector2(220, 170)
	confirm_no_button.custom_minimum_size = Vector2(150, 50)
	confirm_no_button.modulate = Color(1.0, 0.5, 0.5)
	confirm_no_button.pressed.connect(_on_confirm_no_button_pressed)
	confirm_dialog.add_child(confirm_no_button)

	print("[Shop] Confirmation Dialog created")

func show_purchase_confirmation(item_id: String):
	"""Zeigt Purchase-Confirmation-Dialog"""
	var item_data = SaveSystem.ITEMS.get(item_id)
	if not item_data:
		return

	pending_purchase_item_id = item_id

	# Update Message
	confirm_message.text = "Purchase '%s' for %d coins?\n\nYou currently have %d coins." % [
		item_data.name,
		item_data.cost,
		Global.coins
	]

	# Show Dialog
	confirm_dialog.visible = true

	print("[Shop] Showing purchase confirmation for: %s" % item_id)

func hide_purchase_confirmation():
	"""Versteckt Purchase-Confirmation-Dialog"""
	confirm_dialog.visible = false
	pending_purchase_item_id = ""

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
	"""Item Button geklickt - Zeigt Details"""
	# Show Details Panel
	show_item_details(item_id)

func _on_detail_action_button_pressed():
	"""Action Button im Details-Panel geklickt"""
	var item_data = SaveSystem.ITEMS.get(selected_item_id)
	if not item_data:
		return

	var is_owned = Global.is_item_owned(selected_item_id)

	if is_owned:
		# Toggle Activate/Deactivate
		var is_active = Global.is_item_active(selected_item_id)

		if is_active:
			Global.deactivate_item(selected_item_id)
			print("[Shop] Deactivated: %s" % item_data.name)
		else:
			Global.activate_item(selected_item_id)
			print("[Shop] Activated: %s" % item_data.name)

		# Save
		SaveSystem.save_game()

		# Refresh Details
		show_item_details(selected_item_id)
	else:
		# Show Purchase Confirmation
		hide_item_details()
		show_purchase_confirmation(selected_item_id)

func _on_detail_close_button_pressed():
	"""Close Button im Details-Panel geklickt"""
	hide_item_details()

func _on_confirm_yes_button_pressed():
	"""Yes Button im Confirmation-Dialog geklickt"""
	var item_data = SaveSystem.ITEMS.get(pending_purchase_item_id)
	if not item_data:
		return

	# Check if can still afford (in case coins changed)
	if Global.coins < item_data.cost:
		print("[Shop] Cannot afford item anymore: %s" % pending_purchase_item_id)
		hide_purchase_confirmation()
		return

	# Purchase Item
	purchase_item(pending_purchase_item_id, item_data)

	# Hide Confirmation
	hide_purchase_confirmation()

func _on_confirm_no_button_pressed():
	"""No Button im Confirmation-Dialog geklickt"""
	hide_purchase_confirmation()

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
