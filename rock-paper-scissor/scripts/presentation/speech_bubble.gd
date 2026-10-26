@tool
extends Control
## Keep Avatar/Panel/Text paths while exposing the portrait side in the Inspector.
@export_enum("Left", "Right") var portrait_side: int = 0:
	set(value):
		portrait_side = value
		if is_node_ready():
			_fit_contents()
@export var portrait_size: Vector2 = Vector2(46, 46)
@export var portrait_gap: float = 10.0
@export var text_margin: float = 12.0

func _ready() -> void:
	resized.connect(_fit_contents)
	_fit_contents()

func _fit_contents() -> void:
	var avatar: TextureRect = $Avatar
	var panel: Control = $Panel
	var text: Label = $Text
	for item in [avatar, panel, text]:
		item.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	avatar.size = portrait_size
	avatar.position = Vector2(0.0, (size.y - portrait_size.y) / 2.0)
	panel.position = Vector2(portrait_size.x + portrait_gap, 0.0)
	if portrait_side == 1:
		avatar.position.x = maxf(size.x - portrait_size.x, 0.0)
		panel.position.x = 0.0
	panel.size = Vector2(maxf(size.x - portrait_size.x - portrait_gap, 0.0), size.y)
	text.position = panel.position + Vector2(text_margin, 6.0)
	text.size = Vector2(maxf(panel.size.x - text_margin * 2.0, 0.0), maxf(size.y - 12.0, 0.0))
