extends RefCounted
## Reads only the detached accepted envelope, never UI bubbles or mutable RoundLog.
static func beats(submission: Dictionary, copy: Resource) -> Array[String]:
	var lines: Array[String] = []
	for phase in ["initial", "identity", "intention", "action"]:
		for actor in submission.history.actors:
			var name := "Player"
			var resolved: Dictionary = {}
			for recipient in submission.recipients:
				if recipient.actorId == actor.actorId:
					name = str(recipient.displayName)
			for result in submission.result.actors:
				if result.actorId == actor.actorId:
					resolved = result
			var truth: String = copy.truth_copy
			var action: String = copy.keep_copy
			var intention: String = copy.keep_copy
			if resolved.actualSwitch:
				action = copy.switch_copy
			if actor.switchClaim == "switch":
				intention = copy.switch_copy
			var template: String = copy.initial_copy
			var defaulted: bool = actor.get("defaulted", false)
			if phase == "identity":
				template = copy.identity_copy
				defaulted = actor.claimPhases.identity_claim.defaulted
				if not resolved.identityTruth:
					truth = copy.lie_copy
			elif phase == "intention":
				template = copy.intention_copy
				defaulted = actor.claimPhases.switch_claim.defaulted
				if not resolved.intentionTruth:
					truth = copy.lie_copy
			elif phase == "action":
				template = copy.action_copy
				defaulted = actor.finalState.defaulted
			var suffix := ""
			if defaulted:
				suffix = copy.default_copy
			lines.append(template.format({"name": name, "initial": actor.initialCard, "claim": actor.identityClaim, "intention": intention, "action": action, "final": actor.finalCard, "truth": truth, "default": suffix}))
	return lines
