class_name PreviewProfile
extends Resource
## Development data only. Never an authenticated backend profile.

@export var player_id: String = ""
@export var display_name: String = ""
@export var overall_points: int = 0
@export var wins: int = 0
@export var games_played: int = 0
@export var win_streak: int = 0
@export var daily_quest_text: String = "Daily quest • not available in M01"
