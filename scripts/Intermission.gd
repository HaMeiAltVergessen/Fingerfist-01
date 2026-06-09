# Intermission.gd - Kurze 5-Sekunden-Pause zwischen Mini-Runden
#
# Wird von game.gd dynamisch instanziiert (wie SaveIndicator). Läuft dank
# process_mode = ALWAYS trotz get_tree().paused weiter und zählt einen eigenen
# Countdown herunter. In der Pause kann der Spieler Items aktivieren UND kurz
# einkaufen (In-Game-Shop-Overlay). Bei Ablauf (hart) oder "WEITER" wird das
# Signal `finished` emittiert; game.gd setzt dann die nächste Mini-Runde fort.
extends CanvasLayer

# ============================================================================
# SIGNALS
# ============================================================================

signal finished

# ============================================================================
# STATE
# ============================================================================

var time_left: float = 0.0
var is_active: bool = false

# True, sobald in dieser Pause ein Item (de)aktiviert oder gekauft wurde.
# game.gd re-applied Item-Effekte nur dann (vermeidet Heal-on-Pause via golem_skin).
var selection_changed: bool = false

var showing_shop: bool = false

# ============================================================================
# NODE REFERENCES (dynamisch erstellt)
# ============================================================================

var dimmer: ColorRect
var panel: Panel
var countdown_label: Label
var section_header: Label
var items_container: VBoxContainer
var shop_left: VBoxContainer
var shop_right: VBoxContainer
var shop_toggle_button: Button
var continue_button: Button

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Muss trotz get_tree().paused laufen (Countdown + Buttons), analog EndScreen.
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 50  # über HUD/PauseScreen
	visible = false
	_build_ui()

func _build_ui():
	# Abdunkelung über dem ganzen Screen
	dimmer = ColorRect.new()
	dimmer.color = Color(0.0, 0.0, 0.0, 0.6)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dimmer)

	# Zentrales Panel (großzügig: Platz für zweispaltigen Shop)
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(1120, 620)
	panel.size = Vector2(1120, 620)
	panel.position = Vector2(80, 50)
	add_child(panel)

	var title = Label.new()
	title.text = "BREAK"
	title.position = Vector2(32, 20)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	panel.add_child(title)

	countdown_label = Label.new()
	countdown_label.position = Vector2(1010, 18)
	countdown_label.add_theme_font_size_override("font_size", 48)
	panel.add_child(countdown_label)

	section_header = Label.new()
	section_header.text = "Activate items for the next wave"
	section_header.position = Vector2(32, 82)
	section_header.add_theme_font_size_override("font_size", 18)
	panel.add_child(section_header)

	# Item-Aktivierungsliste (eine Spalte über volle Breite)
	items_container = VBoxContainer.new()
	items_container.position = Vector2(32, 122)
	items_container.custom_minimum_size = Vector2(1056, 380)
	panel.add_child(items_container)

	# Kompakte Kaufliste (Shop) - zwei Spalten nebeneinander, versteckt
	shop_left = VBoxContainer.new()
	shop_left.position = Vector2(32, 122)
	shop_left.custom_minimum_size = Vector2(512, 380)
	shop_left.visible = false
	panel.add_child(shop_left)

	shop_right = VBoxContainer.new()
	shop_right.position = Vector2(576, 122)
	shop_right.custom_minimum_size = Vector2(512, 380)
	shop_right.visible = false
	panel.add_child(shop_right)

	# SHOP-Toggle
	shop_toggle_button = Button.new()
	shop_toggle_button.text = "SHOP"
	shop_toggle_button.position = Vector2(32, 540)
	shop_toggle_button.custom_minimum_size = Vector2(500, 60)
	shop_toggle_button.pressed.connect(_on_shop_toggle_pressed)
	panel.add_child(shop_toggle_button)

	# WEITER (frühzeitig fortsetzen)
	continue_button = Button.new()
	continue_button.text = "CONTINUE ▶"
	continue_button.position = Vector2(588, 540)
	continue_button.custom_minimum_size = Vector2(500, 60)
	continue_button.modulate = Color(0.5, 1.0, 0.5)
	continue_button.pressed.connect(_on_continue_pressed)
	panel.add_child(continue_button)

# ============================================================================
# PUBLIC API
# ============================================================================

func start(seconds: float):
	"""Startet die Pause mit gegebenem Countdown."""
	time_left = seconds
	is_active = true
	selection_changed = false
	showing_shop = false
	_show_items_view()
	_render_item_toggles()
	visible = true
	_update_countdown_label()

# ============================================================================
# COUNTDOWN
# ============================================================================

