extends Resource
@export var fade_seconds: float = 0.25
@export var travel_pixels: float = 18.0
@export var losing_alpha: float = 0.35
@export var page_size: int = 3
@export var transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease: Tween.EaseType = Tween.EASE_OUT
@export_group("Modal choreography")
@export var open_seconds: float = 0.35
@export var close_seconds: float = 0.2
@export var open_scale: float = 0.5
@export var close_scale: float = 0.0
@export var dimmer_alpha: float = 0.88
@export var quest_track: StyleBox
@export var quest_fill: StyleBox
@export var open_transition: Tween.TransitionType = Tween.TRANS_BACK
@export var open_ease: Tween.EaseType = Tween.EASE_OUT
@export var close_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var close_ease: Tween.EaseType = Tween.EASE_IN

# Reapplied at runtime: Godot 4.7 binary export loses inherited Control offsets.
@export var panel_insets: Vector4 = Vector4(16, 60, 16, 45)
@export var content_insets: Vector4 = Vector4(30, 78, 30, 63)
