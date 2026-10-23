extends RefCounted
## Detached wire data only. Hidden history is never a presentation/policy input.
static func participant(value: MatchParticipant) -> Dictionary:
	return {"actorId": value.player_id, "name": value.display_name, "rating": value.overall_points, "peerId": value.peer_id, "control": value.control_kind, "departed": value.departed_before_commit, "takeover": value.takeover_side}

static func read_participant(value: Dictionary) -> MatchParticipant:
	var result := MatchParticipant.new()
	result.player_id = value.actorId
	result.display_name = value.name
	result.overall_points = value.rating
	result.peer_id = value.peerId
	result.control_kind = value.control
	result.departed_before_commit = value.get("departed", false)
	result.takeover_side = value.get("takeover", false)
	return result

static func read_history(value: Dictionary) -> RoundLog:
	var result := RoundLog.new()
	result.match_id = value.matchId
	result.rules_revision = value.rulesRevision
	result.arena_condition = value.condition
	result.option_started_elapsed_msec = value.optionStarted
	result.option_deadline_elapsed_msec = value.optionDeadline
	result.option_locked_elapsed_msec = value.optionLocked
	result.claim_timing = value.claimTiming.duplicate(true)
	result.final_timing = value.finalTiming.duplicate(true)
	result.presentation_complete = value.presentationComplete
	result.claims_presentation_complete = value.claimsPresentationComplete
	result.final_presentation_complete = value.finalPresentationComplete
	for actor in value.actors:
		var history := InitialChoiceHistory.new()
		history.actor_id = actor.actorId
		history.starting_order.assign(actor.startingOrder)
		history.initial_card = actor.initialCard
		history.identity_claim = actor.identityClaim
		history.switch_claim = actor.switchClaim
		history.final_card = actor.finalCard
		history.final_state = actor.finalState.duplicate(true)
		history.claim_phases = actor.claimPhases.duplicate(true)
		history.events.assign(actor.events.duplicate(true))
		history.defaulted = actor.defaulted
		history.locked = actor.locked
		history.locked_elapsed_msec = actor.lockedElapsedMsec
		result.initial_choices.append(history)
	return result
