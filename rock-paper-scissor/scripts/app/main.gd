extends Control

@export var motion: MenuMotion
@onready var provider: ProfileProvider = $ProfileProvider
@onready var service: Node = $ServiceConnection
@onready var entry: VBoxContainer = %Entry
@onready var menu: VBoxContainer = %Menu
@onready var name_box: VBoxContainer = %NameBox
@onready var name_input: LineEdit = %DisplayName
@onready var continue_button: Button = %Continue
@onready var feedback: Label = %Feedback
@onready var matchmaking: VBoxContainer = %Matchmaking
var menu_profile: PlayerProfile
var screen_tween: Tween
var feedback_tween: Tween
var can_continue: bool = false
var changing_screen: bool = false

func _ready() -> void:
	matchmaking.session.api = $Api
	%SearchScenario.hide()
	%ArenaCondition.hide()
	print("M01 engine: ", Engine.get_version_info().string)
	if OS.has_feature("web"):
		var browser_info = JavaScriptBridge.get_interface("navigator")
		print("M01 browser: ", browser_info.userAgent)
	provider.identity_ready.connect(_identity_ready)
	provider.menu_ready.connect(_menu_ready)
	provider.menu_snapshot_updated.connect(_quest_menu_snapshot)
	provider.request_failed.connect(_request_failed)
	provider.local_data_cleared.connect(_local_cleared)
	service.status_changed.connect(_connection_changed)
	_connection_changed(service.status_text)
	%SaveName.pressed.connect(_save_name)
	name_input.text_submitted.connect(_name_submitted)
	continue_button.pressed.connect(_continue)
	%ClearData.pressed.connect(provider.clear_local_data)
	%RetryEntry.pressed.connect(_restart_entry)
	%NewPreview.pressed.connect(provider.clear_local_data)
	%RetryConnection.pressed.connect(service.retry)
	%Play.pressed.connect(_play)
	matchmaking.return_requested.connect(_return_from_search)
	matchmaking.match_ready.connect(_arena_entered)
	%Leaderboard.pressed.connect(_open_data.bind($LeaderboardView))
	%Record.pressed.connect(_open_data.bind($Records))
	%Stats.pressed.connect(_open_data.bind($DetailedStats))
	%Quests.pressed.connect(_open_data.bind($QuestsView))
	_restart_entry()

func _unhandled_input(event: InputEvent) -> void:
	if can_continue and not changing_screen:
		if event is InputEventScreenTouch and event.pressed:
			_continue()
		elif event is InputEventMouseButton and event.pressed:
			_continue()
		elif event.is_action_pressed("ui_accept"):
			_continue()

func _restart_entry() -> void:
	can_continue = false
	name_box.hide()
	continue_button.hide()
	%RetryEntry.hide()
	%NewPreview.hide()
	%EntryStatus.text = "Connecting to your account…"
	menu.hide()
	entry.show()
	entry.modulate.a = 1.0
	provider.begin_session()

func _identity_ready(profile: PlayerProfile) -> void:
	%RetryEntry.hide()
	%NewPreview.hide()
	if profile.display_name.is_empty():
		%EntryStatus.text = "Choose a display name (1–24 characters)"
		name_box.show()
		name_input.grab_focus()
		_fade_in(name_box)
	else:
		name_box.hide()
		%EntryStatus.text = "Welcome, " + profile.display_name
		can_continue = true
		continue_button.show()
		_fade_in(continue_button)

func _save_name() -> void:
	provider.save_display_name(name_input.text)

func _name_submitted(_text: String) -> void:
	_save_name()

func _continue() -> void:
	if not can_continue or changing_screen:
		return
	can_continue = false
	%Play.disabled = true
	provider.enter_menu()

func _menu_ready(profile: PlayerProfile) -> void:
	%Play.disabled = false
	menu_profile = profile
	%PlayerName.text = profile.display_name
	%Points.text = "%d Overall Points" % profile.overall_points
	%DailyQuest.text = profile.daily_quest_text
	%WinRatio.text = "Win Ratio
N/A"
	if profile.games_played > 0:
		%WinRatio.text = "Win Ratio
%.0f%%" % (100.0 * profile.wins / profile.games_played)
	%WinStreak.text = "Win Streak
%d" % profile.win_streak
	var allegiance := "Human • no wins"
	if profile.lying_wins > profile.honest_wins:
		allegiance = "Devil"
	elif profile.honest_wins > profile.lying_wins:
		allegiance = "Angel"
	elif profile.wins > 0:
		allegiance = "Angel / Devil"
	$Margin/Stack/Body/Menu/Summary/Center/AllegianceLabel.text = allegiance + "\nTemp. icon"
	if entry.visible:
		_transition_to_menu()

