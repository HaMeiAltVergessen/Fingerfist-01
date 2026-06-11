extends Control
## Intro-Video beim Spielstart. Läuft als erste Szene (run/main_scene),
## spielt OmniaIntro01.ogv full-screen und wechselt danach ins Hauptmenü.
## Per Tippen / Klick / Tastendruck überspringbar.

const NEXT_SCENE := "res://Scenes/MainMenu.tscn"

@onready var player: VideoStreamPlayer = $VideoStreamPlayer

var _done := false

func _ready() -> void:
	player.finished.connect(_go_next)
	if not player.is_playing():
		player.play()

func _input(event: InputEvent) -> void:
	# Skip bei Tipp / Klick / Taste
	if (event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey) and event.pressed:
		_skip()

func _skip() -> void:
	if player.is_playing():
		player.stop()
	_go_next()

func _go_next() -> void:
	if _done:
		return
	_done = true
	SceneLoader.load_scene(NEXT_SCENE)
