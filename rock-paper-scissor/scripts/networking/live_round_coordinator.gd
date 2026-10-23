extends "res://scripts/arena/option_coordinator.gd"
## Host acceptance, peer continuation and independently queried backend commitment.
const Wire = preload("res://scripts/networking/match_wire.gd")
var transport: Node
var starting: bool = false
var accepting: bool = false
var ready_phases: Dictionary = {}
var desired_phase: String = ""
var local_revision: Dictionary = {}
var accepted_revisions: Dictionary = {}
var state_revision: int = 0
var last_state_revision: int = -1
var clock_owner: bool = true
var clock_synced: bool = false
var clock_offset_msec: float = 0.0
var clock_wait: float = 0.0
var clock_request: int = -1
var departure_pending: bool = false
var disconnected: bool = false

func begin_match(value: MatchContext, _condition: int) -> bool:
	if value.session == null or value.round_log == null:
		return false
	context = value
	history = value.round_log
	if history.rules_revision != rules.revision:
		return false
	transport = value.session
	transport.coordinator = self
	if not transport.packet_received.is_connected(_packet):
		transport.packet_received.connect(_packet)
		transport.peer_departed.connect(_departed)
		transport.authority_changed.connect(_authority_changed)
	result_sink.bind_session(transport, self)
	phase = "intro"
	sequence = 0
	deadline_msec = 0
	match_started_msec = Time.get_ticks_msec()
	clock_owner = transport.authority()
	clock_synced = clock_owner
	clock_offset_msec = -float(Time.get_ticks_msec())
	clock_wait = 0.0
	clock_request = -1
	disconnected = false
	departure_pending = false
	state_revision = 0
	last_state_revision = -1
	desired_phase = ""
	ready_phases.clear()
	local_revision.clear()
	accepted_revisions.clear()
	return true

func elapsed_msec() -> int:
	if clock_owner:
		return super.elapsed_msec()
	return int(Time.get_ticks_msec() + clock_offset_msec)

func _process(delta: float) -> void:
	if context == null or disconnected:
		return
	if transport.authority():
		if not clock_owner:
			_adopt_clock()
		if departure_pending:
			_continue_survivor()
		super._process(delta)
	else:
		clock_wait -= delta
		if clock_wait <= 0.0:
			clock_wait = transport.settings.clock_sync_seconds
			clock_request = Time.get_ticks_msec()
			transport.send_peer("clock_ping", {"echo": clock_request})

func start_option() -> void:
	if starting:
		super.start_option()
	else:
		_ready_for("option")

func start_claim(name_of_phase: String) -> bool:
	if starting:
		return super.start_claim(name_of_phase)
	_ready_for(name_of_phase)
	return true

func start_final() -> bool:
	if starting:
		return super.start_final()
	_ready_for("final_choice")
	return true

func _ready_for(next_phase: String) -> void:
	if disconnected or context == null:
		return
	desired_phase = next_phase
	if not ready_phases.has(next_phase):
		ready_phases[next_phase] = {}
	ready_phases[next_phase][context.local_player.peer_id] = true
	if transport.authority():
		_try_start(next_phase)
	elif clock_synced:
		transport.send_peer("phase_ready", {}, next_phase, context.local_player.player_id)

func _try_start(next_phase: String) -> void:
	if not transport.authority() or not ready_phases.has(next_phase):
		return
	var ready: Dictionary = ready_phases[next_phase]
	if not ready.has(context.local_player.peer_id):
		return
	if transport.has_human_peer() and not ready.has(context.opponent.peer_id):
		return
	var expected := {"option": "intro", "identity_claim": "m03_complete", "switch_claim": "identity_claim_locked", "final_choice": "m04_complete"}
	if phase != expected.get(next_phase, ""):
		return
	starting = true
	if next_phase == "option":
		super.start_option()
	elif next_phase == "final_choice":
		super.start_final()
	else:
		super.start_claim(next_phase)
	starting = false
	_publish()
	print("M09 host phase=%s deadline=%d epoch=match-elapsed" % [phase, deadline_msec])

