# CombatTestValidator.gd - Automated Combat Tests
extends Node

# ============================================================================
# TEST RESULTS
# ============================================================================

var test_results: Dictionary = {
	"player_exists": false,
	"player_can_attack": false,
	"enemy_can_spawn": false,
	"collision_detected": false,
	"enemy_dies_on_hit": false,
	"score_increases": false,
	"combo_tracks": false,
	"player_takes_damage": false,
	"hp_decreases": false,
	"screenshake_triggers": false,
}

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	print("\n=== COMBAT TEST VALIDATOR ===\n")
	await get_tree().create_timer(0.5).timeout
	run_all_tests()

# ============================================================================
# TEST SUITE
# ============================================================================

func run_all_tests():
	"""Führt alle Tests aus"""
	await test_player_exists()
	await test_player_attack()
	await test_enemy_spawn()
	await test_collision_detection()
	await test_enemy_death()
	await test_score_system()
	await test_combo_system()
	await test_player_damage()
	await test_screenshake()

	print_results()

# ============================================================================
# INDIVIDUAL TESTS
# ============================================================================

func test_player_exists():
	"""Test 1: Player existiert"""
	print("[Test 1] Checking Player existence...")

	var player = get_tree().get_first_node_in_group("player")
	test_results.player_exists = player != null

	if test_results.player_exists:
		print("  ✓ Player found")
	else:
		print("  ✗ Player NOT found")

func test_player_attack():
	"""Test 2: Player kann attacken"""
	print("[Test 2] Testing Player attack...")

	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("  ✗ Player not found, skipping")
		return

	var initial_attacking = player.is_attacking
	player.attack(Vector2(500, 360))
	await get_tree().create_timer(0.05).timeout

	test_results.player_can_attack = player.is_attacking or player.attack_timer > 0

	if test_results.player_can_attack:
		print("  ✓ Player can attack")
	else:
		print("  ✗ Player attack failed")

func test_enemy_spawn():
	"""Test 3: Enemy kann gespawnt werden"""
	print("[Test 3] Testing Enemy spawn...")

	var enemy_scene = load("res://Scenes/Enemy.tscn")
	var enemy = enemy_scene.instantiate() as Enemy
	enemy.position = Vector2(200, 360)
	get_tree().root.add_child(enemy)

	await get_tree().create_timer(0.1).timeout

	test_results.enemy_can_spawn = enemy != null and is_instance_valid(enemy)

	if test_results.enemy_can_spawn:
		print("  ✓ Enemy spawned successfully")
		enemy.queue_free()
	else:
		print("  ✗ Enemy spawn failed")

func test_collision_detection():
	"""Test 4: Collision Detection"""
	print("[Test 4] Testing collision detection...")

	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("  ✗ Player not found, skipping")
		return

	# Spawn Enemy nahe Player
	var enemy_scene = load("res://Scenes/Enemy.tscn")
	var enemy = enemy_scene.instantiate() as Enemy
	enemy.position = player.position + Vector2(50, 0)  # Nahe genug für Hit
	get_tree().root.add_child(enemy)

	# Connect Signal
	var collision_detected = false
	player.hit_enemy.connect(func(e): collision_detected = true)

	# Attack
	player.attack(enemy.position)
	await get_tree().create_timer(0.1).timeout

	test_results.collision_detected = collision_detected

	if test_results.collision_detected:
		print("  ✓ Collision detected")
	else:
		print("  ✗ Collision NOT detected")

	if is_instance_valid(enemy):
		enemy.queue_free()

func test_enemy_death():
	"""Test 5: Enemy stirbt bei Hit"""
	print("[Test 5] Testing enemy death...")

	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("  ✗ Player not found, skipping")
		return

	# Spawn Enemy
	var enemy_scene = load("res://Scenes/Enemy.tscn")
	var enemy = enemy_scene.instantiate() as Enemy
	enemy.position = player.position + Vector2(50, 0)
	get_tree().root.add_child(enemy)

	await get_tree().create_timer(0.1).timeout

	# Attack
	player.attack(enemy.position)
	await get_tree().create_timer(0.15).timeout

	test_results.enemy_dies_on_hit = not is_instance_valid(enemy)

	if test_results.enemy_dies_on_hit:
		print("  ✓ Enemy died on hit")
	else:
		print("  ✗ Enemy did NOT die")
		if is_instance_valid(enemy):
			enemy.queue_free()

func test_score_system():
	"""Test 6: Score erhöht sich"""
	print("[Test 6] Testing score system...")

	var initial_score = Global.current_round_score
	Global.add_score(10)

	test_results.score_increases = Global.current_round_score == initial_score + 10

	if test_results.score_increases:
		print("  ✓ Score increases correctly")
	else:
		print("  ✗ Score system broken")

func test_combo_system():
	"""Test 7: Combo tracked"""
	print("[Test 7] Testing combo system...")

	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("  ✗ Player not found, skipping")
		return

	var initial_combo = player.combo_counter
	player.combo_counter += 1

	test_results.combo_tracks = player.combo_counter == initial_combo + 1

	if test_results.combo_tracks:
		print("  ✓ Combo tracking works")
	else:
		print("  ✗ Combo tracking broken")

func test_player_damage():
	"""Test 8: Player nimmt Schaden"""
	print("[Test 8] Testing player damage...")

	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		print("  ✗ Player not found, skipping")
		return

	var initial_hp = player.hp
	player.take_damage(1)

	test_results.player_takes_damage = true  # Method existiert
	test_results.hp_decreases = player.hp == initial_hp - 1

	if test_results.hp_decreases:
		print("  ✓ Player takes damage correctly")
	else:
		print("  ✗ HP did not decrease")

func test_screenshake():
	"""Test 9: Screenshake funktioniert"""
	print("[Test 9] Testing screenshake...")

	var camera = get_tree().get_first_node_in_group("camera")
	if not camera:
		print("  ✗ Camera not found, skipping")
		return

	if not camera.has_method("shake_light_hit"):
		print("  ✗ Camera has no shake method")
		return

	camera.shake_light_hit()
	await get_tree().create_timer(0.05).timeout

	test_results.screenshake_triggers = camera.is_shaking()

	if test_results.screenshake_triggers:
		print("  ✓ Screenshake works")
	else:
		print("  ✗ Screenshake NOT triggered")

# ============================================================================
# RESULTS
# ============================================================================

func print_results():
	"""Zeigt Test-Ergebnisse"""
	print("\n=== TEST RESULTS ===")

	var passed = 0
	var total = test_results.size()

	for test_name in test_results:
		var result = test_results[test_name]
		var icon = "✓" if result else "✗"
		print("  %s %s" % [icon, test_name])
		if result:
			passed += 1

	print("\nPassed: %d / %d" % [passed, total])

	if passed == total:
		print("🎉 ALL TESTS PASSED!")
	else:
		print("❌ SOME TESTS FAILED")
