class_name MatchContext
extends Resource
## Reservation-owned round/finalization handoff. No persistent credit or verified peer.
@export var match_id: String = ""
@export var search_generation: int = 0
@export var local_player: MatchParticipant
@export var opponent: MatchParticipant
@export var transport: String = "scripted_development"
@export var development_only: bool = true
@export var persistent_credit_allowed: bool = false
@export var round_log: RoundLog
# Stable identity and detached finalization data retained for M06/provider retries.
@export var result_id: String = ""
@export var result_submission: Dictionary = {}
@export var result_receipt: Dictionary = {}
