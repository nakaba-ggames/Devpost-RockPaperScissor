extends "res://scripts/results/result_sink.gd"
const Wire = preload("res://scripts/api/history_wire.gd")
var api: Node
var coordinator: Node
var frozen: Dictionary = {}
var wire: Dictionary = {}
var departures: Array = []
var pending_departures: Array[String] = []
var receipts: Dictionary = {}
var generation: int = 0
var delivering: bool = false
var delivery_started_msec: int = 0

func bind_session(session: Node, controller: Node) -> void:
	api = session.api
	coordinator = controller
	generation += 1
	delivering = false
	frozen = {}
	wire = {}
	departures = []
	pending_departures.clear()
	receipts.clear()

func submit(submission: Dictionary) -> void:
	if not coordinator.transport.authority():
		return
	observe(submission, true)
	coordinator.publish_final_state()

func observe(submission: Dictionary, should_submit: bool = false) -> void:
	if frozen.is_empty():
		delivery_started_msec = Time.get_ticks_msec()
		frozen = submission.duplicate(true)
		wire = Wire.encode(frozen.history, frozen.rulesRevision, api.settings.history_events_per_chunk)
		for row in frozen.recipients:
			if row.departedBeforeCommit:
				departures.append(row.actorId)
		departures.sort()
		var prepared: Dictionary = coordinator.context.result_submission.duplicate(true)
		prepared["historyDigest"] = wire.historyDigest
		preload("res://scripts/results/round_resolver.gd").freeze(prepared)
		coordinator.context.result_submission = prepared
	if not delivering and receipts.is_empty():
		_deliver(should_submit)

func _deliver(should_submit: bool) -> void:
	delivering = true
	var ticket := generation
	# Query first, including every retry/uncertainty and authority transfer.
	var response: Dictionary = await api.send("matches/result?matchId=" + frozen.matchId.uri_encode())
	if ticket != generation:
		return
	if not response.has("error") and response.status == "committed":
		_accept(response.savedResult)
		delivering = false
		return
	if response.has("error"):
		delivering = false
		failed.emit(frozen.resultId, str(response.error.message), bool(response.error.retryable))
		return
	if should_submit:
		for player_id in pending_departures.duplicate():
			response = await api.send("matches/result", HTTPClient.METHOD_POST, {"matchId": frozen.matchId, "departedPlayerId": player_id})
			if ticket != generation:
				return
			if response.has("error"):
				delivering = false
				failed.emit(frozen.resultId, "Departure status is uncertain. Retry this same match.", true)
				return
			pending_departures.erase(player_id)
			if response.status == "committed":
				_accept(response.savedResult)
				delivering = false
				return
		for index in range(wire.chunks.size()):
			response = await api.send("matches/history", HTTPClient.METHOD_POST, {"matchId": frozen.matchId, "uploadId": wire.uploadId, "index": index, "encodedEvents": wire.chunks[index]})
			if ticket != generation:
				return
			if response.has("error"):
				delivering = false
				failed.emit(frozen.resultId, str(response.error.message), bool(response.error.retryable))
				return
		response = await api.send("matches/finalize", HTTPClient.METHOD_POST, {"matchId": frozen.matchId, "rulesRevision": frozen.rulesRevision, "uploadId": wire.uploadId, "headerJson": wire.headerJson, "chunkCount": wire.chunkCount, "departures": departures})
		if ticket != generation:
			return
		if not response.has("error") and response.status == "committed":
			_accept(response.savedResult)
			delivering = false
			return
		# An uncertain write never awards locally or changes eligibility. A later
		# retry starts with GET on this exact match, even after the host departs.
		delivering = false
		var message := "Result is not confirmed. Retry to check this same match."
		var retryable := true
		if response.has("error"):
			message = response.error.message
			retryable = response.error.retryable
		failed.emit(frozen.resultId, message, retryable)
		return
	await get_tree().create_timer(api.settings.result_poll_seconds).timeout
	if ticket != generation:
		return
	delivering = false
	_deliver(coordinator.transport.authority())

func _accept(receipt: Dictionary) -> void:
	if receipt.get("matchId") != frozen.matchId or receipt.get("resultId") != frozen.resultId or receipt.get("rulesRevision") != frozen.rulesRevision or receipt.get("historyDigest") != wire.historyDigest or str(receipt.get("committedAt", "")).is_empty():
		failed.emit(frozen.resultId, "Committed history differs from the frozen round. Contact support.", false)
		return
	for departed in departures:
		if not receipt.departures.has(departed):
			failed.emit(frozen.resultId, "Committed eligibility differs from the frozen departure facts.", false)
			return
	var envelope := frozen.duplicate(true)
	for recipient in envelope.recipients:
		recipient.departedBeforeCommit = receipt.departures.has(recipient.actorId)
		recipient.takeoverSide = recipient.departedBeforeCommit
		for actor in receipt.actors:
			if actor.playerId == recipient.actorId:
				recipient.eventualEligible = actor.eligible
	var results: Array = []
	for row in receipt.actors:
		var result: Dictionary = row.duplicate(true)
		result.actorId = row.playerId
		for actor in receipt.history.actors:
			if actor.actorId == row.playerId:
				result.initialCard = actor.initialCard
				result.finalCard = actor.finalCard
		results.append(result)
	envelope.result = {"rulesRevision": receipt.rulesRevision, "actors": results}
	envelope.historyDigest = wire.historyDigest
	var confirmed := receipt.duplicate(true)
	confirmed.simulated = false
	confirmed.persisted = true
	confirmed.serverAcknowledged = true
	confirmed.persistentCreditAllowed = true
	coordinator.context.result_submission = envelope
	coordinator.context.result_receipt = confirmed
	receipts[frozen.resultId] = confirmed
	if api.timing_enabled:
		print("NetworkTiming settlement_ms=%d chunks=%d" % [Time.get_ticks_msec() - delivery_started_msec, wire.chunkCount])
	acknowledged.emit(frozen.resultId, confirmed.duplicate(true))
	print("M12 durable receipt before cinematic match=%s receipt=%s" % [receipt.matchId, receipt.receiptId])

func receipt_for(result_id: String) -> Dictionary:
	return receipts.get(result_id, {}).duplicate(true)

func retry(submission: Dictionary) -> void:
	if frozen.is_empty():
		observe(submission, coordinator.transport.authority())
	elif not delivering:
		_deliver(coordinator.transport.authority())

func dispose() -> void:
	generation += 1
	delivering = false

func record_departure(player_id: String) -> void:
	if not pending_departures.has(player_id):
		pending_departures.append(player_id)
	var ticket := generation
	var match_id: String = coordinator.context.match_id
	var response: Dictionary = await api.send("matches/result", HTTPClient.METHOD_POST, {"matchId": match_id, "departedPlayerId": player_id})
	if ticket != generation:
		return
	if response.has("error"):
		failed.emit(match_id + ":result", "Departure status is uncertain. Retry this same match.", true)
		return
	pending_departures.erase(player_id)
	if response.status == "committed" and not frozen.is_empty():
		_accept(response.savedResult)
	elif not frozen.is_empty() and not delivering:
		_deliver(coordinator.transport.authority())
