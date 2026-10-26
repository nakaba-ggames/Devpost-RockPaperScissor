class_name GameUI
extends Control
## Shared visual structure and interactions. No identity or connection startup.
signal continue_requested
signal name_requested(display_name: String)
signal retry_entry_requested
signal recreate_requested
signal retry_connection_requested
signal presentation_requested

const SOUND_CONFIG = preload("res://resources/presentation/ui_sound_config.tres")

@export var motion: MenuMotion
@onready var entry: VBoxContainer = %Entry
@onready var menu: MenuPresentation = %Menu
@onready var name_box: VBoxContainer = %NameBox
@onready var name_input: LineEdit = %DisplayName
@onready var continue_button: Button = %Continue
@onready var feedback: Label = %Feedback
@onready var matchmaking: VBoxContainer = %Matchmaking
@onready var scrolling_bg: Control = $ScrollingBackground
@onready var title_intro: Control = $TitleIntroSequence
@onready var music: Node = $MusicDirector
var provider: ProfileProvider
var persistent_matches: bool = false
var menu_profile: PlayerProfile
var screen_tween: Tween
var feedback_tween: Tween
var can_continue: bool = false
var changing_screen: bool = false
var menu_homes: Dictionary = {}

func _ready() -> void:
	_apply_pixel_case(self)
	get_tree().node_added.connect(_pixel_node_added)
	%SearchScenario.hide()
	%ArenaCondition.hide()
	%SaveName.pressed.connect(_save_name)
	name_input.text_submitted.connect(_name_submitted)
	continue_button.pressed.connect(_request_continue)
	%RetryEntry.pressed.connect(func(): retry_entry_requested.emit())
	%NewPreview.pressed.connect(func(): recreate_requested.emit())
	%RetryConnection.pressed.connect(func(): retry_connection_requested.emit())
	%PresentationMode.pressed.connect(func(): presentation_requested.emit())
	%Play.pressed.connect(_play)
	matchmaking.return_requested.connect(_return_from_search)
	matchmaking.match_ready.connect(_arena_entered)
	%Leaderboard.pressed.connect(_open_data.bind($LeaderboardView))
	%Record.pressed.connect(_open_data.bind($Records))
	%Stats.pressed.connect(_open_data.bind($DetailedStats))
	%Quests.pressed.connect(_open_data.bind($QuestsView))

	if title_intro != null:
		title_intro.intro_completed.connect(_on_intro_completed)
		title_intro.pattern_background_activated.connect(music.play_menu)
	matchmaking.session.found.connect(music.fade_out)
	matchmaking.destination.get_node("Reveal").outcome_requested.connect(music.stop_for_result)
	matchmaking.destination.get_node("Reveal").cinematic_started.connect(music.fade_out)
	matchmaking.destination.get_node("Reveal").winner_revealed.connect(music.play_menu)

func _play_btn_sfx() -> void:
	SOUND_CONFIG.play(self, "tab_select")

func play_title_intro(wait_for_live_entry: bool = false) -> void:
	if changing_screen or title_intro.is_active:
		return
	reset_data_views()
	music.stop()
	can_continue = false
	menu.hide()
	entry.hide()
	matchmaking.hide()
	_arena_chrome(false)
	%ConnectionStatus.hide()
	title_intro.play_sequence(wait_for_live_entry)

func _on_intro_completed() -> void:
	if persistent_matches:
		# Keep the real naming/menu gate in charge after the title tap.
		entry.show()
		entry.modulate.a = 1.0
		_arena_chrome(true)
		%ConnectionStatus.show()
		_request_continue()
		return
	_arena_chrome(true)
	%ConnectionStatus.show()
	if menu_profile != null:
		_transition_to_menu()
	else:
		show_menu_immediately()

func configure(source: ProfileProvider, api: Node = null, saved_matches: bool = false) -> void:
	provider = source
	persistent_matches = saved_matches
	if api != null:
		matchmaking.session.api = api
	provider.menu_ready.connect(_menu_ready)
	provider.menu_snapshot_updated.connect(_quest_menu_snapshot)
	%ClearData.pressed.connect(provider.clear_local_data)

