extends Control
## A read-only view of the coordinator's deadline, never a second phase timer.
@export var tuning: Resource
var seconds: float = 0.0
var duration: float = 15.0

func update_time(remaining: float, total: float) -> void:
	seconds = maxf(remaining, 0.0)
	duration = total
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	var radius: float = minf(size.x, size.y) / 2.0 - tuning.clock_width
	draw_arc(center, radius, -PI / 2.0, TAU - PI / 2.0, tuning.clock_segments, tuning.clock_track, tuning.clock_width, false)
	var fraction := clampf(seconds / duration, 0.0, 1.0)
	if fraction <= 0.0:
		return
	var color: Color = tuning.clock_fill
	if seconds <= tuning.warning_seconds:
		color = tuning.clock_warning
	# Negative sweep runs counterclockwise; both rounded ends recede with time.
	var end := -PI / 2.0 - TAU * fraction
	draw_arc(center, radius, end, -PI / 2.0, tuning.clock_segments, color, tuning.clock_width, false)
	draw_circle(center + Vector2.from_angle(end) * radius, tuning.clock_width / 2.0, color)
	draw_circle(center + Vector2.UP * radius, tuning.clock_width / 2.0, color)
