extends Resource
@export var menu: AudioStream
@export var gameplay: AudioStream
@export var bus: StringName = &"Master"
@export var volume_db: float = -15.0
@export var silent_db: float = -60.0
@export var fade_out_seconds: float = 0.22
@export var fade_in_seconds: float = 0.18
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var ease: Tween.EaseType = Tween.EASE_OUT
