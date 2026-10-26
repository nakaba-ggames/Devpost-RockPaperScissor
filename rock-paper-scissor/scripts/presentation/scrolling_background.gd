class_name ScrollingBackground
extends Control
@export var motion: Resource
@onready var gradient_rect: TextureRect = $Gradient
@onready var pattern_rect: TextureRect = $Pattern
@onready var flash_rect: ColorRect = $Flash
var pattern_material: ShaderMaterial
var flash_tween: Tween
var scroll_offset: float = 0.0

func _process(delta: float) -> void:
	scroll_offset = fposmod(scroll_offset + motion.scroll_speed * delta, 1.0)
	pattern_material.set_shader_parameter("scroll_offset", scroll_offset)

func _ready() -> void:
	if pattern_rect.material is ShaderMaterial:
		pattern_material = pattern_rect.material.duplicate()
		pattern_rect.material = pattern_material
	gradient_rect.modulate = motion.gradient_modulate
	pattern_material.set_shader_parameter("scroll_speed", motion.scroll_speed)
	pattern_material.set_shader_parameter("pattern_color", motion.pattern_color)
	reset_preview()

func reset_preview() -> void:
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	flash_rect.hide()
	flash_rect.modulate.a = 0.0
	scroll_offset = 0.0
	pattern_material.set_shader_parameter("scroll_offset", scroll_offset)
	set_pattern_active(motion.pattern_enabled)

func set_pattern_active(active: bool) -> void:
	# Runtime visibility must never mutate the shared Resource's default.
	pattern_rect.visible = active
	set_process(active)

func flash(peak_callback: Callable = Callable()) -> void:
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	flash_rect.show()
	flash_rect.modulate.a = 0.0
	flash_tween = create_tween().set_trans(motion.flash_transition)
	flash_tween.tween_property(flash_rect, "modulate:a", 1.0, motion.flash_seconds * motion.flash_peak_fraction).set_ease(motion.flash_in_ease)
	if peak_callback.is_valid():
		flash_tween.tween_callback(peak_callback)
	flash_tween.tween_property(flash_rect, "modulate:a", 0.0, motion.flash_seconds * (1.0 - motion.flash_peak_fraction)).set_ease(motion.flash_out_ease)
	flash_tween.tween_callback(flash_rect.hide)
