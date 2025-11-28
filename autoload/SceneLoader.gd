# SceneLoader.gd - Szenen-Manager mit Fade-Transitions
extends Node

# ============================================================================
# CONFIGURATION
# ============================================================================

var fade_duration: float = 0.3
var is_loading: bool = false

# ============================================================================
# FADE OVERLAY
# ============================================================================

var fade_rect: ColorRect

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Create Fade Overlay (CanvasLayer für hohen z-index)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Über allen anderen UI-Elementen
	add_child(canvas_layer)

	# Fullscreen Black Overlay
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)  # Transparent am Start
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(fade_rect)

	# Fullscreen anchors
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.offset_left = 0
	fade_rect.offset_top = 0
	fade_rect.offset_right = 0
	fade_rect.offset_bottom = 0

# ============================================================================
# SCENE LOADING
# ============================================================================

func load_scene(scene_path: String):
	if is_loading:
		return  # Prevent multiple simultaneous loads

	is_loading = true

	# Fade Out (zu Schwarz)
	await fade_out()

	# Change Scene
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to load scene: " + scene_path)
		is_loading = false
		return

	# Small delay für Scene-Initialization
	await get_tree().create_timer(0.1).timeout

	# Fade In (von Schwarz)
	await fade_in()

	is_loading = false

# ============================================================================
# FADE EFFECTS
# ============================================================================

func fade_out() -> void:
	# Block input während Fade
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	# Tween zu Schwarz (alpha 0 → 1)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished

func fade_in() -> void:
	# Tween zu Transparent (alpha 1 → 0)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, fade_duration)
	await tween.finished

	# Re-enable input
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# ============================================================================
# UTILITY
# ============================================================================

func set_fade_duration(duration: float):
	fade_duration = clamp(duration, 0.1, 2.0)

func is_transitioning() -> bool:
	return is_loading
