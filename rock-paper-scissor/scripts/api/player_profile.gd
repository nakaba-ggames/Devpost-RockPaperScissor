class_name PlayerProfile
extends Resource
## Shared view model populated by the selected provider; never holds credentials.

@export var player_id: String = ""
@export var display_name: String = ""
@export var overall_points: int = 0
@export var wins: int = 0
@export var games_played: int = 0
@export var win_streak: int = 0
@export var losses: int = 0
@export var draws: int = 0
@export var honest_wins: int = 0
@export var lying_wins: int = 0
@export var lie_count: int = 0
@export var honest_count: int = 0
@export var switch_count: int = 0
@export var initial_cards: Dictionary = {"Rock": 0, "Paper": 0, "Scissor": 0}
@export var final_cards: Dictionary = {"Rock": 0, "Paper": 0, "Scissor": 0}
@export var winning_cards: Dictionary = {"Rock": 0, "Paper": 0, "Scissor": 0}
@export var daily_quest_text: String = "Daily quest • loading"
