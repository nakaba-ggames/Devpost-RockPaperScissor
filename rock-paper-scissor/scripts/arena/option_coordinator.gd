class_name OptionCoordinator
extends Node
const ResultSink = preload("res://scripts/results/result_sink.gd")
const RoundResolver = preload("res://scripts/results/round_resolver.gd")
## Local authoritative coordinator; M09 supplies host/peer transport.
signal option_started
signal decision_accepted(actor_id: String, revised: bool)
signal claim_started(phase_name: String)
signal claim_locked(phase_name: String)
signal final_locked
signal round_ready(context: MatchContext)
signal finalization_failed(result_id: String, detail: String, retryable: bool)
@export var result_sink: ResultSink
signal option_locked
@export var rules: ArenaRules
var context: MatchContext
var history: RoundLog
var phase: String = "idle"
var match_started_msec: int = 0
var deadline_msec: int = 0
var sequence: int = 0

func begin_match(match_context: MatchContext, condition: int) -> bool:
	if not _decision_windows_allowed():
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
	deadline_msec = history.option_started_elapsed_msec + int(rules.option_seconds * 1000.0)
	history.option_deadline_elapsed_msec = deadline_msec
	phase = "option"
	option_started.emit()
	print("M03 Option started: full %.0f-second window; accepted history retained" % rules.option_seconds)

func _process(_delta: float) -> void:
	if elapsed_msec() < deadline_msec:
		return
	if phase == "option":
		_lock()
	elif phase in ["identity_claim", "switch_claim"]:
		_lock_claim()
	elif phase == "final_choice":
		_lock_final()

func accept_choice(actor_id: String, choice: String) -> bool:
	if phase != "option":
		return false
	if elapsed_msec() >= deadline_msec:
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
	var event_time := elapsed_msec()
	if kind == "default":
		event_time = history.option_locked_elapsed_msec
	actor_history.events.append({"matchId": context.match_id, "phase": "option", "actorId": actor_history.actor_id, "sequence": sequence, "revision": actor_history.events.size(), "kind": kind, "revised": revised, "elapsedMsec": event_time, "optionElapsedMsec": event_time - history.option_started_elapsed_msec, "payload": {"initialCard": actor_history.initial_card}})

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
	if not phase in ["option", "identity_claim", "switch_claim", "final_choice"]:
		return 0.0
	return maxf(0.0, (deadline_msec - elapsed_msec()) / 1000.0)

func elapsed_msec() -> int:
	return Time.get_ticks_msec() - match_started_msec

func finish_presentation() -> void:
	if phase == "option_locked":
		history.presentation_complete = true
		phase = "m03_complete"
		print("Option presentation complete; same context and reservation retained")

func leave_context() -> void:
	phase = "idle"
	context = null
	history = null

func start_claim(phase_name: String) -> bool:
	if phase_name == "identity_claim" and phase != "m03_complete":
		return false
	if phase_name == "switch_claim" and phase != "identity_claim_locked":
		return false
	if not phase_name in ["identity_claim", "switch_claim"]:
		return false
	var duration := rules.identity_claim_seconds
	if phase_name == "switch_claim":
		duration = rules.switch_claim_seconds
	var started := elapsed_msec()
	deadline_msec = started + int(duration * 1000.0)
	history.claim_timing[phase_name] = {"started": started, "deadline": deadline_msec, "locked": -1}
	for actor_history in history.initial_choices:
		actor_history.claim_phases[phase_name] = {"defaulted": false, "locked": false, "lockedElapsedMsec": -1, "events": []}
	phase = phase_name
	claim_started.emit(phase_name)
	print("M04 %s started: full %.0f-second window" % [phase_name, duration])
	return true

func accept_claim(actor_id: String, claim: String) -> bool:
	if not phase in ["identity_claim", "switch_claim"]:
		return false
	if elapsed_msec() >= deadline_msec:
		_lock_claim()
		return false
	var actor_history := history.actor(actor_id)
	if actor_history == null:
		return false
	var previous := actor_history.identity_claim
	if phase == "identity_claim":
		if not claim in ["Rock", "Paper", "Scissor"]:
			return false
	else:
		if not claim in ["keep", "switch"]:
			return false
		previous = actor_history.switch_claim
	if previous == claim:
		return false
	if phase == "identity_claim":
		actor_history.identity_claim = claim
	else:
		actor_history.switch_claim = claim
	var revised := not previous.is_empty()
	_record_claim_event(actor_history, "decision", revised)
	decision_accepted.emit(actor_id, revised)
	return true

func _record_claim_event(actor_history: InitialChoiceHistory, kind: String, revised: bool) -> void:
	sequence += 1
	var state: Dictionary = actor_history.claim_phases[phase]
	var payload := {"identityClaim": actor_history.identity_claim}
	if phase == "switch_claim":
		payload = {"switchClaim": actor_history.switch_claim}
	var event_time := elapsed_msec()
	if kind == "default":
		event_time = history.claim_timing[phase].locked
	var event := {"matchId": context.match_id, "phase": phase, "actorId": actor_history.actor_id, "sequence": sequence, "revision": state.events.size(), "kind": kind, "revised": revised, "elapsedMsec": event_time, "phaseElapsedMsec": event_time - int(history.claim_timing[phase].started), "payload": payload}
	state.events.append(event)
	actor_history.events.append(event)

