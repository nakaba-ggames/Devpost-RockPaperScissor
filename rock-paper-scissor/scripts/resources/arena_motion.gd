class_name ArenaMotion
extends Resource
@export var intro_fade_seconds: float = 0.35
@export var intro_hold_seconds: float = 2.0
@export var card_seconds: float = 0.45
@export var dim_seconds: float = 0.25
@export var announcement_seconds: float = 0.2
@export var phase_end_fade_seconds: float = 0.3
@export var phase_end_hold_seconds: float = 1.0
@export var dim_alpha: float = 0.5
@export var unselected_brightness: float = 0.55
@export var card_scale: Vector2 = Vector2(0.42, 0.42)
@export var card_spacing: float = 112.0
@export var opponent_y: float = 178.0
@export var player_y: float = 534.0
@export var opponent_submission_y: float = 306.0
@export var player_submission_y: float = 404.0
@export var feedback_start_scale: Vector2 = Vector2(0.85, 0.85)
@export var transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease: Tween.EaseType = Tween.EASE_OUT
@export var bubble_seconds: float = 0.35
@export var bubble_start_scale: Vector2 = Vector2(0.92, 0.92)
@export var unused_card_exit_distance: float = 95.0
@export var chat_seconds: float = 0.25
@export var chat_slide_distance: float = 34.0
@export_group("Decision layout")
@export var choices_y: float = 525.0
@export var instruction_y: float = 455.0
@export var final_choices_y: float = 300.0
@export var final_instruction_y: float = 230.0
@export var submission_pulse_scale: float = 1.12
@export var submission_pulse_seconds: float = 0.18

@export var table_position: Vector2 = Vector2(12, -15)

@export_group("Previous choice reminder")
@export var previous_choice_caption: String = "PREVIOUSLY"
@export var previous_choice_caption_y: float = -52.0
@export var previous_choice_caption_font_size: int = 24
@export var previous_choice_flip_seconds: float = 4.0
@export var previous_choice_position: Vector2 = Vector2(211, 600)
@export_range(0.1, 1.0) var previous_choice_scale: float = 0.5