func accept_choice(actor: String, value: String) -> bool:
	return _decision_input(actor, value, "option")

func accept_claim(actor: String, value: String) -> bool:
	return _decision_input(actor, value, phase)

func accept_final(actor: String, value: String) -> bool:
	return _decision_input(actor, value, "final_choice")

func _decision_input(actor: String, value: String, required_phase: String) -> bool:
	if context == null or disconnected or phase != required_phase or not phase in ["option", "identity_claim", "switch_claim", "final_choice"]:
		return false
	if accepting:
		if phase == "option":
			return super.accept_choice(actor, value)
		if phase == "final_choice":
			return super.accept_final(actor, value)
		return super.accept_claim(actor, value)
	if actor != context.local_player.player_id:
		if not transport.authority() or not context.opponent.control_kind in ["fallback_bot", "takeover_bot"]:
			return false
	var key := phase + ":" + actor
	var revision: int = local_revision.get(key, 0) + 1
	local_revision[key] = revision
	if transport.authority():
		return _accept(actor, value, revision)
	transport.send_peer("decision", {"value": value}, phase, actor, revision)
	return true # UI feedback waits for the host's accepted snapshot.

func _accept(actor: String, value: String, revision: int) -> bool:
	var key := phase + ":" + actor
	if revision <= int(accepted_revisions.get(key, 0)) or elapsed_msec() >= deadline_msec:
		return false
	accepting = true
	var accepted := _decision_input(actor, value, phase)
	accepting = false
	if accepted:
		accepted_revisions[key] = revision
		print("M09 accepted phase=%s actor=%s revision=%d" % [phase, actor, revision])
		var own := history.actor(actor)
		var event: Dictionary = own.events.back()
		_publish({"actorId": actor, "revised": event.revised})
	return accepted

func _lock() -> void:
	super._lock()
	_publish()

func _lock_claim() -> void:
	super._lock_claim()
	_publish()

func _lock_final() -> void:
	# The backend sink publishes the frozen final state, then resolves commitment.
	super._lock_final()

func _state() -> Dictionary:
	return {"history": history.debug_snapshot(), "phase": phase, "deadline": deadline_msec, "elapsed": elapsed_msec(), "sequence": sequence, "revisions": accepted_revisions.duplicate(true), "actors": [Wire.participant(context.local_player), Wire.participant(context.opponent)], "resultId": context.result_id, "submission": context.result_submission.duplicate(true)}

func _publish(tell: Dictionary = {}) -> void:
	if context == null:
		return
	state_revision += 1
	var state := _state()
	state["tell"] = tell
	transport.send_peer("state", state, phase, "", state_revision)

func _apply_state(data: Dictionary, revision: int) -> void:
	if revision <= last_state_revision or data.history.rulesRevision != rules.revision or data.history.matchId != context.match_id:
		return
	last_state_revision = revision
	state_revision = revision
	var previous := phase
	history = Wire.read_history(data.history)
	context.round_log = history
	phase = data.phase
	if phase == desired_phase:
		desired_phase = ""
	deadline_msec = data.deadline
	sequence = data.sequence
	accepted_revisions = data.revisions.duplicate(true)
	for actor in data.actors:
		if actor.actorId == context.opponent.player_id:
			context.opponent.departed_before_commit = actor.departed
			context.opponent.takeover_side = actor.takeover
			context.opponent.control_kind = actor.control
	context.result_id = data.resultId
	if context.result_submission.is_empty() and not data.submission.is_empty():
		context.result_submission = data.submission.duplicate(true)
		result_sink.observe(context.result_submission)
	if not data.get("tell", {}).is_empty():
		print("M09 peer accepted phase=%s revised=%s" % [phase, data.tell.revised])
		decision_accepted.emit(data.tell.actorId, data.tell.revised)
	if previous != phase:
		if phase == "option_locked":
			option_locked.emit()
		elif phase in ["identity_claim_locked", "switch_claim_locked"]:
			claim_locked.emit(phase.trim_suffix("_locked"))
		elif phase == "final_locked":
			final_locked.emit()

