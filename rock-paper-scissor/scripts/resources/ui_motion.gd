class_name MenuMotion
extends Resource

@export var entry_delay: float = 0.35
@export var fade_seconds: float = 0.28
@export var press_seconds: float = 0.10
@export var release_seconds: float = 0.18
@export var pressed_scale: float = 0.96
@export var feedback_seconds: float = 2.4
@export var feedback_offset: float = 10.0
@export var transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease: Tween.EaseType = Tween.EASE_OUT

@export_group("Menu choreography")
@export var menu_enter_seconds: float = 0.5
@export var menu_exit_seconds: float = 0.4
@export var offscreen_margin: float = 24.0
@export var menu_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var menu_enter_ease: Tween.EaseType = Tween.EASE_OUT
@export var menu_exit_ease: Tween.EaseType = Tween.EASE_IN
