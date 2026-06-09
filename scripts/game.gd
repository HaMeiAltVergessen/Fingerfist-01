# game.gd - GameScene Orchestrierung
extends Node2D

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var background: Sprite2D = $Background
@onready var player: Player = $Player
@onready var enemy_spawner: Node2D = $Spawners/EnemySpawner
@onready var coin_spawner: Node2D = $Spawners/CoinSpawner
@onready var camera: GameCamera = $GameCamera
@onready var hud: CanvasLayer = $HUDLayer
@onready var wall: Wall = $Wall
@onready var end_screen: CanvasLayer = $EndScreen
@onready var pause_screen: CanvasLayer = $PauseScreen

# Dynamic UI
var save_indicator: CanvasLayer
var intermission: CanvasLayer

# ============================================================================
# STATE
# ============================================================================

var is_round_active: bool = false
var is_paused: bool = false
var total_highscore_before_round: int = 0

# Letzter verarbeiteter Rundenscore - für inkrementellen Wall-Schaden (Delta pro Score-Tick)
var _last_round_score: int = 0

# Rundenscore, gesichert vor Global.end_round() (das current_round_score nullt) - für EndScreen
var _final_round_score: int = 0

# Runden-OSTs - bei jedem Rundenstart wird zufällig einer gespielt
const ROUND_OSTS := [
	"Fingerfist Ost 1.mp3",
	"Fingerfist Ost 2.mp3",
	"Fingerfist Ost 10.mp3",
	"Fingerfist Ost 11.mp3",
	"Fingerfist Ost 12.mp3",
]

# Mini-Runden-System: jedes Level besteht aus MINI_COUNT Mini-Runden, deren
# Zufallsdauern zusammen TOTAL_MIN..TOTAL_MAX Sekunden ergeben. Zwischen den
# Mini-Runden eine kurze Intermission-Pause. Endless (Level 7) hat keinen
# Rundentimer, sondern alle ENDLESS_PAUSE_INTERVAL Sekunden eine Pause.
const MINI_COUNT: int = 3
const TOTAL_MIN: float = 45.0
const TOTAL_MAX: float = 60.0
const MINI_MIN: float = 8.0
const INTERMISSION_SECONDS: float = 5.0
const ENDLESS_PAUSE_INTERVAL: float = 60.0

var mini_durations: Array[float] = []
var current_mini: int = 0
var round_time_left: float = 0.0
var in_intermission: bool = false
var endless_elapsed: float = 0.0
var endless_next_pause: float = ENDLESS_PAUSE_INTERVAL

# Round Stats Tracking
var coins_at_round_start: int = 0
var round_start_time: float = 0.0
var enemies_killed_this_round: int = 0
var is_new_highscore: bool = false
var player_died: bool = false
var round_won: bool = false

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create Save Indicator
	var indicator_script = preload("res://scripts/SaveIndicator.gd")
	save_indicator = CanvasLayer.new()
	save_indicator.set_script(indicator_script)
	add_child(save_indicator)

	# Create Intermission Overlay (Pause zwischen Mini-Runden)
	var intermission_script = preload("res://scripts/Intermission.gd")
	intermission = CanvasLayer.new()
	intermission.set_script(intermission_script)
	add_child(intermission)
	intermission.finished.connect(_on_intermission_finished)

	# Hide Screens initially
	end_screen.visible = false
	pause_screen.visible = false

	# Setup Background (per Level)
	setup_background()

	# Setup Player (STATIC position)
	setup_player()

	# Setup based on selected level
	var level = Global.selected_level
	if level == 7:
		setup_endless_mode()
	else:
		setup_wall(level)

	# Connect Player Signals
	player.died.connect(_on_player_died)
	player.hit_enemy.connect(_on_player_hit_enemy)
	player.combo_increased.connect(_on_combo_increased)
	player.took_damage.connect(_on_player_took_damage)

	# Connect Global Signals
	Global.score_changed.connect(_on_score_changed)

	# Start Round
	start_round()

	print("[GameScene] Ready - Level: ", level)

# ============================================================================
# BACKGROUND SETUP
# ============================================================================

