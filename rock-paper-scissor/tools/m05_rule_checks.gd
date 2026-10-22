extends SceneTree
## Focused M05 contract checks, run directly; not a test framework or shipped script.
const Resolver = preload("res://scripts/results/round_resolver.gd")
var failures: Array[String] = []
var checks: int = 0
var rules = load("res://resources/arena/option_rules.tres")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)

func actor(initial: String, identity: String, intention: String, final: String) -> Dictionary:
	return {"actorId": "a", "initialCard": initial, "identityClaim": identity, "switchClaim": intention, "finalCard": final}

func calculate(a: Dictionary, other: String, condition: int) -> Dictionary:
	return Resolver.calculate({"rulesRevision": rules.revision, "condition": condition, "actors": [a, actor(other, other, "keep", other)]}, rules).actors[0]

func _initialize() -> void:
	# SDK autoloads expect a current scene even for this direct calculation runner.
	var runner := Node.new()
	runner.name = "RuleChecks"
	root.add_child(runner)
	current_scene = runner
	call_deferred("_run")

func _run() -> void:
	var cards := ["Rock", "Paper", "Scissor"]
	var expected := [["draw", "loss", "win"], ["win", "draw", "loss"], ["loss", "win", "draw"]]
	for i in range(3):
		for j in range(3):
			check(Resolver.outcome(cards[i], cards[j]) == expected[i][j], "RPS %s/%s" % [cards[i], cards[j]])
	# Honest, identity-only lie, intention-only lie, two lies. Fixed totals per arena.
	for claims in [["Rock", "keep", true], ["Paper", "keep", false], ["Rock", "switch", false], ["Paper", "switch", false]]:
		for condition in range(3):
			for other in cards:
				var a := actor("Rock", claims[0], claims[1], "Rock")
				# Revisions/events do not change actual-switch or classification.
				a.events = [{"payload": {"finalCard": "Paper"}}, {"payload": {"finalCard": "Rock"}}]
				var result := calculate(a, other, condition)
				var points := 0
				if result.outcome == "win":
					points = 10
					if condition == 0 and not claims[2]:
						points = 20
					elif condition == 1 and claims[2]:
						points = 25
				elif result.outcome == "draw":
					points = 3
					if condition == 0 and not claims[2]:
						points = 8
					elif condition == 1 and claims[2]:
						points = 10
				check(result.points == points, "fixed total %s arena %d" % [claims, condition])
				check(result.honestMatchCount == int(claims[2]) and result.lyingMatchCount == int(not claims[2]), "one match classification")
				check(not result.actualSwitch, "final-equals-initial despite revisions")
	var default_case := actor("Paper", "Paper", "keep", "Rock")
	default_case.startingOrder = ["Rock", "Paper", "Scissor"]
	var accepted := calculate(default_case, "Scissor", 0)
	check(accepted.actualSwitch and not accepted.intentionTruth and accepted.identityTruth and accepted.lyingMatchCount == 1 and accepted.points == 20, "approved non-leftmost initial/default Keep/leftmost final")
	var switched := calculate(actor("Paper", "Paper", "switch", "Rock"), "Scissor", 1)
	check(switched.actualSwitch and switched.intentionTruth and switched.points == 25, "truthful Switch")
	print(JSON.stringify({"checks": checks, "failures": failures, "rulesRevision": rules.revision}))
	quit(int(not failures.is_empty()))
