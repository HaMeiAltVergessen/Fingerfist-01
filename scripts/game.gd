# game.gd - GameScene Orchestrierung
extends Node2D

# ============================================================================
# NODE REFERENCES
# ============================================================================

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

# ============================================================================
# STATE
# ============================================================================

var is_round_active: bool = false
var is_paused: bool = false
var total_highscore_before_round: int = 0

# Round Stats Tracking
var coins_at_round_start: int = 0
var round_start_time: float = 0.0
var enemies_killed_this_round: int = 0
var is_new_highscore: bool = false

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create Save Indicator
	var indicator_script = preload("res://scripts/SaveIndicator.gd")
	save_indicator = CanvasLayer.new()
	save_indicator.set_script(indicator_script)
	add_child(save_indicator)

	# Hide Screens initially
	end_screen.visible = false
	pause_screen.visible = false

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
# PLAYER SETUP
# ============================================================================

func setup_player():
	"""Setup Player (statisch!)"""
	if not player:
		return

	# FESTE Position (links im Screen)
	player.position = Vector2(100, 360)

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

	# Speichere Total Highscore vor Runde (für Wand-Schaden)
	total_highscore_before_round = Global.total_highscore

	# Reset Round Stats
	coins_at_round_start = Global.coins
	round_start_time = Time.get_ticks_msec() / 1000.0
	enemies_killed_this_round = 0

	# Start Spawners
	enemy_spawner.start_spawning()
	coin_spawner.start_spawning()

	# TODO: Start Music (Commit später)
	# var level = Global.selected_level
	# if level <= 3:
	# 	Audio.play_music("combat_level_1.ogg")
	# elif level <= 6:
	# 	Audio.play_music("combat_level_2.ogg")
	# else:
	# 	Audio.play_music("combat_boss.ogg")

	print("[GameScene] Round Started")

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
	var victory = (wall and not wall.visible)

	var stats = {
		"round_score": Global.current_round_score,
		"total_score": Global.total_highscore,
		"coins_earned": coins_earned,
		"highest_combo": player.highest_combo,
		"enemies_killed": enemies_killed_this_round,
		"time_played": round_time,
		"victory": victory,
		"new_highscore": is_new_highscore,
	}

	# Show EndScreen with stats
	end_screen.show_stats(stats)

# ============================================================================
# PAUSE SYSTEM
# ============================================================================

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):  # ESC Key
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
	"""Score hat sich geändert - Damage Wall"""
	if Global.selected_level == 7:
		return  # Endless Mode, keine Wand

	# Score damages wall (every point of score = 1 damage)
	# Wall tracks its own HP, we just tell it to take damage
	# Note: This is called on score increase, so we damage by the increment
	# But since score increases are small (usually 1-10), we just sync HP with score
	var level = Global.selected_level
	var max_hp = Global.WALL_HP_PER_LEVEL.get(level, 0)
	var target_hp = max_hp - Global.current_round_score

	# Damage wall to match target HP
	var current_wall_hp = wall.current_hp
	if target_hp < current_wall_hp:
		var damage = current_wall_hp - target_hp
		wall.take_damage(damage)

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

func _on_restart_button_pressed():
	"""Restart Button im PauseScreen"""
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_pause_menu_button_pressed():
	"""Menu Button im PauseScreen"""
	get_tree().paused = false
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