func setup_background():
	"""Lädt das Background-Sprite für das gewählte Level und streckt es auf Vollbild."""
	if not background:
		return

	var level = clamp(Global.selected_level, 1, 7)

	# Nummerierte Backgrounds: Background1 → Level 1 … Background7 → Level 7
	# (visualisiert den "Aufstieg aus der Höhle" über die Level hinweg).
	var bg_path := "res://assets/Placeholder/AIPlaceholder/Background%d.png" % level
	var tex = load(bg_path)
	if not tex:
		print("[GameScene] Background für Level %d nicht gefunden" % level)
		return

	background.texture = tex

	# Auf Viewport (1280×720) strecken - dynamisch, falls echte Backgrounds andere Maße haben
	var tw = tex.get_width()
	var th = tex.get_height()
	if tw > 0 and th > 0:
		background.scale = Vector2(1280.0 / tw, 720.0 / th)

	print("[GameScene] Background gesetzt für Level %d" % level)

# ============================================================================
# PLAYER SETUP
# ============================================================================

func setup_player():
	"""Setup Player (statisch!)"""
	if not player:
		return

	# Position wird im jeweiligen Level{N}.tscn im Editor festgelegt; den Fallback
	# (falls der Node auf 0/0 steht) übernimmt Player.gd._ready() vor diesem Aufruf.

	# Apply Items (falls gekauft)
	player.apply_item_effects()

	print("[GameScene] Player setup - Position: ", player.position)

# ============================================================================
# WALL SETUP
# ============================================================================

func setup_wall(level: int):
	"""Setzt Wand-HP basierend auf Level und Total Highscore"""
	# Wand-Sprite anzeigen
	wall.visible = true
	wall.position = Vector2(48, 360)  # Links im Screen

	# Setup Wall (new Wall class handles HP)
	wall.setup(level)

	# Connect Wall Signals
	wall.wall_destroyed.connect(_on_wall_destroyed)
	wall.hp_changed.connect(_on_wall_hp_changed)

	# Check Golem's Blessing Item
	if Global.is_item_active("golem_blessing"):
		wall.enable_regeneration()

	print("[GameScene] Wall setup for Level %d" % level)

func setup_endless_mode():
	"""Endless Mode (Level 7) - keine Wand"""
	wall.visible = false
	print("[GameScene] Endless Mode - No Wall")

func _on_wall_destroyed():
	"""Wall wurde zerstört - Victory!"""
	print("[GameScene] Wall Destroyed! Victory!")

	# SFX + Screenshake
	# TODO: Audio.play_sfx("wall_break.ogg")  # Commit später
	camera.shake_wall_destroyed()

	# Victory! Update progression
	var level = Global.selected_level

	# Update Highscore (returns true if new)
	is_new_highscore = Global.update_highscore(level, Global.current_round_score)

	# Update Highest Combo (from static player)
	Global.update_highest_combo(level, player.highest_combo)

	# Unlock next level
	if level < 7:
		Global.unlock_next_level(level)

	# Sieg-Flag setzen (zuverlässig, statt der wall.visible-Heuristik)
	round_won = true

	# Wall-HP für dieses Level zurücksetzen, damit es erneut spielbar ist
	# (sonst startet ein Replay mit gespeicherten 0 HP -> sofort wieder zerstört)
	Global.reset_wall_hp(level)

	# Auto-Save bei Victory
	Global.trigger_auto_save()

	# End Round
	end_round()

func _on_wall_hp_changed(current_hp: float, max_hp: float):
	"""Wall HP hat sich geändert"""
	# HUD wird automatisch via Signal updated
	pass

# ============================================================================
# ROUND MANAGEMENT
# ============================================================================

func start_round():
	"""Startet die Runde"""
	if is_round_active:
		return

	is_round_active = true

	# Reset Round Score
	Global.reset_round_score()
	_last_round_score = 0

	# Speichere Total Highscore vor Runde (für Wand-Schaden)
	total_highscore_before_round = Global.total_highscore

	# Reset Round Stats
	coins_at_round_start = Global.coins
	round_start_time = Time.get_ticks_msec() / 1000.0
	enemies_killed_this_round = 0
	player_died = false

	# Mini-Runden vorbereiten
	round_won = false
	current_mini = 0
	in_intermission = false
	if Global.selected_level == 7:
		# Endless: kein Rundentimer, nur Pausen alle 60s
		endless_elapsed = 0.0
		endless_next_pause = ENDLESS_PAUSE_INTERVAL
	else:
		_generate_mini_durations()
		round_time_left = mini_durations[0]
		if hud and hud.has_method("update_timer"):
			hud.update_timer(round_time_left)

	# Start Spawners
	enemy_spawner.start_spawning()
	coin_spawner.start_spawning()

	# Zufälligen Runden-OST starten (loopt via AudioManager)
	Audio.play_music(ROUND_OSTS[randi() % ROUND_OSTS.size()])

	print("[GameScene] Round Started")

