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

# Preview Panel (C46 - Item Preview)
var preview_panel: Panel
var preview_player: ColorRect  # Visual representation of player
var preview_hitbox: ColorRect  # Visual representation of punch radius
var preview_before_label: Label
var preview_after_label: Label

# Tooltip (C47 - Hover Tooltips)
var tooltip: Panel
var tooltip_title: Label
var tooltip_desc: Label
var tooltip_cost: Label

# Search and Sort (C49)
var search_field: LineEdit
var sort_cost_button: Button
var sort_name_button: Button

# ============================================================================
# STATE
# ============================================================================

var item_buttons: Array[Button] = []
var selected_item_id: String = ""
var pending_purchase_item_id: String = ""
var active_filter: String = "All"  # Current category filter
var search_query: String = ""  # C49
var current_sort: String = "cost_asc"  # C49: cost_asc, cost_desc, name_asc, name_desc

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	title_label.text = "ITEM SHOP"

	# Update Coins Display
	update_coins_display()

	# Connect Back Button
	back_button.pressed.connect(_on_back_button_pressed)

	# Create Search and Sort UI (C49)
	create_search_and_sort()

	# Create Category Filters
	create_category_filters()

	# Create Item Buttons
	create_item_buttons()

	# Create Details Panel
	create_details_panel()

	# Create Confirmation Dialog
	create_confirmation_dialog()

	# Create Preview Panel (C46)
	create_preview_panel()

	# Create Tooltip (C47)
	create_tooltip()

	# Connect Global Signals
	Global.coins_changed.connect(_on_coins_changed)

	print("[Shop] Ready")

# ============================================================================
# SEARCH AND SORT (C49)
# ============================================================================

func create_search_and_sort():
	"""Erstellt Search Field und Sort Buttons"""
	# Search Field
	search_field = LineEdit.new()
	search_field.name = "SearchField"
	search_field.placeholder_text = "Search items..."
	search_field.position = Vector2(100, 100)
	search_field.custom_minimum_size = Vector2(400, 40)
	search_field.text_changed.connect(_on_search_changed)
	add_child(search_field)

	# Sort Cost Button
	sort_cost_button = Button.new()
	sort_cost_button.name = "SortCostButton"
	sort_cost_button.text = "Sort: Cost ▼"
	sort_cost_button.position = Vector2(520, 100)
	sort_cost_button.custom_minimum_size = Vector2(140, 40)
	sort_cost_button.pressed.connect(_on_sort_cost)
	add_child(sort_cost_button)

	# Sort Name Button
	sort_name_button = Button.new()
	sort_name_button.name = "SortNameButton"
	sort_name_button.text = "Sort: Name"
	sort_name_button.position = Vector2(680, 100)
	sort_name_button.custom_minimum_size = Vector2(140, 40)
	sort_name_button.pressed.connect(_on_sort_name)
	add_child(sort_name_button)

	print("[Shop] Search and Sort UI created")

func _on_search_changed(text: String):
	"""Search text changed - filter items"""
	search_query = text.to_lower()
	create_item_buttons()  # Rebuild list

func _on_sort_cost():
	"""Toggle cost sorting"""
	if current_sort == "cost_asc":
		current_sort = "cost_desc"
		sort_cost_button.text = "Sort: Cost ▲"
	else:
		current_sort = "cost_asc"
		sort_cost_button.text = "Sort: Cost ▼"

	create_item_buttons()  # Rebuild list