func _packet(kind: String, envelope: Dictionary, sender: int) -> void:
	if context == null or disconnected:
		return
	var data: Dictionary = envelope.payload
	var host: int = transport.sdk.get_host()
	if kind == "clock_ping" and transport.authority():
		transport.send_peer("clock_pong", {"echo": data.echo, "elapsed": elapsed_msec()})
	elif kind == "clock_pong" and sender == host and not clock_owner and int(data.echo) == clock_request:
		var received_at := Time.get_ticks_msec()
		# NTP-style midpoint estimate: echo uses OUR clock; only host elapsed is
		# translated. Raw monotonic ticks from two processes are never compared.
		clock_offset_msec = float(data.elapsed) + (received_at - clock_request) / 2.0 - received_at
		clock_request = -1
		clock_synced = true
		if not desired_phase.is_empty():
			transport.send_peer("phase_ready", {}, desired_phase, context.local_player.player_id)
	elif kind == "phase_ready" and transport.authority() and envelope.actorId == context.opponent.player_id:
		var next_phase: String = envelope.phase
		if not next_phase in ["option", "identity_claim", "switch_claim", "final_choice"]:
			return
		if not ready_phases.has(next_phase):
			ready_phases[next_phase] = {}
		ready_phases[next_phase][sender] = true
		_try_start(next_phase)
	elif kind == "decision" and transport.authority() and envelope.phase == phase and envelope.actorId == context.opponent.player_id and transport.has_human_peer():
		_accept(envelope.actorId, str(data.get("value", "")), envelope.revision)
	elif kind == "state" and sender == host and not transport.authority() and context.result_receipt.is_empty():
		_apply_state(data, envelope.revision)

func publish_final_state() -> void:
	_publish()

func propose_result(submission: Dictionary) -> void:
	result_sink.submit(submission)

func _departed(peer: int) -> void:
	if context == null or peer != context.opponent.peer_id:
		return
	if not context.result_receipt.is_empty():
		print("M09 post-ACK peer departure retained match=%s digest=%s" % [context.match_id, JSON.stringify(context.result_submission).sha256_text()])
		return
	result_sink.record_departure(context.opponent.player_id)
	if not context.result_submission.is_empty():
		result_sink.retry(context.result_submission)
		return
	context.opponent.departed_before_commit = true
	context.opponent.takeover_side = true
	context.opponent.control_kind = "takeover_bot"
	departure_pending = true
	if transport.authority():
		_continue_survivor()

func _authority_changed() -> void:
	if context == null or disconnected or not transport.authority():
		return
	_adopt_clock()
	if departure_pending:
		_continue_survivor()

func _adopt_clock() -> void:
	if not clock_owner:
		var retained_elapsed := elapsed_msec()
		match_started_msec = Time.get_ticks_msec() - retained_elapsed
		clock_owner = true

func _continue_survivor() -> void:
	departure_pending = false
	_adopt_clock()
	print("M09 takeover retained phase=%s deadline=%d events=%d departedPeer=%d" % [phase, deadline_msec, sequence, context.opponent.peer_id])
	if not context.result_submission.is_empty():
		# Frozen delivery may already be committed. Resolve its status; never
		# rewrite eligibility based on a later transport departure.
		result_sink.retry(context.result_submission)
	else:
		for next_phase in ready_phases.keys():
			_try_start(next_phase)
		_publish()

func transport_lost() -> void:
	if context == null:
		return
	if not context.result_receipt.is_empty():
		return # Already-ACKed presentation remains usable in this client.
	disconnected = true
	context.local_player.departed_before_commit = true
	context.result_submission = {}
	phase = "departed"
	finalization_failed.emit(context.result_id, "Connection ended. This match cannot be resumed.", false)

func leave_context() -> void:
	if result_sink != null:
		result_sink.dispose()
	if transport != null:
		transport.coordinator = null
	super.leave_context()
