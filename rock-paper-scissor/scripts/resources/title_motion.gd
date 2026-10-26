extends Resource
## Title choreography; connection delays emulate the two stages offline only.
@export_group("Word entrance")
@export var word_seconds: float = 0.5
@export var word_gap_seconds: float = 0.25
@export var devil_delay_seconds: float = 0.75
@export var devil_seconds: float = 1.0
@export var pop_transition: Tween.TransitionType = Tween.TRANS_BACK
@export var pop_ease: Tween.EaseType = Tween.EASE_OUT
@export_group("Composition")
@export_range(0.0, 1.0) var top_fraction: float = 0.13
@export_range(0.0, 1.0) var center_fraction: float = 0.5
@export_group("Idle motion")
@export var rotation_seconds_min: float = 1.0
@export var rotation_seconds_max: float = 2.0
@export var rotation_degrees: float = 5.0
@export var spinner_seconds: float = 1.5
@export var spinner_fade_seconds: float = 0.4
@export var pulse_seconds: float = 0.75
@export var pulse_min_alpha: float = 0.0
@export var idle_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var idle_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export_group("Offline connection preview")
@export var server_preview_seconds: float = 1.2
@export var multiplayer_preview_seconds: float = 1.2
@export_group("Continue")
@export var center_seconds: float = 0.8
@export var center_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var center_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var exit_seconds: float = 1.0
@export var exit_scale: float = 2.5
@export var exit_transition: Tween.TransitionType = Tween.TRANS_BACK
@export var exit_ease: Tween.EaseType = Tween.EASE_IN
