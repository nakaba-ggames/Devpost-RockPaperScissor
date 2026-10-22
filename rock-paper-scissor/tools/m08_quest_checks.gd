extends SceneTree
## BASIC M08 only. Isolated synthetic rule checks, never normal account history.
const Coordinator = preload("res://scripts/quests/preview_quest_coordinator.gd")
const Catalogue = preload("res://scripts/quests/quest_catalogue.gd")
const Clock = preload("res://scripts/quests/preview_clock.gd")
const Definition = preload("res://scripts/quests/quest_definition.gd")
const Provider = preload("res://scripts/api/local_preview_provider.gd")
const Resolver = preload("res://scripts/results/round_resolver.gd")
var failures: Array[String] = []
var evidence: Dictionary = {"label": "M08 isolated development fixtures"}
var serial: int = 0

func _initialize() -> void:
	var runner := Node.new()
	runner.name = "M08QuestChecks"
	root.add_child(runner)
	current_scene = runner
	call_deferred("_run")

func check(condition: bool, detail: String) -> void:
	if not condition:
		failures.append(detail)

func provider_at(utc: String) -> Node:
	var provider := Provider.new()
	provider.motion = load("res://resources/presentation/menu_motion.tres")
	provider.quest_catalogue = load("res://resources/quests/development_catalogue.tres")
	current_scene.add_child(provider)
	provider.profile = PreviewProfile.new()
	provider.profile.player_id = "m08-controlled"
	provider.profile.display_name = "M08 controlled"
	provider.quest_clock.set_development_time(Time.get_unix_time_from_datetime_string(utc))
	provider.enter_menu()
	return provider

func actor(initial: String, claim: String, intention: String, final: String) -> Dictionary:
	return {"actorId": "m08-controlled", "initialCard": initial, "identityClaim": claim, "switchClaim": intention, "finalCard": final}

func apply(provider: Node, own: Dictionary, other: String) -> void:
	serial += 1
	var id := "m08-labelled-%d" % serial
	provider.begin_preview_match(id)
	var peer := {"actorId": "fixture-peer", "initialCard": other, "identityClaim": other, "switchClaim": "keep", "finalCard": other}
	var history := {"rulesRevision": "m08-controlled", "condition": 0, "actors": [own, peer]}
	var submission := {"resultId": id, "matchId": id, "rulesRevision": history.rulesRevision, "history": history, "result": Resolver.calculate(history, load("res://resources/arena/option_rules.tres")), "developmentOnly": true, "persistentCreditAllowed": false, "recipients": [{"actorId": "m08-controlled", "displayName": "M08 controlled", "eventualEligible": true, "departedBeforeCommit": false, "takeoverSide": false}, {"actorId": "fixture-peer", "displayName": "Labelled fixture", "eventualEligible": true, "departedBeforeCommit": false, "takeoverSide": false}]}
	var receipt := {"resultId": id, "matchId": id, "rulesRevision": history.rulesRevision, "receiptId": "simulated:" + id, "simulated": true, "persisted": false, "serverAcknowledged": false, "persistentCreditAllowed": false}
	Resolver.freeze(submission)
	var applied: bool = provider.apply_acknowledged_result(submission, receipt)
	check(applied, "labelled acknowledged fixture applies")

