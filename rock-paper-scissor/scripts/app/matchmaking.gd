extends VBoxContainer
signal return_requested
signal match_ready(context: MatchContext)

@export var motion: SearchMotion
@onready var session: MatchSession = $Session
@onready var search: VBoxContainer = $Search
@onready var destination: Control = $Arena
@export var arena_fixture: ArenaFixture
var arena_condition: int = 0
@onready var card: Control = $Search/CardSpace/SearchCard
@onready var dots: Timer = $Dots
var ready_context: MatchContext
var transition: Tween
var dot_count: int = 0
var changing: bool = false
var ready_count: int = 0

func _ready() -> void:
	$Search/Leave.pressed.connect(_leave)
	$Arena.return_requested.connect(_return)
	match_ready.connect(_enter_arena)
	session.found.connect(_found)
	session.failed.connect(_failed)
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
	$Search/Leave.text = "Leave search"
	dot_count = 0
	$Search/Status.text = "Looking for Opponent"
	$Search/Status.modulate.a = 1.0
	$Search/DotLabel.text = ""
	card.start_motion()
	dots.start()
	session.set("scenario", scenario)
	session.begin(player)

func _tick_dots() -> void:
	dot_count = (dot_count + 1) % 4
	$Search/DotLabel.text = ".".repeat(dot_count)

func _leave() -> void:
	if changing or ready_context != null:
		return
	$Search/Leave.disabled = true
	session.cancel()
	if transition:
		transition.kill()
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
	card.stop_motion()
	transition = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	transition.tween_property(search, "modulate:a", 0.0, motion.fade_seconds)
	await transition.finished
	search.hide()
	destination.modulate.a = 0.0
	destination.show()
	match_ready.emit(context)
	transition = create_tween().set_trans(motion.transition).set_ease(motion.ease)
	transition.tween_property(destination, "modulate:a", 1.0, motion.fade_seconds)
	await transition.finished
	changing = false
	print("M02 handoff ready: generation=%d ready_count=%d transition completed" % [context.search_generation, ready_count])

func _failed(_generation: int, detail: String) -> void:
	dots.stop()
	card.stop_motion()
	$Search/Leave.text = "Return to menu"
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
	$Arena.begin(context, arena_condition)
