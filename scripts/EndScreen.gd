# EndScreen.gd - Detailed Round End Statistics
extends CanvasLayer

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var panel: Panel = $EndScreenPanel
@onready var title_label: Label = $EndScreenPanel/TitleLabel
@onready var round_score_label: Label = $EndScreenPanel/StatsContainer/RoundScoreLabel
@onready var total_score_label: Label = $EndScreenPanel/StatsContainer/TotalScoreLabel
@onready var coins_earned_label: Label = $EndScreenPanel/StatsContainer/CoinsEarnedLabel
@onready var highest_combo_label: Label = $EndScreenPanel/StatsContainer/HighestComboLabel
@onready var enemies_killed_label: Label = $EndScreenPanel/StatsContainer/EnemiesKilledLabel
@onready var time_played_label: Label = $EndScreenPanel/StatsContainer/TimePlayedLabel

@onready var shop_button: Button = $EndScreenPanel/ButtonsContainer/ShopButton
@onready var retry_button: Button = $EndScreenPanel/ButtonsContainer/RetryButton
@onready var menu_button: Button = $EndScreenPanel/ButtonsContainer/MenuButton

# ============================================================================
# STATE
# ============================================================================

var round_stats: Dictionary = {}

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	visible = false

	# Connect Buttons
	shop_button.pressed.connect(_on_shop_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

# ============================================================================
# PUBLIC API
# ============================================================================

func show_stats(stats: Dictionary):
	"""Zeigt EndScreen mit Stats

	Args:
		stats: {
			round_score: int,
			total_score: int,
			coins_earned: int,
			highest_combo: int,
			enemies_killed: int,
			time_played: float,
			victory: bool,
		}
	"""
	round_stats = stats

	# Title (Victory vs Defeat)
	if stats.get("victory", false):
		# Check if new highscore
		if stats.get("new_highscore", false):
			title_label.text = "🏆 NEW HIGHSCORE! 🏆"
			title_label.modulate = Color(1.0, 0.84, 0.0)  # Gold
		else:
			title_label.text = "🎉 LEVEL COMPLETE! 🎉"
			title_label.modulate = Color(0.3, 1.0, 0.3)
	else:
		title_label.text = "💀 GAME OVER 💀"
		title_label.modulate = Color(1.0, 0.3, 0.3)

	# Stats
	round_score_label.text = "Round Score: %d" % stats.get("round_score", 0)
	total_score_label.text = "Total Score: %d" % stats.get("total_score", 0)
	coins_earned_label.text = "Coins Earned: %d" % stats.get("coins_earned", 0)
	highest_combo_label.text = "Highest Combo: x%d" % stats.get("highest_combo", 0)
	enemies_killed_label.text = "Enemies Killed: %d" % stats.get("enemies_killed", 0)

	# Time (MM:SS)
	var time = stats.get("time_played", 0.0)
	var minutes = int(time / 60.0)
	var seconds = int(time) % 60
	time_played_label.text = "Time: %02d:%02d" % [minutes, seconds]

	# Show
	visible = true
	get_tree().paused = true

	# Fade-In
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)

	print("[EndScreen] Showing stats - Victory: ", stats.get("victory", false))

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_shop_pressed():
	"""Load Shop Scene"""
	get_tree().paused = false
	SceneLoader.load_scene("res://Scenes/shop.tscn")

func _on_retry_pressed():
	"""Retry Current Level"""
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	"""Return to Main Menu"""
	get_tree().paused = false
	SceneLoader.load_scene("res://Scenes/MainMenu.tscn")
