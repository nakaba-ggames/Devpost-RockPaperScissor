class_name OptionCoordinator
extends Node
## Local authoritative coordinator; M09 supplies host/peer transport.
signal option_started
signal decision_accepted(actor_id: String, revised: bool)
signal option_locked
@export var rules: ArenaRules
var context: MatchContext
var history: RoundLog
var phase: String = "idle"
var match_started_msec: int = 0
var deadline_msec: int = 0
var sequence: int = 0

func begin_match(match_context: MatchContext, condition: int) -> bool:
	if rules == null or rules.option_seconds != 15.0:
		push_error("Option requires the approved 15-second rules resource.")
		return false
	context = match_context
	history = RoundLog.new()
	history.match_id = context.match_id
	history.rules_revision = rules.revision
	history.arena_condition = condition
	for participant in [context.local_player, context.opponent]:
		var actor_history := InitialChoiceHistory.new()
		actor_history.actor_id = participant.player_id
		actor_history.starting_order.assign(["Rock", "Paper", "Scissor"])
		actor_history.starting_order.shuffle()
		history.initial_choices.append(actor_history)
	context.round_log = history
	match_started_msec = Time.get_ticks_msec()
	sequence = 0
	phase = "intro"
	return true

func start_option() -> void:
	if phase != "intro":
		return
	history.option_started_elapsed_msec = elapsed_msec()
	deadline_msec = Time.get_ticks_msec() + int(rules.option_seconds * 1000.0)
	history.option_deadline_elapsed_msec = deadline_msec - match_started_msec
	phase = "option"
	option_started.emit()
	print("M03 Option started: full 15-second window; development context, no persistent credit")

func _process(_delta: float) -> void:
	if phase == "option" and Time.get_ticks_msec() >= deadline_msec:
		_lock()

func accept_choice(actor_id: String, choice: String) -> bool:
	if phase != "option":
		return false
	if Time.get_ticks_msec() >= deadline_msec:
		_lock()
		return false
	var actor_history := history.actor(actor_id)
	if actor_history == null or not choice in actor_history.starting_order:
		return false
	if actor_history.initial_card == choice:
		return false
	var revised := not actor_history.initial_card.is_empty()
	actor_history.initial_card = choice
	_record_event(actor_history, "decision", revised)
	decision_accepted.emit(actor_id, revised)
	return true

func _record_event(actor_history: InitialChoiceHistory, kind: String, revised: bool) -> void:
	sequence += 1
	actor_history.events.append({"matchId": context.match_id, "phase": "option", "actorId": actor_history.actor_id, "sequence": sequence, "revision": actor_history.events.size(), "kind": kind, "revised": revised, "elapsedMsec": elapsed_msec(), "optionElapsedMsec": elapsed_msec() - history.option_started_elapsed_msec, "payload": {"initialCard": actor_history.initial_card}})

func _lock() -> void:
	if phase != "option":
		return
	# Authority locks before any phase-end motion, never from tween completion.
	phase = "option_locked"
	history.option_locked_elapsed_msec = elapsed_msec()
	for actor_history in history.initial_choices:
		if actor_history.initial_card.is_empty():
			actor_history.initial_card = actor_history.starting_order[0]
			actor_history.defaulted = true
			_record_event(actor_history, "default", false)
		actor_history.locked = true
		actor_history.locked_elapsed_msec = history.option_locked_elapsed_msec
	option_locked.emit()
	print("M03 Option locked: elapsed=%dms; choices retained privately" % (history.option_locked_elapsed_msec - history.option_started_elapsed_msec))

func seconds_left() -> float:
	if phase != "option":
		return 0.0
	return maxf(0.0, (deadline_msec - Time.get_ticks_msec()) / 1000.0)

func elapsed_msec() -> int:
	return Time.get_ticks_msec() - match_started_msec

func finish_presentation() -> void:
	if phase == "option_locked":
		history.presentation_complete = true
		phase = "m03_complete"
		print("M03 presentation complete: M04 boundary; reservation retained")

func leave_context() -> void:
	phase = "idle"
	context = null
	history = null
