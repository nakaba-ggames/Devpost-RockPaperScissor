extends Control

@export var motion: MenuMotion
@onready var provider: ProfileProvider = $PreviewProvider
@onready var service: Node = $ServiceConnection
@onready var entry: VBoxContainer = %Entry
@onready var menu: VBoxContainer = %Menu
@onready var name_box: VBoxContainer = %NameBox
@onready var name_input: LineEdit = %DisplayName
@onready var continue_button: Button = %Continue
@onready var feedback: Label = %Feedback
var screen_tween: Tween
var feedback_tween: Tween
var can_continue: bool = false
var changing_screen: bool = false

func _ready() -> void:
	print("M01 engine: ", Engine.get_version_info().string)
	if OS.has_feature("web"):
		var browser_info = JavaScriptBridge.get_interface("navigator")
		print("M01 browser: ", browser_info.userAgent)
	provider.identity_ready.connect(_identity_ready)
	provider.menu_ready.connect(_menu_ready)
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
	%Play.pressed.connect(_temporary.bind("Play", "Matchmaking arrives in M02."))
	%Leaderboard.pressed.connect(_temporary.bind("Leaderboard", "Available in M07."))
	%Record.pressed.connect(_temporary.bind("Record", "Available in M07; layout reserved to the creator."))
	%Stats.pressed.connect(_temporary.bind("Detailed Stats", "Available in M07; layout reserved to the creator."))
	%Quests.pressed.connect(_temporary.bind("Quests", "Available in M08."))
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
	%EntryStatus.text = "Preparing local preview…"
	menu.hide()
	entry.show()
	entry.modulate.a = 1.0
	provider.begin_session()

func _identity_ready(profile: PreviewProfile) -> void:
	%RetryEntry.hide()
	%NewPreview.hide()
	if profile.display_name.is_empty():
		%EntryStatus.text = "Name your local preview"
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
	provider.enter_menu()

func _menu_ready(profile: PreviewProfile) -> void:
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
	name_input.clear()
	if screen_tween:
		screen_tween.kill()
	changing_screen = false
	_restart_entry()
	_fade_in(entry)
	_show_feedback("Local preview cleared. Enter a new name to start again.")

func _connection_changed(text: String) -> void:
	%ConnectionStatus.text = text
	%RetryConnection.visible = text.contains("failed") or text.contains("disconnected")
	_fade_in(%ConnectionStatus)