func _process(delta: float):
	if not is_active:
		return

	time_left -= delta
	_update_countdown_label()

	if time_left <= 0.0:
		_finish()

func _update_countdown_label():
	if not countdown_label:
		return
	var s := int(ceil(max(0.0, time_left)))
	countdown_label.text = "%d" % s
	countdown_label.modulate = Color(1.0, 0.3, 0.3) if s <= 2 else Color(1.0, 1.0, 1.0)

func _finish():
	is_active = false
	visible = false
	finished.emit()

# ============================================================================
# VIEW SWITCHING
# ============================================================================

func _on_continue_pressed():
	_finish()

func _on_shop_toggle_pressed():
	showing_shop = !showing_shop
	if showing_shop:
		_show_shop_view()
	else:
		_show_items_view()

func _show_items_view():
	showing_shop = false
	section_header.text = "Activate items for the next wave"
	items_container.visible = true
	shop_left.visible = false
	shop_right.visible = false
	shop_toggle_button.text = "SHOP"
	_render_item_toggles()

func _show_shop_view():
	showing_shop = true
	section_header.text = "Quick Shop — Coins: %d" % Global.coins
	items_container.visible = false
	shop_left.visible = true
	shop_right.visible = true
	shop_toggle_button.text = "◀ BACK"
	_render_shop_list()

# ============================================================================
# ITEM ACTIVATION LIST
# ============================================================================

func _render_item_toggles():
	"""Baut die Item-Toggle-Buttons (nur besessene Items) neu auf."""
	for child in items_container.get_children():
		child.queue_free()

	var any_owned := false
	for item_id in SaveSystem.ITEMS.keys():
		if not Global.is_item_owned(item_id):
			continue
		any_owned = true
		var item_data = SaveSystem.ITEMS[item_id]

		var button = Button.new()
		button.custom_minimum_size = Vector2(512, 34)
		button.pressed.connect(_on_item_toggle_pressed.bind(item_id))
		items_container.add_child(button)
		_update_item_toggle(button, item_id, item_data)

	if not any_owned:
		var hint = Label.new()
		hint.text = "No items owned — tap SHOP to buy."
		hint.add_theme_font_size_override("font_size", 15)
		items_container.add_child(hint)

func _update_item_toggle(button: Button, item_id: String, item_data: Dictionary):
	if Global.is_item_active(item_id):
		button.text = "%s - ACTIVE" % item_data.name
		button.modulate = Color(0.5, 1.0, 0.5)
	else:
		button.text = "%s - inactive" % item_data.name
		button.modulate = Color.WHITE

func _on_item_toggle_pressed(item_id: String):
	if Global.is_item_active(item_id):
		Global.deactivate_item(item_id)
	else:
		Global.activate_item(item_id)

	selection_changed = true
	SaveSystem.save_game()
	_render_item_toggles()

# ============================================================================
# QUICK SHOP LIST
# ============================================================================

func _render_shop_list():
	"""Kaufliste in zwei Spalten: noch nicht besessene Items mit Kosten + BUY."""
	for child in shop_left.get_children():
		child.queue_free()
	for child in shop_right.get_children():
		child.queue_free()

	var col_index := 0
	for item_id in SaveSystem.ITEMS.keys():
		if Global.is_item_owned(item_id):
			continue
		var item_data = SaveSystem.ITEMS[item_id]
		var can_afford = Global.coins >= item_data.cost

		var button = Button.new()
		button.custom_minimum_size = Vector2(508, 46)
		button.text = "%s — %d Coins" % [item_data.name, item_data.cost]
		button.disabled = not can_afford
		button.modulate = Color.WHITE if can_afford else Color(0.6, 0.6, 0.6)

		# Passendes Item-Icon links vor den Text (auf Buttonhöhe begrenzt)
		var icon_path := "res://assets/sprites/ui/items/%s.png" % item_id
		if ResourceLoader.exists(icon_path):
			button.icon = load(icon_path)
			button.add_theme_constant_override("icon_max_width", 36)

		button.pressed.connect(_on_buy_pressed.bind(item_id))
		# Abwechselnd auf linke/rechte Spalte verteilen
		if col_index % 2 == 0:
			shop_left.add_child(button)
		else:
			shop_right.add_child(button)
		col_index += 1

	if col_index == 0:
		var hint = Label.new()
		hint.text = "All items owned."
		hint.add_theme_font_size_override("font_size", 16)
		shop_left.add_child(hint)

func _on_buy_pressed(item_id: String):
	if Global.buy_item(item_id):
		selection_changed = true
		SaveSystem.save_game()
	# Coins/Status neu darstellen
	section_header.text = "Quick Shop — Coins: %d" % Global.coins
	_render_shop_list()
