class_name UISoundConfig
extends Resource

## Sound configuration resource for UI interactions and transitions.
@export_group("Button Sounds")
@export var button_click: AudioStream
@export var play_game_click: AudioStream
@export var tab_select: AudioStream

@export_group("Modal Sounds")
@export var modal_open: AudioStream
@export var modal_close: AudioStream

@export_group("Title sequence")
@export var sfx_rock: AudioStream
@export var sfx_paper: AudioStream
@export var sfx_scissors: AudioStream
@export var sfx_devils: AudioStream
@export var sfx_chring: AudioStream
@export var sfx_tap: AudioStream
@export_group("Matchmaking")
@export var match_found: AudioStream
@export_group("Arena")
@export var card_select: AudioStream
@export var card_confirm: AudioStream
@export var phase_end: AudioStream
@export var dialogue: AudioStream
@export_group("Playback")
@export var bus: StringName = &"Master"
@export var volume_db: float = 0.0

func play(parent: Node, sound_id: String) -> void:
	var stream: AudioStream = get(sound_id)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db
	parent.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