func _run() -> void:
	var provider := provider_at("2026-10-23T06:00:00")
	var first: Dictionary = provider.menu_snapshot.dailyQuest
	apply(provider, actor("Scissor", "Scissor", "keep", "Scissor"), "Rock")
	check(provider.menu_snapshot.dailyQuest.progress == 0 and provider.menu_snapshot.dailyQuest.definitionId == "preview-wins", "Scissors loss completes initial-card objective; next daily starts zero")
	check(provider.menu_snapshot.weeklyQuests[0].progress == 1, "already-active weekly also advances on loss")
	apply(provider, actor("Paper", "Paper", "keep", "Paper"), "Rock")
	apply(provider, actor("Paper", "Paper", "keep", "Paper"), "Rock")
	apply(provider, actor("Scissor", "Scissor", "keep", "Scissor"), "Paper")
	var repeated: Dictionary = provider.menu_snapshot.dailyQuest
	check(repeated.definitionId == first.definitionId and repeated.questInstanceId != first.questInstanceId and repeated.progress == 0, "Scissors/Win-3/Scissors uses fresh identity/counter; finishing Scissors event is not replayed")
	apply(provider, actor("Scissor", "Rock", "switch", "Scissor"), "Scissor")
	var read: Dictionary = await provider.request_quests()
	check(read.weeklyQuests[0].state == "completed" and read.weeklyQuests[2].progress == 1, "draw counts for play; two false claims contribute once to match-level lie")
	check(read.dailyHistory[2].state == "completed" and read.dailyQuest.progress == 0, "new Scissors needs new play; quest read does not pay")
	var before: int = provider.profile.overall_points
	provider.enter_menu()
	var grants: Array = provider.menu_snapshot.grants.duplicate(true)
	var after: int = provider.profile.overall_points
	provider.enter_menu()
	check(after - before == 10 and provider.profile.overall_points == after and provider.menu_snapshot.grants.is_empty(), "menu pays daily 1+3+1 and weekly 5 once across repeated entries")
	var stats: Dictionary = await provider.request_stats()
	check(stats.matches == 5 and stats.wins == 3 and stats.losses == 1 and stats.draws == 1 and stats.lieCount == 1, "normal aggregate attribution preserved")
	var leaderboard: Dictionary = await provider.request_leaderboard("overallPoints")
	check(leaderboard.entries[0].overallPoints == after and stats.overallPoints == after, "profile/menu/leaderboard read consistent rewarded balance")
	evidence["sequence"] = {"first": first, "repeated": repeated, "history": provider.menu_snapshot.dailyHistory, "grants": grants, "matchPoints": before, "afterRewards": after, "stats": stats}
	# Direct objective checks: actual fields, no presentation-string interpretation.
	var loss := Definition.new()
	loss.objective = "loss"
	var draw := Definition.new()
	draw.objective = "draw"
	var lying_win := Definition.new()
	lying_win.objective = "win_lying"
	var honest_win := Definition.new()
	honest_win.objective = "win_honest"
	var switched := Definition.new()
	switched.objective = "switch"
	var final_card := Definition.new()
	final_card.objective = "final_card"
	final_card.card = "Paper"
	check(loss.qualifies(actor("Rock", "Rock", "keep", "Rock"), "loss") and draw.qualifies(actor("Rock", "Rock", "keep", "Rock"), "draw"), "relevant loss/draw objectives qualify")
	check(lying_win.qualifies(actor("Scissor", "Rock", "switch", "Scissor"), "win") and honest_win.qualifies(actor("Rock", "Rock", "switch", "Paper"), "win") and switched.qualifies(actor("Rock", "Rock", "switch", "Paper"), "draw") and final_card.qualifies(actor("Rock", "Rock", "switch", "Paper"), "draw"), "claim/outcome and distinct initial/final fields")
	var objective_catalogue := Catalogue.new()
	objective_catalogue.daily_cycle.assign([loss, draw])
	objective_catalogue.weekly_objectives.assign([loss, draw])
	var objective_clock := Clock.new()
	objective_clock.set_development_time(Time.get_unix_time_from_datetime_string("2026-10-23T06:00:00"))
	var objective_quests := Coordinator.new(objective_catalogue, objective_clock, "isolated-loss-draw")
	var active_ids: Array = objective_quests.active_instance_ids()
	objective_quests.consume("loss-fixture", actor("Rock", "Rock", "keep", "Rock"), "loss", active_ids)
	check(objective_quests.daily_history[0].progress == 1 and objective_quests.current_daily.progress == 0 and objective_quests.weekly[0].progress == 1 and objective_quests.weekly[1].progress == 0, "loss objective advances both previously active periods")
	active_ids = objective_quests.active_instance_ids()
	objective_quests.consume("draw-fixture", actor("Rock", "Rock", "keep", "Rock"), "draw", active_ids)
	check(objective_quests.daily_history[1].progress == 1 and objective_quests.weekly[1].progress == 1 and objective_quests.current_daily.progress == 0, "draw objective advances both periods; next loss starts zero")
	evidence["isolatedLossDraw"] = objective_quests.snapshot()
	_clock_checks(false)
	_clock_checks(true)
	evidence["failures"] = failures
	var file := FileAccess.open("/tmp/m08_quest_checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence, "\t"))
	print("M08_BASIC " + JSON.stringify({"fixtureMatches": serial, "sequenceReward": after - before, "failures": failures}))
	quit(int(not failures.is_empty()))

func _clock_checks(monday: bool) -> void:
	# UTC 21:59 Sunday is GMT+7 Monday 04:59. No real-time waits.
	var utc := "2026-10-23T21:59:00"
	var label := "daily"
	if monday:
		utc = "2026-10-25T21:59:00"
		label = "Monday weekly"
	var provider := provider_at(utc)
	var before_time: int = provider.quest_clock.now_unix()
	var old_daily = provider.quests.current_daily
	var old_weekly = provider.quests.weekly[0]
	# Small clock fixture: one-play weekly, and a second unfinished objective.
	var one := Definition.new()
	one.definition_id = "clock-one-play"
	one.objective = "play"
	one.target = 1
	one.reward_points = 2
	old_weekly.definition = one
	apply(provider, actor("Scissor", "Scissor", "keep", "Scissor"), "Scissor")
	var unpaid_daily = old_daily
	var unfinished_daily = provider.quests.current_daily
	var unfinished_weekly = provider.quests.weekly[1]
	var snapshot_0459: Dictionary = provider.quests.snapshot()
	check(unpaid_daily.completed_at == before_time and unpaid_daily.paid_at == -1 and not unpaid_daily.expired, label + " 04:59 completion pending")
	provider.quest_clock.set_development_time(before_time + 60)
	provider.quests.refresh_periods()
	check(unpaid_daily.expired and unfinished_daily.expired, label + " 05:00 completed-unpaid and unfinished daily expire")
	check(provider.quests.current_daily.progress == 0 and provider.quests.current_daily.instance_id != unfinished_daily.instance_id and provider.quests.daily_history.size() == 1, label + " new day fresh identity and filtered history")
	if monday:
		check(old_weekly.expired and unfinished_weekly.expired and provider.quests.weekly[0].progress == 0 and provider.quests.weekly[0].instance_id != old_weekly.instance_id, "Monday 05:00 fresh weekly; unfinished/completed-unpaid expire")
	else:
		check(not old_weekly.expired and provider.quests.weekly[0] == old_weekly, "daily reset retains current weekly")
	var prior_points: int = provider.profile.overall_points
	provider.quest_clock.set_development_time(before_time + 120)
	provider.enter_menu()
	var paid_delta: int = provider.profile.overall_points - prior_points
	if monday:
		check(paid_delta == 0, "Monday 05:01 expired daily/weekly grant nothing")
	else:
		check(paid_delta == 2, "daily 05:01 expired daily grants nothing; unexpired weekly remains payable")
	# A separate normal paid completion retains awarded points after the boundary.
	var paid := provider_at(utc)
	apply(paid, actor("Scissor", "Scissor", "keep", "Scissor"), "Scissor")
	var paid_instance = paid.quests.daily_history[0]
	paid.enter_menu()
	var retained: int = paid.profile.overall_points
	paid.quest_clock.set_development_time(before_time + 120)
	paid.enter_menu()
	check(paid.profile.overall_points == retained and paid_instance.paid_at >= 0 and not paid_instance.expired and retained >= 0, label + " paid points retained; paid/expired exclusive")
	evidence[label] = {"at0459": snapshot_0459, "at0501": provider.menu_snapshot, "expiredUnpaid": unpaid_daily.snapshot(), "expiredUnfinished": unfinished_daily.snapshot(), "weeklyOld": old_weekly.snapshot(), "retainedPaidPoints": retained, "paidInstance": paid_instance.snapshot()}