func _lock_claim() -> void:
	var locked_phase := phase
	if not locked_phase in ["identity_claim", "switch_claim"]:
		return
	# Close authority first. Defaults/events use the saved phase, never a tween.
	var locked_at := elapsed_msec()
	history.claim_timing[locked_phase].locked = locked_at
	for actor_history in history.initial_choices:
		var empty := actor_history.identity_claim.is_empty()
		if locked_phase == "switch_claim":
			empty = actor_history.switch_claim.is_empty()
		if empty:
			if locked_phase == "identity_claim":
				actor_history.identity_claim = actor_history.initial_card
			else:
				actor_history.switch_claim = "keep"
			actor_history.claim_phases[locked_phase].defaulted = true
			_record_claim_event(actor_history, "default", false)
		actor_history.claim_phases[locked_phase].locked = true
		actor_history.claim_phases[locked_phase].lockedElapsedMsec = locked_at
	phase = locked_phase + "_locked"
	claim_locked.emit(locked_phase)
	print("M04 %s locked after %dms" % [locked_phase, locked_at - int(history.claim_timing[locked_phase].started)])

func finish_claims_presentation() -> void:
	if phase == "switch_claim_locked":
		history.claims_presentation_complete = true
		phase = "m04_complete"
		print("M04 complete: M05 boundary; context/history/reservation retained; no round saved")

func _ready() -> void:
	if result_sink != null:
		result_sink.acknowledged.connect(_receipt)
		result_sink.failed.connect(_result_failed)

func start_final() -> bool:
	if phase != "m04_complete" or not history.claims_presentation_complete:
		return false
	var started := elapsed_msec()
	deadline_msec = started + int(rules.final_choice_seconds * 1000.0)
	history.final_timing = {"started": started, "deadline": deadline_msec, "locked": -1}
	for actor_history in history.initial_choices:
		actor_history.final_state = {"defaulted": false, "locked": false, "lockedElapsedMsec": -1, "events": []}
	phase = "final_choice"
	print("M05 final choice started: full %.0f-second window" % rules.final_choice_seconds)
	return true

func accept_final(actor_id: String, choice: String) -> bool:
	if phase != "final_choice":
		return false
	if elapsed_msec() >= deadline_msec:
		_lock_final()
		return false
	var actor_history := history.actor(actor_id)
	if actor_history == null or not choice in actor_history.starting_order or actor_history.final_card == choice:
		return false
	var revised := not actor_history.final_card.is_empty()
	actor_history.final_card = choice
	_record_final_event(actor_history, "decision", revised)
	decision_accepted.emit(actor_id, revised)
	return true

func _record_final_event(actor_history: InitialChoiceHistory, kind: String, revised: bool, accepted_msec: int = -1) -> void:
	sequence += 1
	var event_time := elapsed_msec() if accepted_msec < 0 else accepted_msec
	if kind == "default":
		event_time = history.final_timing.locked
	var event := {"matchId": context.match_id, "phase": "final_choice", "actorId": actor_history.actor_id, "sequence": sequence, "revision": actor_history.final_state.events.size(), "kind": kind, "revised": revised, "elapsedMsec": event_time, "phaseElapsedMsec": event_time - int(history.final_timing.started), "payload": {"finalCard": actor_history.final_card}}
	actor_history.final_state.events.append(event)
	actor_history.events.append(event)

func _lock_final() -> void:
	if phase != "final_choice":
		return
	phase = "final_locked"
	history.final_timing.locked = elapsed_msec()
	for actor_history in history.initial_choices:
		if actor_history.final_card.is_empty():
			actor_history.final_card = actor_history.starting_order[0]
			actor_history.final_state.defaulted = true
			_record_final_event(actor_history, "default", false)
		actor_history.final_state.locked = true
		actor_history.final_state.lockedElapsedMsec = history.final_timing.locked
	# Freeze detached history/eligibility before presentation; stable ID for M06 retry.
	context.result_submission = RoundResolver.submission(context, rules)
	if result_sink != null:
		result_sink.submit(context.result_submission)
	else:
		_result_failed(context.result_id, "Result sink missing.", false)
	print("M12 final locked after %dms; history and eligibility frozen for delivery" % (history.final_timing.locked - history.final_timing.started))
	final_locked.emit()

func _receipt(result_id: String, receipt: Dictionary) -> void:
	if context == null or context.result_id != result_id:
		return
	context.result_receipt = receipt.duplicate(true)
	print("M05 receipt: simulated=%s persisted=%s" % [receipt.get("simulated", false), receipt.get("persisted", false)])

func _result_failed(result_id: String, detail: String, retryable: bool) -> void:
	finalization_failed.emit(result_id, detail, retryable)

func finish_final_presentation() -> void:
	if phase != "final_locked":
		return
	history.final_presentation_complete = true
	phase = "m05_complete"
	round_ready.emit(context)
	print("M12 round closed; receipt gate controls cinematic; reservation retained")

func _decision_windows_allowed() -> bool:
	return rules != null and rules.option_seconds == 15.0 and rules.identity_claim_seconds == 15.0 and rules.switch_claim_seconds == 15.0 and rules.final_choice_seconds == 15.0