func _generate_mini_durations():
	"""Erzeugt MINI_COUNT zufällige Mini-Runden-Dauern, die zusammen
	TOTAL_MIN..TOTAL_MAX Sekunden ergeben (je mind. MINI_MIN)."""
	var total := randf_range(TOTAL_MIN, TOTAL_MAX)
	var weights: Array[float] = [randf() + 0.5, randf() + 0.5, randf() + 0.5]
	var sum_w: float = weights[0] + weights[1] + weights[2]

	mini_durations.clear()
	for i in range(MINI_COUNT):
		var d: float = max(MINI_MIN, total * (weights[i] / sum_w))
		mini_durations.append(d)

	print("[GameScene] Mini-Runden-Dauern: ", mini_durations)

func _advance_mini():
	"""Aktuelle Mini-Runde abgelaufen: nächste starten oder Runde beenden."""
	current_mini += 1
	if current_mini >= MINI_COUNT:
		print("[GameScene] Alle Mini-Runden durch!")
		end_round()
	else:
		_start_intermission()

func _start_intermission():
	"""Friert das Spiel ein und zeigt die Pause (Items + Shop)."""
	in_intermission = true
	get_tree().paused = true
	intermission.start(INTERMISSION_SECONDS)
	print("[GameScene] Intermission gestartet (Mini %d)" % current_mini)

func _on_intermission_finished():
	"""Pause vorbei: fortsetzen, ggf. neue Item-Effekte übernehmen."""
	get_tree().paused = false
	in_intermission = false

	# Nur bei Änderung neu anwenden (apply_item_effects heilt bei golem_skin auf max_hp)
	if intermission.selection_changed:
		player.apply_item_effects()
		if Global.is_item_active("golem_blessing") and wall and wall.visible:
			wall.enable_regeneration()

	if Global.selected_level == 7:
		endless_next_pause += ENDLESS_PAUSE_INTERVAL
	else:
		round_time_left = mini_durations[current_mini]
		if hud and hud.has_method("update_timer"):
			hud.update_timer(round_time_left)

	print("[GameScene] Intermission beendet - weiter mit Mini %d" % current_mini)

func end_round():
	"""Beendet die Runde"""
	if not is_round_active:
		return

	is_round_active = false

	# Save Wall HP (persistent across rounds)
	if wall.visible and Global.selected_level != 7:
		Global.update_wall_hp(Global.selected_level, wall.current_hp)

	# Stop Spawners
	enemy_spawner.stop_spawning()
	coin_spawner.stop_spawning()

	# Clear Enemies + Coins
	enemy_spawner.clear_all_enemies()
	coin_spawner.clear_all_coins()

	# Rundenscore sichern, bevor Global.end_round() ihn zurücksetzt (für EndScreen)
	_final_round_score = Global.current_round_score

	# Update Global Stats
	Global.end_round()

	# Deactivate Items
	Global.deactivate_all_items()

	# Auto-Save bei Round-Ende
	Global.trigger_auto_save()

	# Show End Screen
	show_end_screen()

	print("[GameScene] Round Ended - Score: ", Global.current_round_score)

func show_end_screen():
	"""Zeigt End Screen mit Stats"""
	# Calculate Stats
	var round_time = (Time.get_ticks_msec() / 1000.0) - round_start_time
	var coins_earned = Global.coins - coins_at_round_start
	var victory = round_won

	var stats = {
		"round_score": _final_round_score,
		"total_score": Global.total_highscore,
		"coins_earned": coins_earned,
		"highest_combo": player.highest_combo,
		"enemies_killed": enemies_killed_this_round,
		"time_played": round_time,
		"victory": victory,
		"new_highscore": is_new_highscore,
		"died": player_died,
	}

	# Show EndScreen with stats
	end_screen.show_stats(stats)

