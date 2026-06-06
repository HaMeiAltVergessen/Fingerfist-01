# AudioManager.gd - Zentrale Audio-Verwaltung
extends Node

# ============================================================================
# AUDIO BUS NAMES
# ============================================================================

const SFX_BUS = "SFX"
const MUSIC_BUS = "Music"

# ============================================================================
# SFX KATALOG (neue Monster-/Magic-Packs - lange Pfade hier zentralisiert)
# ============================================================================

const _SFX := "res://assets/audio/sfx/"
const _MON1 := _SFX + "Monster Sound Effects 1 - Universal Sound Effects/Monster Sound Effects 1 - Universal Sound Effects/OGG/"
const _MON2 := _SFX + "Monster Sound Effects 2 - Universal Sound Effects/Monster Sound Effects 2 - Universal Sound Effects/OGG/"
const _MAG4 := _SFX + "Magic and Spells 4 - Universal Sound Effects/Magic and Spells 4 - Universal Sound Effects/"
const _GAME3 := _SFX + "Game Sound Effects Pack 3/Game Sound Effects Pack 3/OGG/"

# Semantischer Schlüssel -> Pool von OGG-Pfaden (zufällige Auswahl via play_sfx_random)
var sfx_pools := {
	# Spieler
	"punch":         [_GAME3 + "Punch - 1.ogg", _GAME3 + "Punch - 2.ogg", _GAME3 + "Punch - 3.ogg", _GAME3 + "Punch - 4.ogg"],
	"player_hurt":   [_GAME3 + "Player Hit - 1.ogg", _GAME3 + "Player Hit - 2.ogg", _GAME3 + "Player Hit - 3.ogg", _GAME3 + "Player Hit - 4.ogg"],
	"player_death":  [_GAME3 + "Player Death - 1.ogg", _GAME3 + "Player Death - 2.ogg"],
	"projectile_hit":[_GAME3 + "Player Hit - 5.ogg", _GAME3 + "Player Hit - 6.ogg"],
	# Gegner
	"insect_death": [_MON1 + "Monster 1 Death - 1.ogg", _MON1 + "Monster 4 Death - 1.ogg", _MON2 + "Monster 9 Death - 1.ogg"],
	"vase_death":   [_MON1 + "Monster 3 Death - 1.ogg", _MON1 + "Monster 8 Death - 1.ogg", _MON2 + "Monster 16 Death - 1.ogg"],
	"fire_death":   [_MON1 + "Monster 5 Death - 1.ogg", _MON1 + "Monster 6 Death - 1.ogg", _MON1 + "Monster 7 Death - 1.ogg"],
	"vase_windup":  [_MON1 + "Monster 2 Attack - 1.ogg"],
	"vase_attack":  [_MON1 + "Monster 2 Attack - 2.ogg", _MON1 + "Monster 3 Attack - 1.ogg"],
	"fire_charge":  [_MAG4 + "Fire Spells/Fire Spell - 1.ogg"],
	"fire_shot":    [_MAG4 + "Fire Spells/Fire Spell - 2.ogg"],
	# Items
	"item_shield":  [_MAG4 + "Buff Spells/Buff & Area Effect - 1.ogg"],
	"item_slowmo":  [_MAG4 + "Water Spells/Water Spell 1.ogg"],
	"item_thunder": [_MAG4 + "Air Spells/Air Spell - 1.ogg"],
	"item_meteor":  [_MAG4 + "Fire Spells/Fire Spell - 1.ogg"],
}

# ============================================================================
# VOLUME SETTINGS
# ============================================================================

var sfx_volume: float = 1.0
var music_volume: float = 0.7

# ============================================================================
# STATE
# ============================================================================

var current_music: AudioStreamPlayer
var current_track_name: String = ""
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
	# Legacy-API: relativer Name unter res://assets/audio/sfx/
	_play_path("res://assets/audio/sfx/" + sfx_name, pitch_variation, volume_db)

func play_sfx_random(key: String, pitch_variation: float = 0.1, volume_db: float = 0.0):
	"""Spielt einen zufälligen SFX aus dem Pool 'key' (siehe sfx_pools)."""
	var pool = sfx_pools.get(key, [])
	if pool.is_empty():
		push_warning("SFX pool empty/unknown: " + key)
		return
	_play_path(pool[randi() % pool.size()], pitch_variation, volume_db)

func _play_path(stream_path: String, pitch_variation: float = 0.1, volume_db: float = 0.0):
	# Limit simultaneous sounds (Performance)
	if active_sfx_count >= MAX_SIMULTANEOUS_SFX:
		return

	# Existenz prüfen
	if not ResourceLoader.exists(stream_path):
		push_warning("SFX not found: " + stream_path)
		return

	# Laden - bei ungültiger/fehlgeschlagener Ressource ABBRECHEN, BEVOR der Zähler erhöht wird.
	# (Sonst würde ein nie feuerndes 'finished'-Signal active_sfx_count permanent hochhalten
	#  und nach MAX_SIMULTANEOUS_SFX ALLE weiteren SFX blockieren -> Deadlock/Stille.)
	var stream = load(stream_path)
	if stream == null:
		push_warning("SFX failed to load (invalid resource): " + stream_path)
		return

	# Create temporary AudioStreamPlayer
	var player = AudioStreamPlayer.new()
	player.bus = SFX_BUS
	player.stream = stream

	# Pitch Variation (für Variabilität)
	player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)

	# Volume Override
	player.volume_db = volume_db

	add_child(player)

	# Track active sounds (erst jetzt, mit gültigem Stream)
	active_sfx_count += 1

	# Auto-cleanup when finished
	player.finished.connect(func():
		active_sfx_count -= 1
		player.queue_free()
	)

	# Play
	player.play()

# ============================================================================
# MUSIC PLAYBACK
# ============================================================================

func play_music(track_name: String, crossfade: bool = true):
	# Derselbe Track läuft bereits -> kein Neustart (z.B. bei Menü-Szenenwechsel)
	if track_name == current_track_name and is_music_playing():
		return

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

	# Looping erzwingen (Main Theme & OSTs sollen durchlaufen)
	if "loop" in new_music.stream:
		new_music.stream.loop = true

	current_track_name = track_name

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
		current_track_name = ""

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