func _transition_to_menu() -> void:
	# Temporary fade only; the creator owns final opening choreography.
	changing_screen = true
	screen_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	screen_tween.tween_property(entry, "modulate:a", 0.0, motion.fade_seconds)
	await screen_tween.finished
	entry.hide()
	menu.show()
	menu.modulate.a = 0.0
	screen_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	screen_tween.tween_property(menu, "modulate:a", 1.0, motion.fade_seconds)
	await screen_tween.finished
	changing_screen = false
	print("M01 menu: temporary transition completed")

func _fade_in(control: Control) -> void:
	control.modulate.a = 0.0
	var tween := create_tween().set_trans(motion.transition).set_ease(motion.ease)
	tween.tween_property(control, "modulate:a", 1.0, motion.fade_seconds)

func _temporary(destination: String, detail: String) -> void:
	_show_feedback(destination + " • " + detail)
	print("M01 navigation feedback: " + destination)

func _show_feedback(message: String) -> void:
	if feedback_tween:
		feedback_tween.kill()
	feedback.text = message
	feedback.modulate.a = 0.0
	feedback.position.y = -motion.feedback_offset
	feedback_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	feedback_tween.set_parallel(true)
	feedback_tween.tween_property(feedback, "modulate:a", 1.0, motion.fade_seconds)
	feedback_tween.tween_property(feedback, "position:y", 0.0, motion.fade_seconds)
	feedback_tween.set_parallel(false)
	feedback_tween.tween_interval(motion.feedback_seconds)
	feedback_tween.tween_property(feedback, "modulate:a", 0.0, motion.fade_seconds)

func _request_failed(kind: String, detail: String) -> void:
	_show_feedback(detail)
	if kind == "account":
		%EntryStatus.text = detail
		%NewPreview.show()
	elif kind == "server":
		%EntryStatus.text = detail
		%RetryEntry.show()
	# Name/storage errors keep the current screen so the user can retry.

func _local_cleared() -> void:
	for view in [$DetailedStats, $Records, $LeaderboardView, $QuestsView]:
		view.reset()
	name_input.clear()
	if screen_tween:
		screen_tween.kill()
	changing_screen = false
	_restart_entry()
	_fade_in(entry)
	_show_feedback("Local account data cleared. The previous backend account remains; creating a new account.")

func _connection_changed(text: String) -> void:
	%ConnectionStatus.text = text
	%RetryConnection.visible = text.contains("failed") or text.contains("disconnected")
	_fade_in(%ConnectionStatus)

func _play() -> void:
	if changing_screen or not menu.visible or menu_profile == null:
		return
	changing_screen = true
	feedback.modulate.a = 0.0
	screen_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	screen_tween.tween_property(menu, "modulate:a", 0.0, motion.fade_seconds)
	await screen_tween.finished
	menu.hide()
	var player := MatchParticipant.new()
	player.player_id = menu_profile.player_id
	player.display_name = menu_profile.display_name
	player.overall_points = menu_profile.overall_points
	matchmaking.show()
	matchmaking.modulate.a = 0.0
	matchmaking.session.deployment_revision = provider.deployment_revision
	player.backend_verified = true
	player.rating_source = "backend"
	player.public_profile = {}
	matchmaking.start(player, 0)
	screen_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	screen_tween.tween_property(matchmaking, "modulate:a", 1.0, motion.fade_seconds)
	await screen_tween.finished
	changing_screen = false
	print("M02 search: entry transition completed")

func _return_from_search() -> void:
	# Session invalidation/release happens synchronously before this animation.
	changing_screen = true
	if screen_tween:
		screen_tween.kill()
	screen_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	screen_tween.tween_property(matchmaking, "modulate:a", 0.0, motion.fade_seconds)
	await screen_tween.finished
	matchmaking.hide()
	%Play.disabled = true
	provider.enter_menu()
	_arena_chrome(true)
	menu.modulate.a = 0.0
	menu.show()
	screen_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	screen_tween.tween_property(menu, "modulate:a", 1.0, motion.fade_seconds)
	await screen_tween.finished
	changing_screen = false
	print("M02 menu: return transition completed")

func _arena_entered(context: MatchContext) -> void:
	_arena_chrome(false)

func _arena_chrome(shown: bool) -> void:
	$Margin/Stack/Brand.visible = shown
	$Margin/Stack/Subtitle.visible = shown
	$Margin/Stack/FeedbackSpace.visible = shown
	$Margin/Stack/PreviewNotice.visible = shown

func _open_data(view: Control) -> void:
	if changing_screen or not menu.visible:
		return
	view.open(provider)

func _quest_menu_snapshot(snapshot: Dictionary) -> void:
	%Points.text = "%d Overall Points" % snapshot.profile.overallPoints
	var daily: Dictionary = snapshot.dailyQuest
	if daily.is_empty():
		%DailyQuest.text = "Daily • unavailable"
	else:
		%DailyQuest.text = "Daily • %s  %d/%d • +%d" % [daily.title, daily.progress, daily.target, daily.rewardPoints]
	if menu.visible:
		_fade_in(%DailyQuest)
