extends RefCounted

static func fit(left: TextureRect, right: TextureRect, origin: Vector2, screen: Vector2, tuning: Resource) -> void:
	for curtain in [left, right]:
		curtain.position.y = origin.y
		curtain.size = Vector2(screen.x / 2.0 + tuning.curtain_overlap_pixels, screen.y)

static func animate(host: Node, left: TextureRect, right: TextureRect, origin: Vector2, screen: Vector2, tuning: Resource, close: bool) -> Tween:
	fit(left, right, origin, screen, tuning)
	var left_x := origin.x
	var right_x := origin.x + screen.x / 2.0
	if close:
		left.position.x = origin.x - left.size.x
		right.position.x = origin.x + screen.x
		for curtain in [left, right]:
			curtain.texture = tuning.curtain_texture
			curtain.show()
	else:
		left_x = origin.x - left.size.x
		right_x = origin.x + screen.x
	var animation := host.create_tween().set_parallel(true).set_trans(tuning.curtain_transition).set_ease(tuning.curtain_ease)
	animation.tween_property(left, "position:x", left_x, tuning.curtain_seconds)
	animation.tween_property(right, "position:x", right_x, tuning.curtain_seconds)
	return animation
