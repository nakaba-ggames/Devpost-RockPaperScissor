extends Control
@export var icons: Resource

func face_down() -> void:
	$Visual/EmblemHolder.show()
	$Icon.hide()
	$Face.hide()
	$Caption.hide()

func reveal_face(value: String, display_name: String) -> void:
	$Visual/EmblemHolder.hide()
	var texture: Texture2D = icons.rock_icon
	if value == "Paper":
		texture = icons.paper_icon
	elif value == "Scissor":
		texture = icons.scissor_icon
	$Icon.texture = texture
	$Icon.show()
	$Face.text = value
	tooltip_text = display_name + ": " + value
	$Face.hide()
	$Caption.text = display_name
	$Caption.show()
