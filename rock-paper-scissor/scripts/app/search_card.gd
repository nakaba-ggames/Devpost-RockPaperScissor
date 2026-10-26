extends Control
## Shared card with the existing creator-authored animation hook preserved.
@export var motion: SearchMotion
@export var search_animation: StringName = &"search"
@onready var animator: AnimationPlayer = $CreatorAnimation
@onready var visual: Control = $Visual
@onready var emblem: TextureRect = $Visual/EmblemHolder/Emblem
const GLOBE_TEXTURE = preload("res://Graphics/PresentationIcons/GlobeIcon.png")
const SWORD_TEXTURE = preload("res://Graphics/PresentationIcons/SwordIcon.png")
var flip_tween: Tween
var found_tween: Tween
var entrance_tween: Tween
var generation: int = 0

func _ready() -> void:
	visual.pivot_offset = visual.size / 2.0
	emblem.texture = GLOBE_TEXTURE

func start_motion() -> void:
	stop_motion()
	var ticket := generation
	emblem.texture = GLOBE_TEXTURE
	visual.scale = Vector2.ZERO
	visual.pivot_offset = visual.size / 2.0
	entrance_tween = create_tween().set_trans(motion.pop_transition).set_ease(motion.pop_ease)
	entrance_tween.tween_property(visual, "scale", Vector2.ONE, motion.card_enter_seconds)
	await entrance_tween.finished
	if ticket != generation:
		return
	if animator.has_animation(search_animation):
		animator.play(search_animation)
	else:
		_start_flip_loop()

func _start_flip_loop() -> void:
	flip_tween = create_tween().set_loops().set_trans(motion.flip_transition)
	flip_tween.tween_property(visual, "scale:x", 0.0, motion.flip_quarter_seconds).set_ease(motion.flip_in_ease)
	flip_tween.tween_property(visual, "scale:x", -1.0, motion.flip_quarter_seconds).set_ease(motion.flip_out_ease)
	flip_tween.tween_property(visual, "scale:x", 0.0, motion.flip_quarter_seconds).set_ease(motion.flip_in_ease)
	flip_tween.tween_property(visual, "scale:x", 1.0, motion.flip_quarter_seconds).set_ease(motion.flip_out_ease)

func show_player_found() -> void:
	stop_motion()
	emblem.texture = SWORD_TEXTURE
	found_tween = create_tween().set_trans(motion.pop_transition).set_ease(motion.pop_ease)
	found_tween.tween_property(visual, "scale", Vector2.ONE * motion.found_pop_scale, motion.found_pop_seconds)
	found_tween.tween_property(visual, "scale", Vector2.ONE, motion.found_pop_seconds)
	await found_tween.finished

func stop_motion() -> void:
	generation += 1
	if flip_tween and flip_tween.is_valid():
		flip_tween.kill()
	if found_tween and found_tween.is_valid():
		found_tween.kill()
	if entrance_tween and entrance_tween.is_valid():
		entrance_tween.kill()
	animator.stop()
	visual.scale = Vector2.ONE
	visual.position.y = 0.0
