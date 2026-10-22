extends CPUParticles2D
const SubmissionEffect = preload("res://scripts/resources/submission_effect.gd")
@export var settings: SubmissionEffect

func _ready() -> void:
	emitting = false
	one_shot = true
	explosiveness = 1.0
	texture = settings.texture
	amount = settings.amount
	lifetime = settings.lifetime
	spread = settings.spread
	gravity = Vector2.ZERO
	initial_velocity_min = settings.velocity.x
	initial_velocity_max = settings.velocity.y
	scale_amount_min = settings.particle_scale.x
	scale_amount_max = settings.particle_scale.y
	color = settings.color
