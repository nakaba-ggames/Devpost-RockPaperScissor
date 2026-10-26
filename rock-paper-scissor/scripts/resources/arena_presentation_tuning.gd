extends Resource
@export var persona: Resource
@export var modifier_sound_id: String = "phase_end"
@export var heading_font: Font
@export var rock_icon: Texture2D
@export var paper_icon: Texture2D
@export var scissor_icon: Texture2D
@export var keep_icon: Texture2D
@export var switch_icon: Texture2D
@export_group("Choice feedback")
@export var select_seconds: float = 0.10
@export var selected_scale: float = 1.07
@export var other_alpha: float = 0.5
@export var transition: Tween.TransitionType = Tween.TRANS_QUART
@export var ease: Tween.EaseType = Tween.EASE_OUT
@export_group("Player headers")
@export var header_seconds: float = 0.20
@export var offscreen_margin: float = 20.0
@export_group("Phase clock")
@export var clock_track: Color = Color(0.13, 0.19, 0.26, 1)
@export var clock_fill: Color = Color(0.88, 0.72, 0.36, 1)
@export var clock_warning: Color = Color(0.94, 0.31, 0.24, 1)
@export var warning_seconds: float = 5.0
@export var clock_width: float = 6.0
@export var clock_segments: int = 64
