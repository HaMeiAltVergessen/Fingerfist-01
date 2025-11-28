# AudioManager.gd - Zentrale Audio-Verwaltung
extends Node

# ============================================================================
# AUDIO BUS NAMES
# ============================================================================

const SFX_BUS = "SFX"
const MUSIC_BUS = "Music"

# ============================================================================
# VOLUME SETTINGS
# ============================================================================

var sfx_volume: float = 1.0
var music_volume: float = 0.7

# ============================================================================
# STATE
# ============================================================================

var current_music: AudioStreamPlayer
var active_sfx_count: int = 0
const MAX_SIMULTANEOUS_SFX: int = 8

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Setup Audio Buses (falls nicht in Project vorhanden)
	_setup_audio_buses()

	# Apply initial volumes
	set_sfx_volume(sfx_volume)
	set_music_volume(music_volume)

func _setup_audio_buses():
	var sfx_idx = AudioServer.get_bus_index(SFX_BUS)
	var music_idx = AudioServer.get_bus_index(MUSIC_BUS)

	if sfx_idx == -1:
		push_warning("SFX Bus not found in Audio settings. Create it manually.")
	if music_idx == -1:
		push_warning("MUSIC Bus not found in Audio settings. Create it manually.")

# ============================================================================
# SFX PLAYBACK
# ============================================================================

func play_sfx(sfx_name: String, pitch_variation: float = 0.1, volume_db: float = 0.0):
	# Limit simultaneous sounds (Performance)
	if active_sfx_count >= MAX_SIMULTANEOUS_SFX:
		return

	# Create temporary AudioStreamPlayer
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = SFX_BUS

	# Load Audio File
	var stream_path = "res://assets/audio/sfx/" + sfx_name
	if ResourceLoader.exists(stream_path):
		player.stream = load(stream_path)
	else:
		# File not found - cleanup and return
		push_warning("SFX not found: " + stream_path)
		player.queue_free()
		return

	# Pitch Variation (für Variabilität)
	player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)

	# Volume Override
	player.volume_db = volume_db

	# Play
	player.play()

	# Track active sounds
	active_sfx_count += 1

	# Auto-cleanup when finished
	player.finished.connect(func():
		active_sfx_count -= 1
		player.queue_free()
	)

# ============================================================================
# MUSIC PLAYBACK
# ============================================================================

func play_music(track_name: String, crossfade: bool = true):
	# Create new music player
	var new_music = AudioStreamPlayer.new()
	add_child(new_music)
	new_music.bus = MUSIC_BUS

	# Load Music File
	var stream_path = "res://assets/audio/music/" + track_name
	if ResourceLoader.exists(stream_path):
		new_music.stream = load(stream_path)
	else:
		push_warning("Music track not found: " + stream_path)
		new_music.queue_free()
		return

	# Crossfade with existing music
	if crossfade and current_music:
		# Fade out old, fade in new (parallel)
		var tween = create_tween().set_parallel(true)
		tween.tween_property(current_music, "volume_db", -80, 1.0)
		tween.tween_property(new_music, "volume_db", 0, 1.0).from(-80)

		await tween.finished
		current_music.queue_free()
	else:
		# Instant switch (no crossfade)
		if current_music:
			current_music.stop()
			current_music.queue_free()
		new_music.volume_db = 0

	# Set as current
	current_music = new_music
	current_music.play()

func stop_music():
	if current_music:
		# Fade out
		var tween = create_tween()
		tween.tween_property(current_music, "volume_db", -80, 0.5)
		await tween.finished

		current_music.stop()
		current_music.queue_free()
		current_music = null

# ============================================================================
# VOLUME CONTROL
# ============================================================================

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(SFX_BUS)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(MUSIC_BUS)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))

func get_sfx_volume() -> float:
	return sfx_volume

func get_music_volume() -> float:
	return music_volume

# ============================================================================
# UTILITY
# ============================================================================

func is_music_playing() -> bool:
	return current_music != null and current_music.playing

func get_active_sfx_count() -> int:
	return active_sfx_count
