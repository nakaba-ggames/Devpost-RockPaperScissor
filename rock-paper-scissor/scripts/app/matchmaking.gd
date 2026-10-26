extends VBoxContainer
signal return_requested
signal match_ready(context: MatchContext)
signal before_arena(match_id: String)

const SOUND_CONFIG = preload("res://resources/presentation/ui_sound_config.tres")

@export var motion: SearchMotion
@onready var session: MatchSession = $Session
@onready var search: Control = $Search
@onready var destination: Control = $Arena
var arena_condition: int = 0
@onready var card: Control = $Search/CardSpace/SearchCard
@onready var dots: Timer = $Dots
var ready_context: MatchContext
var transition: Tween
var status_pulse_tween: Tween
var dot_count: int = 0
var changing: bool = false
var ready_count: int = 0

func _ready() -> void:
	$Search/Leave.pressed.connect(_leave)
	$Arena.return_requested.connect(_return)
	match_ready.connect(_enter_arena)
	session.found.connect(_found)
	session.failed.connect(_failed)
	session.cancelled.connect(_cancelled)
	dots.timeout.connect(_tick_dots)
	dots.wait_time = motion.dot_seconds

func start(player: MatchParticipant, scenario: int) -> void:
	if transition:
		transition.kill()
	changing = false
	ready_context = null
	destination.hide()
	search.show()
	search.modulate.a = 1.0
	$Search/Leave.disabled = false
	$Search/Leave.text = "CANCEL"
	dot_count = 0
	$Search/DotLabel.hide()

	# Step 4.2: *Searching for player* alpha 0 -> 1 -> 0 indefinitely over 1.5s
	$Search/Status.text = "SEARCHING FOR PLAYER"
	$Search/Status.modulate.a = 0.0
	if status_pulse_tween and status_pulse_tween.is_valid():
		status_pulse_tween.kill()
	status_pulse_tween = create_tween().set_loops().set_trans(motion.pulse_transition).set_ease(motion.pulse_ease)
	status_pulse_tween.tween_property($Search/Status, "modulate:a", motion.pulse_min_alpha, motion.pulse_half_seconds)
	status_pulse_tween.tween_property($Search/Status, "modulate:a", 1.0, motion.pulse_half_seconds)

	card.start_motion()
	dots.start()
	session.set("scenario", scenario)
	session.set("arena_condition", arena_condition)
	session.begin(player)

func _tick_dots() -> void:
	dot_count = (dot_count + 1) % 4
	$Search/DotLabel.text = ".".repeat(dot_count)

func _leave() -> void:
	if changing or ready_context != null:
		return
	$Search/Leave.disabled = true
	if status_pulse_tween and status_pulse_tween.is_valid():
		status_pulse_tween.kill()
	session.cancel()

func _cancelled(_generation: int) -> void:
	if transition:
		transition.kill()
	if status_pulse_tween and status_pulse_tween.is_valid():
		status_pulse_tween.kill()
	dots.stop()
	card.stop_motion()
	print("M02 ordinary leave: search invalidated before return transition")
	return_requested.emit()

func _found(context: MatchContext) -> void:
	if ready_context != null or session.reservation != context:
		return
	ready_context = context
	ready_count += 1
	changing = true
	$Search/Leave.disabled = true
	dots.stop()
	if status_pulse_tween and status_pulse_tween.is_valid():
		status_pulse_tween.kill()
	$Search/Status.modulate.a = 1.0
	$Search/Status.text = "PLAYER FOUND!"
	SOUND_CONFIG.play(self, "match_found")

	# Step 5.0: Card stops flipping, pop scale 1 -> 1.15 -> 1 with sword displayed
	if card.has_method("show_player_found"):
		await card.show_player_found()
	else:
		card.stop_motion()

	await get_tree().create_timer(motion.found_hold_seconds).timeout

	await $EntryCurtain.close_curtains()
	# Change the underlying composition while the curtain is opaque.
	# Step 5.1: Everything fades out
	transition = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	transition.tween_property(search, "modulate:a", 0.0, motion.fade_seconds)
	await transition.finished
	search.hide()

	# Step 5.2: Poker table shows from below, faded from 0.75, tweened into 1 at same time table comes from offscreen bottom
	destination.modulate.a = 0.0
	destination.show()
	match_ready.emit(context)

	var table_node: Control = destination.get_node_or_null("PokerTable")
	transition = create_tween().set_parallel(true).set_trans(motion.table_transition).set_ease(motion.table_ease)
	transition.tween_property(destination, "modulate:a", 1.0, motion.fade_seconds)
	if table_node != null:
		var target_position := table_node.position
		var below_screen := get_viewport_rect().size.y - table_node.global_position.y + motion.offscreen_margin
		table_node.position.y += below_screen
		table_node.modulate.a = motion.table_start_alpha
		transition.tween_property(table_node, "position", target_position, motion.table_enter_seconds)
		transition.tween_property(table_node, "modulate:a", 1.0, motion.table_enter_seconds)
	await transition.finished

	await $EntryCurtain.open_curtains()
	destination.uncover_entry()
	changing = false
	print("M02 handoff ready: generation=%d ready_count=%d transition completed" % [context.search_generation, ready_count])

func _failed(_generation: int, detail: String) -> void:
	if status_pulse_tween and status_pulse_tween.is_valid():
		status_pulse_tween.kill()
	dots.stop()
	card.stop_motion()
	$Search/Leave.text = "RETURN TO MENU"
	$Search/Leave.disabled = false
	transition = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	transition.tween_property($Search/Status, "modulate:a", 0.0, motion.fade_seconds)
	await transition.finished
	$Search/Status.text = detail
	transition = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	transition.tween_property($Search/Status, "modulate:a", 1.0, motion.fade_seconds)

func _return() -> void:
	if changing or ready_context == null:
		return
	session.release_match(ready_context.match_id)
	ready_context = null
	return_requested.emit()

func _enter_arena(context: MatchContext) -> void:
	# Quest activation precedes any local choice play.
	before_arena.emit(context.match_id)
	$Arena.begin(context, context.round_log.arena_condition, true)
