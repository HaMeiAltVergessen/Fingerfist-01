extends Node
## VFX - Wiederverwendbarer One-Shot-Spawner für die transparenten Effekt-Sheets
## in assets/Placeholder/AIPlaceholder/.
##
## Aufruf von überall:
##   VFX.play("hit_spark_0", enemy.global_position)
##   VFX.play("death_vase", pos, get_parent(), {"scale": 1.3})
##
## Jeder Eintrag im CATALOG beschreibt ein Sprite-Sheet als gleichmäßiges
## h×v-Raster. Es wird ein Sprite2D erzeugt, per Tween Frame 0..n-1 abgespielt,
## kurz ausgeblendet und danach freigegeben (kein Node-Leak).

const _BASE := "res://assets/Placeholder/AIPlaceholder/"

# tex = Dateiname | h/v = Raster-Spalten/Zeilen | n = Anzahl genutzter Frames
# (row-major ab 0) | fps = Abspielgeschwindigkeit | scale = Default-Skalierung
const CATALOG := {
	"hit_spark_0":  {"tex": "hit_spark_00.png",   "h": 4, "v": 2, "n": 8,  "fps": 24.0, "scale": 0.9},
	"hit_spark_1":  {"tex": "hit_spark_01.png",   "h": 5, "v": 1, "n": 5,  "fps": 24.0, "scale": 0.9},
	"hit_spark_2":  {"tex": "hit_spark_02.png",   "h": 5, "v": 1, "n": 5,  "fps": 24.0, "scale": 0.9},
	"death_insect": {"tex": "death_insect_00.png","h": 4, "v": 4, "n": 4,  "fps": 18.0, "scale": 1.0},
	"death_vase":   {"tex": "death_vase_00.png",  "h": 4, "v": 3, "n": 4,  "fps": 16.0, "scale": 1.1},
	"death_fire":   {"tex": "death_fire_00.png",  "h": 4, "v": 2, "n": 7,  "fps": 16.0, "scale": 1.1},
	"proj_spawn":   {"tex": "proj_spawn_00.png",  "h": 3, "v": 1, "n": 3,  "fps": 18.0, "scale": 0.8},
	"proj_hit":     {"tex": "proj_hit_00.png.png","h": 3, "v": 1, "n": 3,  "fps": 18.0, "scale": 0.8},
	"wall_break":   {"tex": "wall_break_00.png",  "h": 5, "v": 1, "n": 5,  "fps": 18.0, "scale": 1.4},
	"coin_dust":    {"tex": "coin_dust_00.png",   "h": 4, "v": 1, "n": 4,  "fps": 18.0, "scale": 0.5},
	"coin_pop":     {"tex": "coin_pop_00.png",    "h": 5, "v": 1, "n": 5,  "fps": 22.0, "scale": 0.5},
	"hurt_flash":   {"tex": "hurt_flash_00.png",  "h": 4, "v": 1, "n": 4,  "fps": 20.0, "scale": 1.0},
	"fx_shield":    {"tex": "fx_shield_00.png",   "h": 5, "v": 1, "n": 5,  "fps": 16.0, "scale": 1.3},
	"fx_slowmo":    {"tex": "fx_slowmo_00.png",   "h": 3, "v": 1, "n": 3,  "fps": 10.0, "scale": 2.5},
	"fx_thunder":   {"tex": "fx_thunder_00.png",  "h": 5, "v": 1, "n": 5,  "fps": 20.0, "scale": 2.0},
	"fx_shockwave": {"tex": "fx_shockwave_00.png","h": 3, "v": 3, "n": 9,  "fps": 24.0, "scale": 2.0},
	"fx_meteor":    {"tex": "fx_meteor_00.png",   "h": 5, "v": 2, "n": 10, "fps": 16.0, "scale": 2.0},
}

var _tex_cache := {}

func _load_tex(file: String) -> Texture2D:
	if _tex_cache.has(file):
		return _tex_cache[file]
	var tex := load(_BASE + file) as Texture2D
	_tex_cache[file] = tex
	return tex

## Spielt einen Effekt einmalig an der Weltposition ab.
## opts (optional): "scale": float, "modulate": Color, "rotation": float
func play(key: String, world_pos: Vector2, parent: Node = null, opts: Dictionary = {}) -> void:
	if not CATALOG.has(key):
		push_warning("[VFX] Unbekannter Effekt-Key: %s" % key)
		return

	var cfg: Dictionary = CATALOG[key]
	var tex := _load_tex(cfg["tex"])
	if tex == null:
		push_warning("[VFX] Textur fehlt: %s" % cfg["tex"])
		return

	var host: Node = parent
	if host == null:
		host = get_tree().current_scene
	if host == null:
		return

	var spr := Sprite2D.new()
	spr.texture = tex
	spr.hframes = int(cfg["h"])
	spr.vframes = int(cfg["v"])
	spr.frame = 0
	spr.z_index = 100
	spr.scale = Vector2.ONE * float(opts.get("scale", cfg["scale"]))
	if opts.has("modulate"):
		spr.modulate = opts["modulate"]
	if opts.has("rotation"):
		spr.rotation = float(opts["rotation"])

	host.add_child(spr)
	spr.global_position = world_pos

	var frames := int(cfg["n"])
	var fps := float(cfg["fps"])
	var play_time := float(frames) / fps

	# Frames durchsteppen, dann kurz ausblenden, dann aufräumen.
	var tween := spr.create_tween()
	if frames > 1:
		tween.tween_method(
			func(f: float): spr.frame = clampi(int(f), 0, frames - 1),
			0.0, float(frames), play_time
		)
	else:
		tween.tween_interval(play_time)
	tween.tween_property(spr, "modulate:a", 0.0, 0.12)
	tween.finished.connect(spr.queue_free)

## Convenience: zufälliger Faust-Treffer-Funke (3 Varianten).
func play_hit_spark(world_pos: Vector2, parent: Node = null) -> void:
	play("hit_spark_%d" % (randi() % 3), world_pos, parent)
