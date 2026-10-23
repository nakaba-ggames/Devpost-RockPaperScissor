class_name RoundResolver
extends RefCounted
## Pure structured-history calculation. No bubbles, profile writes or quests.
static func outcome(card: String, other: String) -> String:
	if card == other:
		return "draw"
	if (card == "Rock" and other == "Scissor") or (card == "Paper" and other == "Rock") or (card == "Scissor" and other == "Paper"):
		return "win"
	return "loss"

static func calculate(history: Dictionary, rules: ArenaRules) -> Dictionary:
	var results: Array[Dictionary] = []
	for index in range(2):
		var actor: Dictionary = history.actors[index]
		var other: Dictionary = history.actors[1 - index]
		var actual_switch: bool = actor.finalCard != actor.initialCard
		var identity_truth: bool = actor.identityClaim == actor.initialCard
		var intention_truth: bool = (actor.switchClaim == "switch") == actual_switch
		var honest := identity_truth and intention_truth
		var classification := "lying"
		if honest:
			classification = "honest"
		var result := outcome(actor.finalCard, other.finalCard)
		var points := rules.loss_points
		if result == "win":
			points = rules.win_points
		elif result == "draw":
			points = rules.draw_points
		var fulfilled: bool = (history.condition == 0 and not honest) or (history.condition == 1 and honest)
		if fulfilled and result != "loss":
			if history.condition == 0:
				if result == "win":
					points += rules.devil_win_bonus
				else:
					points += rules.devil_draw_bonus
			elif history.condition == 1:
				if result == "win":
					points += rules.angel_win_bonus
				else:
					points += rules.angel_draw_bonus
		# Awards are nonnegative deltas. No balance mutation occurs here.
		results.append({"actorId": actor.actorId, "outcome": result, "points": maxi(0, points), "identityTruth": identity_truth, "intentionTruth": intention_truth, "actualSwitch": actual_switch, "classification": classification, "lyingMatchCount": int(not honest), "honestMatchCount": int(honest), "conditionFulfilled": fulfilled, "initialCard": actor.initialCard, "finalCard": actor.finalCard})
	return {"rulesRevision": history.rulesRevision, "actors": results}

static func submission(context: MatchContext, rules: ArenaRules) -> Dictionary:
	var frozen := context.round_log.debug_snapshot().duplicate(true)
	var recipients: Array[Dictionary] = []
	for participant in [context.local_player, context.opponent]:
		var eligible: bool = not participant.departed_before_commit and not participant.takeover_side
		recipients.append({"actorId": participant.player_id, "displayName": participant.display_name, "controlKind": participant.control_kind, "departedBeforeCommit": participant.departed_before_commit, "takeoverSide": participant.takeover_side, "eventualEligible": eligible, "persistentCreditAllowed": context.persistent_credit_allowed})
	if context.result_id.is_empty():
		context.result_id = context.match_id + ":result"
	var revision := rules.revision
	var calculated := {}
	if context.development_only:
		calculated = calculate(frozen, rules)
	else:
		revision = context.deployment_revision
	var envelope := {"resultId": context.result_id, "matchId": context.match_id, "rulesRevision": revision, "authoredRulesRevision": rules.revision, "history": frozen, "result": calculated, "recipients": recipients, "developmentOnly": context.development_only, "persistentCreditAllowed": context.persistent_credit_allowed}

	freeze(envelope)
	return envelope

static func freeze(value: Variant) -> void:
	if value is Dictionary:
		for child in value.values():
			freeze(child)
		value.make_read_only()
	elif value is Array:
		for child in value:
			freeze(child)
		value.make_read_only()