func _unhandled_input(event: InputEvent) -> void:
	if not can_continue or changing_screen:
		return
	if event is InputEventScreenTouch and event.pressed:
		_request_continue()
	elif event is InputEventMouseButton and event.pressed:
		_request_continue()
	elif event.is_action_pressed("ui_accept"):
		_request_continue()

func _request_continue() -> void:
	if can_continue and not changing_screen:
		continue_requested.emit()

func _save_name() -> void:
	name_requested.emit(name_input.text)

func _name_submitted(_text: String) -> void:
	_save_name()

func show_pending(text: String) -> void:
	if persistent_matches:
		title_intro.set_live_entry_state(text, false)
	can_continue = false
	continue_button.hide()
	name_box.hide()
	%EntryStatus.text = text

func show_continue(display_name: String) -> void:
	name_box.hide()
	%EntryStatus.text = "Ready"
	if not display_name.is_empty():
		%EntryStatus.text = "Welcome, " + display_name
	can_continue = true
	continue_button.show()
	if persistent_matches:
		title_intro.set_live_entry_state("", true)

func show_name_prompt() -> void:
	show_pending("Choose a display name (1–24 characters)")
	name_box.show()
	name_input.grab_focus()
	_fade_in(name_box)

func show_menu_immediately() -> void:
	can_continue = false
	entry.hide()
	matchmaking.hide()
	menu.show()
	menu.modulate.a = 1.0
	_restore_menu_visuals()
	_arena_chrome(true)
	%ConnectionStatus.show()
	changing_screen = false

func connection_status(text: String) -> void:
	%ConnectionStatus.text = text
	%RetryConnection.visible = text.contains("failed") or text.contains("disconnected")

func reset_data_views() -> void:
	for view in [$DetailedStats, $Records, $LeaderboardView, $QuestsView]:
		view.reset()
	name_input.clear()
	if screen_tween:
		screen_tween.kill()
	changing_screen = false

func _menu_ready(profile: PlayerProfile) -> void:
	%Play.disabled = false
	menu_profile = profile
	menu.present_profile(profile, provider)
	if entry.visible:
		_transition_to_menu()

func _transition_to_menu() -> void:
	changing_screen = true
	screen_tween = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	screen_tween.tween_property(entry, "modulate:a", 0.0, motion.fade_seconds)
	await screen_tween.finished
	entry.hide()
	await _animate_menu_entrance()
	changing_screen = false

func _animate_menu_entrance() -> void:
	music.play_menu()
	menu.show()
	menu.modulate.a = 1.0
	_restore_menu_visuals()
	await get_tree().process_frame
	var controls := _sliding_menu_controls()
	menu_homes.clear()
	for control in controls:
		menu_homes[control] = control.position
	var offsets := _menu_offscreen_offsets(controls)
	for index in controls.size():
		controls[index].position += offsets[index]
	for control in _fading_menu_controls():
		control.modulate.a = 0.0
	if screen_tween and screen_tween.is_valid():
		screen_tween.kill()
	screen_tween = create_tween().set_parallel(true).set_trans(motion.menu_transition).set_ease(motion.menu_enter_ease)
	for control in controls:
		screen_tween.tween_property(control, "position", menu_homes[control], motion.menu_enter_seconds)
	for control in _fading_menu_controls():
		screen_tween.tween_property(control, "modulate:a", 1.0, motion.menu_enter_seconds)
	await screen_tween.finished

func _animate_menu_exit_for_play() -> void:
	var controls := _sliding_menu_controls()
	var offsets := _menu_offscreen_offsets(controls)
	menu_homes.clear()
	for control in controls:
		menu_homes[control] = control.position
	if screen_tween and screen_tween.is_valid():
		screen_tween.kill()
	screen_tween = create_tween().set_parallel(true).set_trans(motion.menu_transition).set_ease(motion.menu_exit_ease)
	for index in controls.size():
		var control: Control = controls[index]
		screen_tween.tween_property(control, "position", control.position + offsets[index], motion.menu_exit_seconds)
	for control in _fading_menu_controls():
		screen_tween.tween_property(control, "modulate:a", 0.0, motion.menu_exit_seconds)
	await screen_tween.finished
	# Hide before restoring so the last frame cannot flash the menu onscreen.
	menu.hide()
	_restore_menu_visuals()