func _on_sort_name():
	"""Toggle name sorting"""
	if current_sort == "name_asc":
		current_sort = "name_desc"
		sort_name_button.text = "Sort: Name ▲"
	else:
		current_sort = "name_asc"
		sort_name_button.text = "Sort: Name ▼"

	create_item_buttons()  # Rebuild list

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
	"""Erstellt Item-Buttons im Grid (4 per row) - filtered & sorted"""
	# Clear existing buttons
	for child in item_grid.get_children():
		child.queue_free()

	item_buttons.clear()

	# Get all items from SaveSystem
	var items = SaveSystem.ITEMS

	# Build filtered list
	var items_list: Array = []
	for item_id in items.keys():
		var item_data = items[item_id]

		# Category Filter
		if active_filter != "All":
			if item_data.category != active_filter:
				continue  # Skip

		# Search Filter (C49)
		if search_query != "":
			var name_match = item_data.name.to_lower().contains(search_query)
			var desc_match = item_data.description.to_lower().contains(search_query)
			if not (name_match or desc_match):
				continue  # Skip

		items_list.append({"id": item_id, "data": item_data})

	# Sort list (C49)
	items_list = _sort_items(items_list)

	# Create buttons
	for entry in items_list:
		var button = create_item_button(entry.id, entry.data)
		item_grid.add_child(button)
		item_buttons.append(button)

	print("[Shop] Created %d item buttons (filter: %s, sort: %s)" % [
		item_buttons.size(), active_filter, current_sort
	])

func _sort_items(items: Array) -> Array:
	"""Sort items based on current_sort setting"""
	match current_sort:
		"cost_asc":
			items.sort_custom(func(a, b): return a.data.cost < b.data.cost)
		"cost_desc":
			items.sort_custom(func(a, b): return a.data.cost > b.data.cost)
		"name_asc":
			items.sort_custom(func(a, b): return a.data.name < b.data.name)
		"name_desc":
			items.sort_custom(func(a, b): return a.data.name > b.data.name)

	return items

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

	# Connect Signals
	button.pressed.connect(_on_item_button_pressed.bind(item_id))
	button.mouse_entered.connect(_on_item_hover.bind(item_id))  # C47
	button.mouse_exited.connect(_on_item_hover_end)  # C47

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

	# Show Preview (C46)
	show_item_preview(item_id)

	print("[Shop] Showing details for: %s" % item_id)

func hide_item_details():
	"""Versteckt Item-Details-Panel"""
	details_panel.visible = false
	preview_panel.visible = false
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

# ============================================================================
# PREVIEW PANEL (C46)
# ============================================================================

func create_preview_panel():
	"""Erstellt Item-Preview-Panel mit Stat-Vergleich"""
	# Main Panel
	preview_panel = Panel.new()
	preview_panel.name = "PreviewPanel"
	preview_panel.visible = false
	preview_panel.custom_minimum_size = Vector2(360, 400)
	preview_panel.position = Vector2(820, 220)
	add_child(preview_panel)

	# Title
	var title = Label.new()
	title.text = "ITEM PREVIEW"
	title.position = Vector2(100, 10)
	title.add_theme_font_size_override("font_size", 20)
	preview_panel.add_child(title)

	# Player Visual (static position)
	preview_player = ColorRect.new()
	preview_player.name = "PreviewPlayer"
	preview_player.color = Color(0.3, 0.8, 1.0)  # Blue for player
	preview_player.custom_minimum_size = Vector2(20, 40)
	preview_player.position = Vector2(170, 130)
	preview_panel.add_child(preview_player)

	# Punch Hitbox Visual
	preview_hitbox = ColorRect.new()
	preview_hitbox.name = "PreviewHitbox"
	preview_hitbox.color = Color(0.3, 1.0, 0.3, 0.3)  # Semi-transparent green
	preview_hitbox.custom_minimum_size = Vector2(64, 64)  # Default 32px radius = 64px diameter
	preview_hitbox.position = Vector2(180 - 32, 150 - 32)  # Centered on player
	preview_panel.add_child(preview_hitbox)

	# Before Stats Label
	preview_before_label = Label.new()
	preview_before_label.name = "BeforeLabel"
	preview_before_label.position = Vector2(20, 220)
	preview_before_label.custom_minimum_size = Vector2(150, 150)
	preview_before_label.add_theme_font_size_override("font_size", 14)
	preview_before_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	preview_panel.add_child(preview_before_label)

	# After Stats Label
	preview_after_label = Label.new()
	preview_after_label.name = "AfterLabel"
	preview_after_label.position = Vector2(190, 220)
	preview_after_label.custom_minimum_size = Vector2(150, 150)
	preview_after_label.add_theme_font_size_override("font_size", 14)
	preview_after_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))  # Green for after
	preview_panel.add_child(preview_after_label)

	print("[Shop] Preview Panel created")

