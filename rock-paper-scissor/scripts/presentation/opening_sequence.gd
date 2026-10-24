extends Control
signal finished
@export var motion: OpeningMotion

func _ready() -> void:
	_play.call_deferred()

func _play() -> void:
	var label: Label = $Text
	var home := label.position
	label.position.y += motion.travel_pixels
	label.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(label, "position", home, motion.fly_seconds)
	tween.tween_property(label, "modulate:a", 1.0, motion.fly_seconds)
	tween.set_parallel(false)
	tween.tween_interval(motion.hold_seconds)
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", home.y - motion.travel_pixels, motion.fly_seconds)
	tween.tween_property(label, "modulate:a", 0.0, motion.fly_seconds)
	await tween.finished
	hide()
	finished.emit()

