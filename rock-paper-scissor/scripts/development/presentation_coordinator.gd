extends "res://scripts/arena/option_coordinator.gd"
## Offline-only first-play rehearsal. The production coordinator still requires 15s.
const FIRST_PLAY = preload("res://resources/presentation/offline_first_play.tres")

func _decision_windows_allowed() -> bool:
	if super._decision_windows_allowed():
		return true
	if rules == null or not FIRST_PLAY.enabled:
		return false
	var seconds: float = FIRST_PLAY.decision_seconds
	return rules.option_seconds == seconds and rules.identity_claim_seconds == seconds and rules.switch_claim_seconds == seconds and rules.final_choice_seconds == seconds
