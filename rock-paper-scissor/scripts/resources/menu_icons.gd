extends Resource
@export var leaderboard: Texture2D
@export var records: Texture2D
@export var stats: Texture2D
@export var quests: Texture2D
@export var trophy: Texture2D
@export var crown: Texture2D
@export var result_win: Texture2D
@export var result_draw: Texture2D
@export var result_loss: Texture2D

func for_view(kind: String) -> Texture2D:
	if kind == "leaderboard":
		return leaderboard
	if kind == "records":
		return records
	if kind == "quests":
		return quests
	return stats
