extends Button

@export var motion: MenuMotion
var motion_tween: Tween

func _ready() -> void:
	button_down.connect(_press)
	button_up.connect(_release)
	mouse_exited.connect(_release)
	resized.connect(_update_pivot)
	_update_pivot()

func _update_pivot() -> void:
	pivot_offset = size / 2.0

func _press() -> void:
	_move_to(Vector2.ONE * motion.pressed_scale, motion.press_seconds)

func _release() -> void:
	_move_to(Vector2.ONE, motion.release_seconds)

func _move_to(target: Vector2, seconds: float) -> void:
	if motion_tween:
		motion_tween.kill()
	motion_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	motion_tween.tween_property(self, "scale", target, seconds)
