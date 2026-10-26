extends Control
## Independent offline composition root: no live startup or entry gate.
@onready var ui: GameUI = $UI
@onready var provider: ProfileProvider = $ProfileProvider
@export var first_play: Resource = preload("res://resources/presentation/offline_first_play.tres")
var regular_rules: ArenaRules

func _ready() -> void:
	if not OS.has_feature("editor"):
		push_error("Offline presentation is an editor-only development scene.")
		get_tree().quit(1)
		return
	regular_rules = ui.matchmaking.destination.coordinator.rules
	ui.get_node("%Play").pressed.connect(_configure_preview_round)
	ui.configure(provider)
	ui.connection_status("OFFLINE PREVIEW")
	for view_name in ["DetailedStats", "Records", "LeaderboardView", "QuestsView"]:
		ui.get_node(view_name + "/Content/Notice").text = "Preview data • nothing is saved"
	var intro_btn: Button = ui.get_node("%PresentationMode")
	intro_btn.text = "REPLAY TITLE INTRO"
	intro_btn.show()
	intro_btn.pressed.connect(func():
		ui.play_title_intro()
	)
	ui.get_node("%Play").text = "PLAY GAME !"
	ui.get_node("%ClearData").text = "RESET PREVIEW"
	ui.get_node("%ClearData").tooltip_text = "Reset preview • memory only"
	ui.get_node("%ArenaCondition").show()
	ui.get_node("%ArenaCondition").item_selected.connect(_condition_selected)
	ui.get_node("Margin/Stack/Body/Menu/FixtureNotice").text = "Example opponent statistics"
	ui.get_node("Margin/Stack/PreviewNotice").text = "SIMULATED SESSION • MEMORY ONLY"
	ui.matchmaking.before_arena.connect(provider.begin_preview_match)
	ui.matchmaking.destination.result_acknowledged.connect(provider.apply_acknowledged_result)
	provider.local_data_cleared.connect(_reset_preview)
	_start_preview()
	ui.play_title_intro()
	print("Presentation: Test-Human; offline title preview; all connections simulated")

func _start_preview() -> void:
	provider.begin_session()
	provider.enter_menu()
	ui.show_menu_immediately()

func _condition_selected(index: int) -> void:
	ui._play_btn_sfx()
	ui.matchmaking.arena_condition = index

func _reset_preview() -> void:
	ui.reset_data_views()
	_start_preview()

func _configure_preview_round() -> void:
	var first_match: bool = first_play.enabled and provider.profile != null and provider.profile.games_played == 0
	ui.matchmaking.session.set("first_match", first_match)
	# Duplicate only for the offline coordinator. Never edit the shared rules asset.
	var rules: ArenaRules = regular_rules.duplicate()
	if first_match:
		rules.option_seconds = first_play.decision_seconds
		rules.identity_claim_seconds = first_play.decision_seconds
		rules.switch_claim_seconds = first_play.decision_seconds
		rules.final_choice_seconds = first_play.decision_seconds
	ui.matchmaking.destination.coordinator.rules = rules
	print("Presentation decisions: %.1fs; first_match=%s; memory-only rules copy" % [rules.option_seconds, first_match])
