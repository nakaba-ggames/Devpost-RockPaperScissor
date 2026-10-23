extends RefCounted
## Lossless compact translation of accepted RoundLog events, without a count cap.
const PHASES: Array[String] = ["option", "identity_claim", "switch_claim", "final_choice"]
const CARDS: Array[String] = ["Rock", "Paper", "Scissor"]

static func encode(snapshot: Dictionary, deployment_revision: String, chunk_size: int) -> Dictionary:
	var timings: Array = [{"phase": "option", "started": snapshot.optionStarted, "deadline": snapshot.optionDeadline, "locked": snapshot.optionLocked}]
	for phase in ["identity_claim", "switch_claim", "final_choice"]:
		var timing: Dictionary = snapshot.finalTiming
		if phase != "final_choice":
			timing = snapshot.claimTiming[phase]
		timings.append({"phase": phase, "started": timing.started, "deadline": timing.deadline, "locked": timing.locked})
	var actors: Array = []
	var events: Array = []
	for actor_index in range(snapshot.actors.size()):
		var actor: Dictionary = snapshot.actors[actor_index]
		actors.append({"actorId": actor.actorId, "startingOrder": actor.startingOrder.duplicate(), "initialCard": actor.initialCard, "identityClaim": actor.identityClaim, "switchClaim": actor.switchClaim, "finalCard": actor.finalCard})
		for event: Dictionary in actor.events:
			var phase_index := PHASES.find(event.phase)
			var value: String
			if event.phase == "option":
				value = event.payload.initialCard
			elif event.phase == "identity_claim":
				value = event.payload.identityClaim
			elif event.phase == "switch_claim":
				value = event.payload.switchClaim
			else:
				value = event.payload.finalCard
			var value_index := CARDS.find(value)
			if event.phase == "switch_claim":
				value_index = ["keep", "switch"].find(value)
			var kind := 0
			if event.kind == "default":
				kind = 1
			# Keep the accepted phase revision, sequence, value, timing and default.
			events.append([actor_index, phase_index, int(event.sequence), int(event.revision), int(event.elapsedMsec), value_index, kind])
	events.sort_custom(func(a: Array, b: Array) -> bool: return a[2] < b[2])
	var header := {"matchId": snapshot.matchId, "rulesRevision": deployment_revision, "condition": ["devil", "angel", "none"][int(snapshot.condition)], "phases": timings, "actors": actors}
	var header_json := JSON.stringify(header)
	var history_digest := header_json.sha256_text()
	var chunks: Array[String] = []
	var start := 0
	while start < events.size():
		var encoded := JSON.stringify(events.slice(start, start + maxi(1, chunk_size)))
		chunks.append(encoded)
		history_digest = (history_digest + "\n" + encoded.sha256_text()).sha256_text()
		start += maxi(1, chunk_size)
	var hex := history_digest.substr(0, 32)
	var upload_id := "%s-%s-%s-%s-%s" % [hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4), hex.substr(16, 4), hex.substr(20, 12)]
	return {"headerJson": header_json, "chunks": chunks, "historyDigest": history_digest, "uploadId": upload_id, "chunkCount": chunks.size()}
