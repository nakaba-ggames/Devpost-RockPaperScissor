class_name MatchParticipant
extends Resource
## A snapshot: Overall Points is the eventual saved matchmaking rating.
@export var player_id: String = ""
@export var display_name: String = ""
@export var overall_points: int = 0
@export var rating_source: String = "development_preview"
@export var backend_verified: bool = false
@export var peer_id: int = -1
@export var control_kind: String = "local_preview"
