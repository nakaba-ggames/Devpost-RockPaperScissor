class_name SearchMotion
extends Resource
@export var fade_seconds: float = 0.28
@export var dot_seconds: float = 0.4
@export var bob_seconds: float = 0.85
@export var bob_distance: float = 12.0
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var ease: Tween.EaseType = Tween.EASE_IN_OUT

@export_group("Card")
@export var card_enter_seconds: float = 0.4
@export var flip_quarter_seconds: float = 0.28
@export var flip_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var flip_in_ease: Tween.EaseType = Tween.EASE_IN
@export var flip_out_ease: Tween.EaseType = Tween.EASE_OUT
@export var pulse_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var pulse_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var found_pop_scale: float = 1.15
@export var found_pop_seconds: float = 0.16
@export var pop_transition: Tween.TransitionType = Tween.TRANS_BACK
@export var pop_ease: Tween.EaseType = Tween.EASE_OUT
@export_group("Search status")
@export var pulse_half_seconds: float = 0.75
@export var pulse_min_alpha: float = 0.0
@export var found_hold_seconds: float = 0.35
@export_group("Table entrance")
@export var table_enter_seconds: float = 0.6
@export var table_start_alpha: float = 0.75
@export var offscreen_margin: float = 24.0
@export var table_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var table_ease: Tween.EaseType = Tween.EASE_OUT
@export_group("Offline sandbox only")
@export var preview_search_seconds: float = 10.0
