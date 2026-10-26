extends Button
const SOUND = preload("res://resources/presentation/ui_sound_config.tres")
@export var tuning: Resource
var selection_tween: Tween

func _ready() -> void:
	$Caption.add_theme_font_override("font", tuning.heading_font)
	pressed.connect(func(): SOUND.play(self, "card_select"))
	resized.connect(_pivot)
	_pivot()

func _pivot() -> void:
	pivot_offset = size / 2.0

func configure_face(value: String) -> void:
	text = value
	$Caption.text = value.to_upper()
	$Caption.hide()
	tooltip_text = value
	$SecondIcon.hide()
	var icon: Texture2D = tuning.rock_icon
	if value == "Paper":
		icon = tuning.paper_icon
	elif value == "Scissor":
		icon = tuning.scissor_icon
	elif value == "Keep":
		icon = tuning.keep_icon
	elif value == "Switch":
		icon = tuning.switch_icon
	$Icon.texture = icon
	set_selected(false, false)

func set_selected(selected: bool, another_selected: bool) -> void:
	if selection_tween and selection_tween.is_valid():
		selection_tween.kill()
	var target_scale := Vector2.ONE
	var alpha := 1.0
	if selected:
		target_scale *= tuning.selected_scale
	elif another_selected:
		alpha = tuning.other_alpha
	selection_tween = create_tween().set_parallel(true).set_trans(tuning.transition).set_ease(tuning.ease)
	selection_tween.tween_property(self, "scale", target_scale, tuning.select_seconds)
	selection_tween.tween_property(self, "modulate:a", alpha, tuning.select_seconds)
