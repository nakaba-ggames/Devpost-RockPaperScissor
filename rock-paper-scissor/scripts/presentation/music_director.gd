extends Node
## Presentation audio only; no match or result state is written here.
@export var config: Resource
var player: AudioStreamPlayer
var fade: Tween
var track: String = ""

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.bus = config.bus
	add_child(player)

func play_menu() -> void:
	_play("menu", config.menu)

func play_gameplay() -> void:
	_play("gameplay", config.gameplay)

func _play(next_track: String, source: AudioStream) -> void:
	if track == next_track and player.playing:
		return
	if fade and fade.is_valid():
		fade.kill()
	player.stop()
	if source == null:
		track = ""
		return
	var stream: AudioStream = source.duplicate()
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	player.stream = stream
	track = next_track
	player.volume_db = config.silent_db
	player.play()
	fade = create_tween().set_trans(config.transition).set_ease(config.ease)
	fade.tween_property(player, "volume_db", config.volume_db, config.fade_in_seconds)

func fade_out(_context: Resource = null) -> void:
	if fade and fade.is_valid():
		fade.kill()
	track = ""
	if not player.playing:
		return
	fade = create_tween().set_trans(config.transition).set_ease(config.ease)
	fade.tween_property(player, "volume_db", config.silent_db, config.fade_out_seconds)
	fade.tween_callback(player.stop)

func stop_for_result(_seconds: float) -> void:
	stop()

func stop() -> void:
	if fade and fade.is_valid():
		fade.kill()
	player.stop()
	track = ""
