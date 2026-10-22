class_name RoundLog
extends Resource
## In-memory decision history. No result/persistence implied.
@export var match_id: String = ""
@export var rules_revision: String = ""
@export var arena_condition: int = 0
@export var initial_choices: Array[InitialChoiceHistory] = []
@export var option_started_elapsed_msec: int = -1
@export var option_deadline_elapsed_msec: int = -1
@export var option_locked_elapsed_msec: int = -1
@export var claim_timing: Dictionary = {}
@export var claims_presentation_complete: bool = false
@export var presentation_complete: bool = false

func actor(actor_id: String) -> InitialChoiceHistory:
	for history in initial_choices:
		if history.actor_id == actor_id:
			return history
	return null

func debug_snapshot() -> Dictionary:
	# Explicit inspection only. Never bind this hidden snapshot to normal UI.
	var actors: Array[Dictionary] = []
	for history in initial_choices:
		actors.append({"actorId": history.actor_id, "startingOrder": history.starting_order.duplicate(), "initialCard": history.initial_card, "identityClaim": history.identity_claim, "switchClaim": history.switch_claim, "claimPhases": history.claim_phases.duplicate(true), "events": history.events.duplicate(true), "defaulted": history.defaulted, "locked": history.locked, "lockedElapsedMsec": history.locked_elapsed_msec})
	return {"matchId": match_id, "rulesRevision": rules_revision, "condition": arena_condition, "optionStarted": option_started_elapsed_msec, "optionDeadline": option_deadline_elapsed_msec, "optionLocked": option_locked_elapsed_msec, "presentationComplete": presentation_complete, "claimTiming": claim_timing.duplicate(true), "claimsPresentationComplete": claims_presentation_complete, "actors": actors}
