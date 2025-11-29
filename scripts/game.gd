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
@onready var wall: Sprite2D = $Wall
@onready var end_screen: CanvasLayer = $EndScreen
@onready var pause_screen: CanvasLayer = $PauseScreen

# ============================================================================
# STATE
# ============================================================================

var is_round_active: bool = false
var is_paused: bool = false
var total_highscore_before_round: int = 0

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
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
	if not Global.WALL_HP_PER_LEVEL.has(level):
		push_error("Invalid level: " + str(level))
		return

	var max_hp = Global.WALL_HP_PER_LEVEL[level]
	var current_hp = Global.get_wall_remaining_hp(level)

	# Wand-Sprite anzeigen
	wall.visible = true
	wall.position = Vector2(48, 360)  # Links im Screen

	# TODO: Wand-Sprite laden basierend auf Level (Commit später)
	# wall.texture = load("res://assets/sprites/walls/level_%d/wall_intact.png" % level)

	# Wand-Zustand setzen
	update_wall_visual(current_hp, max_hp)

	print("[GameScene] Wall HP: ", current_hp, "/", max_hp)

func setup_endless_mode():
	"""Endless Mode (Level 7) - keine Wand"""
	wall.visible = false
	print("[GameScene] Endless Mode - No Wall")

func update_wall_visual(current_hp: float, max_hp: float):
	"""Updated Wand-Sprite basierend auf HP-Prozent"""
	if not wall.visible:
		return

	var hp_percent = (current_hp / max_hp) * 100.0

	# Sprite-Zustand (3 States)
	if hp_percent > 67:
		# Intact
		wall.modulate = Color(1.0, 1.0, 1.0)  # Normal
	elif hp_percent > 34:
		# Damaged
		wall.modulate = Color(0.9, 0.8, 0.7)  # Leicht gelblich
		# TODO: SFX wall_crack_01.ogg (Commit später)
	else:
		# Critical
		wall.modulate = Color(0.8, 0.6, 0.5)  # Rötlich
		# TODO: SFX wall_crack_02.ogg (Commit später)

	# Prüfe Zerstörung
	if current_hp <= 0:
		destroy_wall()

func destroy_wall():
	"""Wand wird zerstört - Level Complete"""
	if not wall.visible:
		return

	wall.visible = false

	# SFX + Screenshake
	# TODO: Audio.play_sfx("wall_break.ogg")  # Commit später
	camera.shake_wall_destroyed()

	# Level Complete
	end_round()

	# Unlock next level
	if Global.selected_level < 7:
		Global.unlock_next_level(Global.selected_level)

	print("[GameScene] Wall Destroyed!")

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

	# Stop Spawners
	enemy_spawner.stop_spawning()
	coin_spawner.stop_spawning()

	# Clear Enemies
	enemy_spawner.clear_all_enemies()

	# Update Global Stats
	Global.end_round()

	# Deactivate Items
	Global.deactivate_all_items()

	# Save Game
	SaveSystem.save_game()

	# Show End Screen
	show_end_screen()

	print("[GameScene] Round Ended - Score: ", Global.current_round_score)

func show_end_screen():
	"""Zeigt End Screen mit Stats"""
	end_screen.visible = true
	get_tree().paused = true

	# TODO: Update End Screen Labels (Commit später)
	# var round_score = Global.current_round_score
	# var total_score = Global.total_highscore
	# var coins_earned = ...

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
	"""Player hat Enemy getroffen"""
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
	"""Score hat sich geändert - Update Wand"""
	if Global.selected_level == 7:
		return  # Endless Mode, keine Wand

	var level = Global.selected_level
	var max_hp = Global.WALL_HP_PER_LEVEL.get(level, 0)
	var score_delta = Global.total_highscore - total_highscore_before_round
	var current_hp = max_hp - (Global.total_highscore - score_delta)

	update_wall_visual(current_hp, max_hp)

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
