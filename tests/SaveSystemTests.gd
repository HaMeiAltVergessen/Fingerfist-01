# SaveSystemTests.gd - Manual Testing Script for Save System
extends Node

# ============================================================================
# MANUAL TESTING SUITE FOR SAVE SYSTEM
# ============================================================================
#
# Run these tests manually in the Godot editor by attaching this script
# to a Node and calling the test functions from _ready() or via buttons.
#
# ============================================================================

func _ready():
	print("[SaveSystemTests] Ready - Call test functions manually")
	print("Available tests:")
	print("  - test_auto_save_triggers()")
	print("  - test_slot_switching()")
	print("  - test_save_load_integrity()")
	print("  - test_backup_restore()")
	print("  - run_all_tests()")

# ============================================================================
# TEST: AUTO-SAVE TRIGGERS
# ============================================================================

func test_auto_save_triggers():
	"""Test Auto-Save Debouncing"""
	print("\n=== TEST: Auto-Save Triggers ===")

	# Trigger multiple auto-saves rapidly
	print("Triggering 5 rapid auto-saves...")
	for i in range(5):
		Global.trigger_auto_save()
		await get_tree().create_timer(0.1).timeout

	# Wait for debounce timer
	await get_tree().create_timer(SaveSystem.AUTO_SAVE_DELAY + 0.5).timeout

	print("✓ Auto-save debouncing test complete")
	print("  Expected: Only 1 save should have occurred")
	print("  Check console for 'Auto-Save (Slot X) complete' message")

# ============================================================================
# TEST: SLOT SWITCHING
# ============================================================================

func test_slot_switching():
	"""Test Switching Between Save Slots"""
	print("\n=== TEST: Slot Switching ===")

	# Save to slot 0
	SaveSystem.set_current_slot(0)
	Global.coins = 100
	Global.total_highscore = 1000
	SaveSystem.save_game(false)
	print("✓ Saved to Slot 0: Coins=100, Score=1000")

	# Save to slot 1
	SaveSystem.set_current_slot(1)
	Global.coins = 200
	Global.total_highscore = 2000
	SaveSystem.save_game(false)
	print("✓ Saved to Slot 1: Coins=200, Score=2000")

	# Save to slot 2
	SaveSystem.set_current_slot(2)
	Global.coins = 300
	Global.total_highscore = 3000
	SaveSystem.save_game(false)
	print("✓ Saved to Slot 2: Coins=300, Score=3000")

	# Load slot 0
	SaveSystem.set_current_slot(0)
	SaveSystem.load_game()
	assert(Global.coins == 100, "Slot 0 coins mismatch")
	assert(Global.total_highscore == 1000, "Slot 0 score mismatch")
	print("✓ Loaded Slot 0: Coins=%d, Score=%d" % [Global.coins, Global.total_highscore])

	# Load slot 1
	SaveSystem.set_current_slot(1)
	SaveSystem.load_game()
	assert(Global.coins == 200, "Slot 1 coins mismatch")
	assert(Global.total_highscore == 2000, "Slot 1 score mismatch")
	print("✓ Loaded Slot 1: Coins=%d, Score=%d" % [Global.coins, Global.total_highscore])

	print("✓ Slot switching test PASSED")

# ============================================================================
# TEST: SAVE/LOAD INTEGRITY
# ============================================================================

func test_save_load_integrity():
	"""Test Save/Load Data Integrity"""
	print("\n=== TEST: Save/Load Integrity ===")

	# Set test data
	SaveSystem.set_current_slot(0)
	Global.total_highscore = 5000
	Global.coins = 500
	Global.unlocked_levels = [1, 2, 3]
	Global.selected_level = 3
	Global.level_highscores = [100, 200, 300, 0, 0, 0, 0, 0]
	Global.total_rounds_played = 10
	Global.total_playtime = 123.45

	# Save
	SaveSystem.save_game(false)
	print("✓ Saved test data")

	# Clear data
	Global.total_highscore = 0
	Global.coins = 0
	Global.unlocked_levels = [1]
	Global.selected_level = 1
	Global.level_highscores = [0, 0, 0, 0, 0, 0, 0, 0]
	Global.total_rounds_played = 0
	Global.total_playtime = 0.0
	print("✓ Cleared data")

	# Load
	SaveSystem.load_game()
	print("✓ Loaded data")

	# Verify
	assert(Global.total_highscore == 5000, "Highscore mismatch")
	assert(Global.coins == 500, "Coins mismatch")
	assert(Global.unlocked_levels.size() == 3, "Unlocked levels mismatch")
	assert(Global.selected_level == 3, "Selected level mismatch")
	assert(Global.level_highscores[0] == 100, "Level highscores mismatch")
	assert(Global.total_rounds_played == 10, "Rounds played mismatch")
	assert(abs(Global.total_playtime - 123.45) < 0.01, "Playtime mismatch")

	print("✓ Save/Load integrity test PASSED")
	print("  All data fields preserved correctly")

# ============================================================================
# TEST: BACKUP RESTORE
# ============================================================================

func test_backup_restore():
	"""Test Backup/Restore Functionality"""
	print("\n=== TEST: Backup Restore ===")

	# Save initial state
	SaveSystem.set_current_slot(0)
	Global.coins = 1000
	Global.total_highscore = 10000
	SaveSystem.save_game(false)
	print("✓ Initial save: Coins=1000, Score=10000")

	# Modify and save (creates backup of previous save)
	Global.coins = 2000
	Global.total_highscore = 20000
	SaveSystem.save_game(false)
	print("✓ Modified save: Coins=2000, Score=20000")

	# Restore backup
	SaveSystem.restore_backup()
	print("✓ Backup restored")

	# Verify
	assert(Global.coins == 1000, "Backup coins mismatch")
	assert(Global.total_highscore == 10000, "Backup score mismatch")

	print("✓ Backup restore test PASSED")
	print("  Previous save successfully restored")

# ============================================================================
# TEST: SLOT INFO
# ============================================================================

func test_slot_info():
	"""Test get_slot_info() Functionality"""
	print("\n=== TEST: Slot Info ===")

	# Create save in slot 0
	SaveSystem.set_current_slot(0)
	Global.total_highscore = 5000
	Global.coins = 250
	Global.selected_level = 3
	SaveSystem.save_game(false)

	# Get info
	var info = SaveSystem.get_slot_info(0)

	# Verify
	assert(info.exists == true, "Slot should exist")
	assert(info.total_score == 5000, "Score mismatch")
	assert(info.coins == 250, "Coins mismatch")
	assert(info.level == 3, "Level mismatch")
	assert(not info.save_time.is_empty(), "Save time should not be empty")

	print("✓ Slot info test PASSED")
	print("  Slot 0 Info: %s" % str(info))

	# Test empty slot
	var empty_info = SaveSystem.get_slot_info(2)
	assert(empty_info.exists == false, "Slot 2 should be empty")
	print("✓ Empty slot check PASSED")

# ============================================================================
# RUN ALL TESTS
# ============================================================================

func run_all_tests():
	"""Run all tests sequentially"""
	print("\n" + "="*60)
	print("RUNNING ALL SAVE SYSTEM TESTS")
	print("="*60)

	await test_auto_save_triggers()
	test_slot_switching()
	test_save_load_integrity()
	test_backup_restore()
	test_slot_info()

	print("\n" + "="*60)
	print("ALL TESTS COMPLETE")
	print("="*60)
