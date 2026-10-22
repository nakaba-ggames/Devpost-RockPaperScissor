extends Resource
@export var fade_seconds: float = 0.25
@export var travel_pixels: float = 18.0
@export var losing_alpha: float = 0.35
@export var page_size: int = 3
@export var transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease: Tween.EaseType = Tween.EASE_OUT

# Reapplied at runtime: Godot 4.7 binary export loses inherited Control offsets.
@export var panel_insets: Vector4 = Vector4(16, 60, 16, 45)
@export var content_insets: Vector4 = Vector4(30, 78, 30, 63)
