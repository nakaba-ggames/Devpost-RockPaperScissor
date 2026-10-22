class_name LocalBotPolicy
extends RefCounted
const BotPersonality = preload("res://scripts/resources/bot_personality.gd")
## This policy never receives a coordinator, MatchContext or human history.
var personality: BotPersonality
var rng := RandomNumberGenerator.new()
var planned_final: String = ""

func schedule() -> Dictionary:
	return {"decision": rng.randf_range(personality.decision_seconds.x, personality.decision_seconds.y), "revision": rng.randf_range(personality.revision_seconds.x, personality.revision_seconds.y), "willRevise": rng.randf() < personality.revision_chance}

func choose(input: Dictionary) -> String:
	var own: Dictionary = input.own
	var phase: String = input.phase
	if phase == "option":
		return _card("")
	if phase == "identity_claim":
		if rng.randf() < personality.identity_lie_chance:
			return _card(own.initialCard)
		return own.initialCard
	if phase == "switch_claim":
		planned_final = own.initialCard
		if rng.randf() < personality.switch_chance:
			planned_final = _card(own.initialCard)
		var intends_switch: bool = planned_final != own.initialCard
		if rng.randf() < personality.intention_lie_chance:
			intends_switch = not intends_switch
		if intends_switch:
			return "switch"
		return "keep"
	if planned_final.is_empty():
		planned_final = own.initialCard
	# Final revisions may reconsider; only the locked final determines switching.
	if input.revision:
		planned_final = own.initialCard
		if rng.randf() < personality.switch_chance:
			planned_final = _card(own.initialCard)
	return planned_final

func _card(excluded: String) -> String:
	var cards: Array[String] = ["Rock", "Paper", "Scissor"]
	var total := 0.0
	for index in range(3):
		if cards[index] != excluded:
			total += maxf(0.0, personality.choice_weights[index])
	var roll := rng.randf() * total
	for index in range(3):
		if cards[index] == excluded:
			continue
		roll -= maxf(0.0, personality.choice_weights[index])
		if roll < 0.0:
			return cards[index]
	for card in cards:
		if card != excluded:
			return card
	return "Rock"