func show_item_preview(item_id: String):
	"""Zeigt Item-Preview mit Before/After Stats"""
	# Only show preview for items with visual effects
	if not _has_visual_preview(item_id):
		preview_panel.visible = false
		return

	# Calculate stats
	var before_stats = _calculate_current_stats()
	var after_stats = _calculate_stats_with_item(item_id)

	# Update visual preview
	_update_preview_visuals(after_stats)

	# Update stat labels
	preview_before_label.text = _format_stats_text("CURRENT", before_stats)
	preview_after_label.text = _format_stats_text("WITH ITEM", after_stats)

	# Show panel
	preview_panel.visible = true

	print("[Shop] Showing preview for: %s" % item_id)

func _has_visual_preview(item_id: String) -> bool:
	"""Check if item has a visual preview"""
	return item_id in ["shockwave_fist", "iron_knuckles", "fire_shield", "greed_magnet"]

func _calculate_current_stats() -> Dictionary:
	"""Calculate current player stats based on owned items"""
	var radius = 32.0
	var knockback = false
	var shield = 0
	var magnet = 0.0

	# Check all owned items
	for item_id in Global.items:
		var item = Global.items[item_id]
		if not item.owned:
			continue

		match item_id:
			"shockwave_fist":
				radius = 32.0 * 2.0  # Doubles radius
			"iron_knuckles":
				knockback = true
			"fire_shield":
				shield = 1  # 1 projectile negation per round
			"greed_magnet":
				magnet = 200.0

	return {
		"punch_radius": radius,
		"has_knockback": knockback,
		"shield_charges": shield,
		"magnet_radius": magnet,
	}

func _calculate_stats_with_item(item_id: String) -> Dictionary:
	"""Calculate stats if item was owned"""
	var stats = _calculate_current_stats()

	match item_id:
		"shockwave_fist":
			stats.punch_radius = 32.0 * 2.0  # Doubles from 32 to 64
		"iron_knuckles":
			stats.has_knockback = true
		"fire_shield":
			stats.shield_charges = 1
		"greed_magnet":
			stats.magnet_radius = 200.0

	return stats

func _update_preview_visuals(stats: Dictionary):
	"""Update preview visual elements"""
	# Update hitbox size based on punch radius
	var radius = stats.punch_radius
	var diameter = radius * 2

	preview_hitbox.custom_minimum_size = Vector2(diameter, diameter)
	preview_hitbox.position = Vector2(180 - radius, 150 - radius)

	# Change color if knockback
	if stats.has_knockback:
		preview_hitbox.color = Color(1.0, 0.5, 0.3, 0.3)  # Orange for knockback
	else:
		preview_hitbox.color = Color(0.3, 1.0, 0.3, 0.3)  # Green default

func _format_stats_text(title: String, stats: Dictionary) -> String:
	"""Format stats into readable text"""
	var text = "%s:\n\n" % title
	text += "Punch Radius:\n%.0fpx\n\n" % stats.punch_radius

	if stats.has_knockback:
		text += "Knockback: ✓\n"
	else:
		text += "Knockback: ✗\n"

	if stats.shield_charges > 0:
		text += "Shield: %d\n" % stats.shield_charges
	else:
		text += "Shield: ✗\n"

	if stats.magnet_radius > 0:
		text += "Magnet: %.0fpx" % stats.magnet_radius
	else:
		text += "Magnet: ✗"

	return text

# ============================================================================
# TOOLTIP (C47)
# ============================================================================

