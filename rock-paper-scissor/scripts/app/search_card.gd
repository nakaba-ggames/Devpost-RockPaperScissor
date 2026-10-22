extends Control
## Creator hook: author looping "search" in CreatorAnimation to replace bob.
@export var motion: SearchMotion
@export var search_animation: StringName = &"search"
@onready var animator: AnimationPlayer = $CreatorAnimation
@onready var visual: Control = $Visual
var bob: Tween

func start_motion() -> void:
	stop_motion()
	if animator.has_animation(search_animation):
		animator.play(search_animation)
		return
	bob = create_tween().set_loops().set_trans(motion.transition).set_ease(motion.ease)
	bob.tween_property(visual, "position:y", -motion.bob_distance, motion.bob_seconds)
	bob.tween_property(visual, "position:y", 0.0, motion.bob_seconds)

func stop_motion() -> void:
	if bob:
		bob.kill()
	animator.stop()
	visual.position.y = 0.0
