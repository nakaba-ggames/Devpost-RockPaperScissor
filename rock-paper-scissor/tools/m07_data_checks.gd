extends SceneTree
## BASIC M07 only: four controlled submissions, not real account history.
const Provider = preload("res://scripts/api/local_preview_provider.gd")
const Resolver = preload("res://scripts/results/round_resolver.gd")
var failures: Array[String] = []
var provider: Node
var examples: Array[Dictionary] = []

func _initialize() -> void:
	var runner := Node.new()
	runner.name = "M07DataChecks"
	root.add_child(runner)
	current_scene = runner
	provider = Provider.new()
	provider.motion = load("res://resources/presentation/menu_motion.tres")
	provider.roster = load("res://resources/development/leaderboard_roster.tres")
	runner.add_child(provider)
	provider.profile = PreviewProfile.new()
	provider.profile.player_id = "m07-controlled"
	provider.profile.display_name = "Controlled Preview"
	call_deferred("_run")

func check(condition: bool, detail: String) -> void:
	if not condition:
		failures.append(detail)

func actor(id: String, initial: String, claim: String, intention: String, final: String) -> Dictionary:
	return {"actorId": id, "initialCard": initial, "identityClaim": claim, "switchClaim": intention, "finalCard": final}

func apply(own: Dictionary, other: String) -> void:
	var id := "m07-controlled-%d" % examples.size()
	var history := {"rulesRevision": "m07-controlled", "condition": 0, "actors": [own, actor("fixture-peer", other, other, "keep", other)]}
	var rules = load("res://resources/arena/option_rules.tres")
	var submission := {"resultId": id, "matchId": id, "rulesRevision": history.rulesRevision, "history": history, "result": Resolver.calculate(history, rules), "developmentOnly": true, "persistentCreditAllowed": false, "recipients": [{"actorId": "m07-controlled", "displayName": "Controlled Preview", "eventualEligible": true, "departedBeforeCommit": false, "takeoverSide": false}, {"actorId": "fixture-peer", "displayName": "Velvet", "eventualEligible": true, "departedBeforeCommit": false, "takeoverSide": false}]}
	var receipt := {"resultId": id, "matchId": id, "rulesRevision": history.rulesRevision, "receiptId": "simulated:" + id, "simulated": true, "persisted": false, "serverAcknowledged": false, "persistentCreditAllowed": false}
	Resolver.freeze(submission)
	var applied: bool = provider.apply_acknowledged_result(submission, receipt)
	check(applied, "ordinary acknowledged fixture was not applied")
	examples.append({"submission": submission, "receipt": receipt})

func _run() -> void:
	var empty: Dictionary = await provider.request_stats()
	check(empty.winRate == null and empty.winningCards.Rock == null and empty.allegiance == "Human", "no-history N/A / Human")
	apply(actor("m07-controlled", "Rock", "Rock", "switch", "Paper"), "Rock")
	apply(actor("m07-controlled", "Scissor", "Rock", "switch", "Scissor"), "Paper")
	apply(actor("m07-controlled", "Rock", "Rock", "keep", "Rock"), "Rock")
	check(provider.profile.win_streak == 2, "draw must preserve streak")
	var tied: Dictionary = await provider.request_stats()
	check(tied.allegiance == "Angel / Devil", "winning allegiance tie")
	apply(actor("m07-controlled", "Rock", "Rock", "keep", "Rock"), "Paper")
	var stats: Dictionary = await provider.request_stats()
	check(stats.winRate == 50.0 and stats.winningCards.Paper == 50.0 and stats.winningCards.Scissor == 50.0 and stats.winningCards.Rock == 0.0, "final winning-card / total-win denominators")
	check(stats.lyingWinPercent == 50.0 and stats.honestWinPercent == 50.0 and stats.lieCount == 1 and stats.honestCount == 3 and stats.winStreak == 0, "claim counts / winning counts / loss streak")
	var page: Dictionary = await provider.request_records()
	var second: Dictionary = await provider.request_records(page.nextCursor)
	check(page.records.size() == 3 and second.records.size() == 1 and second.nextCursor == "", "record pagination")
	check(second.records[0].actors[0].initialCard == "Rock" and second.records[0].actors[0].finalCard == "Paper", "distinct initial/final record")
	for metric in provider.METRICS:
		var first: Dictionary = await provider.request_leaderboard(metric)
		var next: Dictionary = await provider.request_leaderboard(metric, first.nextCursor)
		check(first.entries.size() == 3 and next.entries.size() == 3 and not next.nextCursor.is_empty(), "leaderboard category page: " + metric)
	print("M07_BASIC " + JSON.stringify({"stats": stats, "records": page.records.size() + second.records.size(), "failures": failures}))
	# Export controlled data for scoped native UI observation, never personal history.
	var file := FileAccess.open("/tmp/m07_controlled.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(examples))
	quit(int(not failures.is_empty()))