func create_tooltip():
	"""Erstellt Hover-Tooltip für Items"""
	# Main Panel
	tooltip = Panel.new()
	tooltip.name = "Tooltip"
	tooltip.visible = false
	tooltip.custom_minimum_size = Vector2(250, 140)
	tooltip.z_index = 100  # Always on top
	add_child(tooltip)

	# Title
	tooltip_title = Label.new()
	tooltip_title.name = "TooltipTitle"
	tooltip_title.position = Vector2(10, 10)
	tooltip_title.add_theme_font_size_override("font_size", 18)
	tooltip_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # Gold
	tooltip.add_child(tooltip_title)

	# Description
	tooltip_desc = Label.new()
	tooltip_desc.name = "TooltipDesc"
	tooltip_desc.position = Vector2(10, 40)
	tooltip_desc.custom_minimum_size = Vector2(230, 60)
	tooltip_desc.add_theme_font_size_override("font_size", 12)
	tooltip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip.add_child(tooltip_desc)

	# Cost
	tooltip_cost = Label.new()
	tooltip_cost.name = "TooltipCost"
	tooltip_cost.position = Vector2(10, 110)
	tooltip_cost.add_theme_font_size_override("font_size", 14)
	tooltip.add_child(tooltip_cost)

	print("[Shop] Tooltip created")

func _on_item_hover(item_id: String):
	"""Item Button hover - zeige Tooltip"""
	var item_data = SaveSystem.ITEMS.get(item_id)
	if not item_data:
		return

	tooltip_title.text = item_data.name
	tooltip_desc.text = item_data.description

	var is_owned = Global.is_item_owned(item_id)

	if is_owned:
		tooltip_cost.text = "✅ OWNED"
		tooltip_cost.modulate = Color(0.5, 1.0, 0.5)
	else:
		tooltip_cost.text = "💰 %d coins" % item_data.cost
		var can_afford = Global.coins >= item_data.cost
		tooltip_cost.modulate = Color(0.3, 1.0, 0.3) if can_afford else Color(1.0, 0.3, 0.3)

	# Position tooltip at mouse cursor
	tooltip.position = get_viewport().get_mouse_position() + Vector2(10, 10)
	tooltip.visible = true

func _on_item_hover_end():
	"""Item hover ended - hide tooltip"""
	tooltip.visible = false

func _process(delta: float):
	"""Update tooltip position to follow mouse"""
	if tooltip.visible:
		tooltip.position = get_viewport().get_mouse_position() + Vector2(10, 10)

func show_purchase_confirmation(item_id: String):
	"""Zeigt Purchase-Confirmation-Dialog"""
	var item_data = SaveSystem.ITEMS.get(item_id)
	if not item_data:
		return

	pending_purchase_item_id = item_id

	# Update Message
	confirm_message.text = "Purchase '%s' for %d coins?\n\nYou will have %d coins remaining." % [
		item_data.name,
		item_data.cost,
		Global.coins - item_data.cost
	]

	# Dim background (C48)
	details_panel.modulate.a = 0.5
	item_grid.modulate.a = 0.5
	filter_container.modulate.a = 0.5

	# Show Dialog
	confirm_dialog.visible = true

	print("[Shop] Showing purchase confirmation for: %s" % item_id)

func hide_purchase_confirmation():
	"""Versteckt Purchase-Confirmation-Dialog"""
	confirm_dialog.visible = false
	pending_purchase_item_id = ""

	# Restore background (C48)
	details_panel.modulate.a = 1.0
	item_grid.modulate.a = 1.0
	filter_container.modulate.a = 1.0

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

	# Auto-Save after purchase (C48)
	Global.trigger_auto_save()

	# Update Buttons
	update_item_buttons()

	print("[Shop] Purchased: %s for %d coins" % [item_data.name, item_data.cost])

func _on_back_button_pressed():
	"""Back Button geklickt"""
	print("[Shop] Back to Main Menu")
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
