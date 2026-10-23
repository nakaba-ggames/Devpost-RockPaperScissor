class_name MatchmakingSettings
extends Resource
@export_range(30.0, 45.0) var fallback_min_seconds: float = 30.0
@export_range(30.0, 45.0) var fallback_max_seconds: float = 45.0
## Unset production policy. The development adapter does not enforce ranking.
@export var rating_policy_configured: bool = false
@export var allowed_rating_gap: int = -1
@export var maximum_rating_gap: int = -1
@export var widening_points_per_second: float = -1.0
## Creator's jam policy: queue accepts all preview ratings (2026-10-23).
@export var restrict_rating_gap: bool = false
@export var bot_selection_configured: bool = false
@export var fallback_player_id: String = "dev-bot-ember"
@export var fallback_display_name: String = "Ember"
@export var fallback_overall_points: int = 0
@export var handshake_timeout_seconds: float = 30.0
@export var handshake_retry_seconds: float = 1.0
@export var cancellation_timeout_seconds: float = 10.0
@export var clock_sync_seconds: float = 2.0
@export var queue_tag: String = "devils-rps-m09-v1"
