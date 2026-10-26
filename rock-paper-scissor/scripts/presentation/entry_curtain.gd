extends CanvasLayer
const Motion = preload("res://scripts/presentation/curtain_motion.gd")
@export var tuning: Resource
var animation: Tween

func _ready() -> void:
	hide()
	set_process(false)

func _process(_delta: float) -> void:
	Motion.fit($CurtainLeft, $CurtainRight, Vector2.ZERO, get_viewport().get_visible_rect().size, tuning)

func close_curtains() -> void:
	show()
	set_process(true)
	_play(tuning.curtain_close_sound)
	animation = Motion.animate(self, $CurtainLeft, $CurtainRight, Vector2.ZERO, get_viewport().get_visible_rect().size, tuning, true)
	await animation.finished
	await get_tree().create_timer(tuning.curtain_hold_seconds).timeout

func open_curtains() -> void:
	_play(tuning.curtain_open_sound)
	animation = Motion.animate(self, $CurtainLeft, $CurtainRight, Vector2.ZERO, get_viewport().get_visible_rect().size, tuning, false)
	await animation.finished
	hide()
	set_process(false)

func reset() -> void:
	if animation and animation.is_valid():
		animation.kill()
	$Audio.stop()
	hide()
	set_process(false)

func _play(stream: AudioStream) -> void:
	$Audio.stream = stream
	$Audio.bus = tuning.effect_bus
	$Audio.volume_db = tuning.effect_volume_db
	$Audio.play()
