class_name BackgroundMotion
extends Resource

## Configuration resource for background scrolling and color grading.
@export var scroll_speed: float = 0.08
@export var pattern_color: Color = Color(0.15, 0.22, 0.45, 0.85) # Navy-blue overlay
@export var pattern_enabled: bool = false
@export var gradient_modulate: Color = Color(0.85, 0.90, 1.0, 1.0)
@export var flash_seconds: float = 0.6
@export_range(0.0, 1.0) var flash_peak_fraction: float = 0.3
@export var flash_transition: Tween.TransitionType = Tween.TRANS_QUAD
@export var flash_in_ease: Tween.EaseType = Tween.EASE_OUT
@export var flash_out_ease: Tween.EaseType = Tween.EASE_IN
