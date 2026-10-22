class_name MatchContext
extends Resource
## M03 input only. No rules, result, persistent credit or verified peer.
@export var match_id: String = ""
@export var search_generation: int = 0
@export var local_player: MatchParticipant
@export var opponent: MatchParticipant
@export var transport: String = "scripted_development"
@export var development_only: bool = true
@export var persistent_credit_allowed: bool = false
