extends Control
## Independent offline composition root: no live startup or entry gate.
@onready var ui: GameUI = $UI
@onready var provider: ProfileProvider = $ProfileProvider

func _ready() -> void:
	if not OS.has_feature("editor"):
		push_error("Offline presentation is an editor-only development scene.")
		get_tree().quit(1)
		return
	ui.configure(provider)
	ui.connection_status("OFFLINE PRESENTATION • nothing is saved")
	ui.get_node("%PresentationMode").hide()
	ui.get_node("%Play").text = "Play bot now"
	ui.get_node("%ClearData").text = "Reset preview • memory only"
	ui.get_node("%ArenaCondition").show()
	ui.get_node("%ArenaCondition").item_selected.connect(_condition_selected)
	ui.get_node("Margin/Stack/Body/Menu/FixtureNotice").text = "Offline • example opponent statistics • no saved credit"
	ui.get_node("Margin/Stack/PreviewNotice").text = "PRESENTATION PREVIEW • simulated session only"
	ui.matchmaking.before_arena.connect(provider.begin_preview_match)
	ui.matchmaking.destination.result_acknowledged.connect(provider.apply_acknowledged_result)
	provider.local_data_cleared.connect(_reset_preview)
	_start_preview()
	print("Presentation: Test-Human ready immediately; no connection controller or intro")

func _start_preview() -> void:
	provider.begin_session()
	provider.enter_menu()
	ui.show_menu_immediately()

func _condition_selected(index: int) -> void:
	ui.matchmaking.arena_condition = index

func _reset_preview() -> void:
	ui.reset_data_views()
	_start_preview()