# ============================================================================
# ROUND TIMER
# ============================================================================

func _process(delta: float):
	"""Mini-Runden-Timer (L1–6) bzw. Endless-Pausen-Timer (L7)."""
	if not is_round_active or is_paused or in_intermission:
		return

	# Endless (Level 7): kein Rundenende per Timer, aber Pause alle 60s
	if Global.selected_level == 7:
		endless_elapsed += delta
		if endless_elapsed >= endless_next_pause:
			_start_intermission()
		return

	round_time_left -= delta

	if hud and hud.has_method("update_timer"):
		hud.update_timer(round_time_left)

	if round_time_left <= 0.0:
		round_time_left = 0.0
		_advance_mini()

# ============================================================================
# PAUSE SYSTEM
# ============================================================================

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):  # ESC Key
		if in_intermission:
			return  # Während der Mini-Pause kein zusätzliches Pausenmenü
		toggle_pause()

func toggle_pause():
	"""Pausiert/Entpausiert das Spiel"""
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_screen.visible = is_paused

	print("[GameScene] Paused: ", is_paused)

# ============================================================================
# PLAYER SIGNAL HANDLERS
# ============================================================================

func _on_player_died():
	"""Player ist gestorben"""
	print("[GameScene] Player Died")
	player_died = true

	# Wait a moment (für Death-Animation)
	await get_tree().create_timer(1.0).timeout

	# End Round
	end_round()

func _on_player_hit_enemy(enemy: Enemy):
	"""Player hat Enemy getroffen (One-Hit-KO)"""
	# Track Kill
	enemies_killed_this_round += 1

	# Auto-Save alle 10 Kills
	if enemies_killed_this_round % 10 == 0:
		Global.trigger_auto_save()

	# Screenshake basierend auf Enemy-Typ
	match enemy.enemy_type:
		Enemy.Type.INSECT:
			camera.shake_light_hit()
		Enemy.Type.VASE_MONSTER:
			camera.shake_normal_hit()
		Enemy.Type.FIRE_DEVIL:
			camera.shake_heavy_hit()

func _on_combo_increased(combo: int):
	"""Combo erhöht"""
	# HUD wird via Signal updated
	pass

func _on_player_took_damage(hp: int):
	"""Player nahm Schaden"""
	# HUD wird via Signal updated

	# Screenshake
	camera.shake_player_hurt()

# ============================================================================
# GLOBAL SIGNAL HANDLERS
# ============================================================================

func _on_score_changed(new_score: int):
	"""Score hat sich geändert - Wand inkrementell beschädigen.

	Jeder Score-Zuwachs beschädigt die Wand um genau diesen Zuwachs (Delta) - unabhängig
	von Rundengrenzen. Dadurch sinkt die persistente Wall-HP über mehrere Runden hinweg,
	statt an den absoluten Rundenscore gekoppelt zu sein."""
	if Global.selected_level == 7:
		return  # Endless Mode, keine Wand

	var delta := new_score - _last_round_score
	_last_round_score = new_score

	if delta > 0:
		wall.take_damage(delta * Global.wall_damage_multiplier)

# ============================================================================
# CLEANUP
# ============================================================================

func _exit_tree():
	"""Cleanup beim Verlassen"""
	# Deactivate Items
	Global.deactivate_all_items()

	# Reset Time Scale (falls Slow Motion aktiv)
	Engine.time_scale = 1.0

# ============================================================================
# UI BUTTON HANDLERS
# ============================================================================

func _on_shop_button_pressed():
	"""Shop Button im EndScreen"""
	SceneLoader.load_scene("res://Scenes/shop.tscn")

func _on_retry_button_pressed():
	"""Retry Button im EndScreen"""
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	"""Menu Button im EndScreen"""
	get_tree().paused = false
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")

func _on_continue_button_pressed():
	"""Continue Button im PauseScreen"""
	toggle_pause()

func _on_save_button_pressed():
	"""Save Button im PauseScreen - Manual Save"""
	SaveSystem.save_game(false)  # Manual save
	print("[GameScene] Manual save triggered from pause menu")

func _on_restart_button_pressed():
	"""Restart Button im PauseScreen"""
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_pause_menu_button_pressed():
	"""Menu Button im PauseScreen"""
	get_tree().paused = false
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
