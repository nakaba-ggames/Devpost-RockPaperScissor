extends Control
## Live composition root. Shared UI has no authority to start connections.
func _ready() -> void:
	$UI.configure($ConnectionRequirement/ProfileProvider, $ConnectionRequirement/Api, true)
	# Keep sandbox tools and development notices out of the live composition.
	$UI.get_node("%PresentationMode").hide()
	$UI.get_node("%ClearData").hide()
	$UI.get_node("Margin/Stack/Body/Menu/FixtureNotice").hide()
	$UI.get_node("Margin/Stack/PreviewNotice").hide()
	$UI.presentation_requested.connect(_open_presentation)
	$ConnectionRequirement.start($UI)

func _open_presentation() -> void:
	if not OS.has_feature("editor"):
		return
	$ConnectionRequirement.stop()
	get_tree().change_scene_to_file("res://scenes/development/presentation.tscn")
