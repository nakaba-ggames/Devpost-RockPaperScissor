class_name MatchmakingSettings
extends Resource
@export_range(30.0, 45.0) var fallback_min_seconds: float = 30.0
@export_range(30.0, 45.0) var fallback_max_seconds: float = 45.0
## Unset production policy. The development adapter does not enforce ranking.
@export var rating_policy_configured: bool = false
@export var allowed_rating_gap: int = -1
@export var maximum_rating_gap: int = -1
@export var widening_points_per_second: float = -1.0
