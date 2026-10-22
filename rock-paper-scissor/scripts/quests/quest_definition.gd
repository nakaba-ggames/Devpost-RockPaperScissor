class_name QuestDefinition
extends Resource
## Authored content, independent of any player's assigned instance.
@export var definition_id: String = ""
@export var title: String = ""
@export_enum("play", "initial_card", "final_card", "win", "loss", "draw", "lie", "win_lying", "win_honest", "switch") var objective: String = "play"
@export_enum("Rock", "Paper", "Scissor") var card: String = "Scissor"
@export_range(1, 100000) var target: int = 1
@export_range(0, 100000) var reward_points: int = 0

func qualifies(actor: Dictionary, outcome: String) -> bool:
	var switched: bool = actor.initialCard != actor.finalCard
	var lying: bool = actor.identityClaim != actor.initialCard or ((actor.switchClaim == "switch") != switched)
	if objective == "initial_card":
		return actor.initialCard == card
	elif objective == "final_card":
		return actor.finalCard == card
	elif objective == "win" or objective == "loss" or objective == "draw":
		return outcome == objective
	elif objective == "lie":
		return lying
	elif objective == "win_lying":
		return outcome == "win" and lying
	elif objective == "win_honest":
		return outcome == "win" and not lying
	elif objective == "switch":
		return switched
	return objective == "play"