func _sliding_menu_controls() -> Array[Control]:
	return [$Margin/Stack/Body/Menu/Summary/Left, $Margin/Stack/Body/Menu/Summary/Right, %Play]

func _fading_menu_controls() -> Array[Control]:
	var controls: Array[Control] = menu.fading_controls()
	controls.append_array([$Margin/Stack/Brand, $Margin/Stack/Subtitle, %ConnectionStatus, $Margin/Stack/PreviewNotice])
	return controls

func _menu_offscreen_offsets(controls: Array[Control]) -> Array[Vector2]:
	var viewport_size := get_viewport_rect().size
	var left_rect := controls[0].get_global_rect()
	var right_rect := controls[1].get_global_rect()
	var play_rect := controls[2].get_global_rect()
	return [Vector2(-left_rect.end.x - motion.offscreen_margin, 0.0),
		Vector2(viewport_size.x - right_rect.position.x + motion.offscreen_margin, 0.0),
		Vector2(0.0, viewport_size.y - play_rect.position.y + motion.offscreen_margin)]

func _restore_menu_visuals() -> void:
	for control in menu_homes:
		if is_instance_valid(control):
			control.position = menu_homes[control]
	menu_homes.clear()
	for control in _fading_menu_controls():
		control.modulate.a = 1.0

func _fade_in(control: Control) -> void:
	control.modulate.a = 0.0
	var tween := create_tween().set_trans(motion.transition).set_ease(motion.ease)
	tween.tween_property(control, "modulate:a", 1.0, motion.fade_seconds)

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

func _play() -> void:
	if changing_screen or not menu.visible or menu_profile == null:
		return
	changing_screen = true
	feedback.modulate.a = 0.0

	await _animate_menu_exit_for_play()
	menu.hide()
	_arena_chrome(false)
	var player := MatchParticipant.new()
	player.player_id = menu_profile.player_id
	player.display_name = menu_profile.display_name
	player.overall_points = menu_profile.overall_points
	matchmaking.show()
	matchmaking.modulate.a = 0.0
	matchmaking.session.deployment_revision = provider.deployment_revision
	player.backend_verified = persistent_matches
	player.rating_source = "development_preview"
	if persistent_matches:
		player.rating_source = "backend"
	player.public_profile = {}
	matchmaking.destination.get_node("Presentation").set_local_streak(menu_profile.win_streak)
	matchmaking.destination.get_node("Presentation").set_local_persona(menu_profile.lie_count, menu_profile.honest_count)
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
	await _animate_menu_entrance()
	changing_screen = false
	print("M02 menu: return transition completed")

func _arena_entered(context: MatchContext) -> void:
	_arena_chrome(false)
	music.play_gameplay()

func _arena_chrome(shown: bool) -> void:
	$Margin/Stack/Brand.visible = shown and entry.visible
	$Margin/Stack/Subtitle.visible = shown and entry.visible
	$Margin/Stack/FeedbackSpace.visible = shown
	$Margin/Stack/PreviewNotice.visible = shown and not persistent_matches

func _open_data(view: Control) -> void:
	if changing_screen or not menu.visible:
		return
	view.open(provider)

func _quest_menu_snapshot(snapshot: Dictionary) -> void:
	menu.apply_snapshot(snapshot)
	if menu.visible:
		_fade_in(%DailyQuest)

func _apply_pixel_case(node: Node) -> void:
	if node is Label:
		node.uppercase = true
	elif node is Button:
		node.text = node.text.to_upper()
	if node is OptionButton:
		for index in range(node.item_count):
			node.set_item_text(index, node.get_item_text(index).to_upper())
	for child in node.get_children():
		_apply_pixel_case(child)

func _pixel_node_added(node: Node) -> void:
	if is_ancestor_of(node) and node is Label:
		node.uppercase = true
