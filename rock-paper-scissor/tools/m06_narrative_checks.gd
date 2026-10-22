extends SceneTree
## Only four controlled frozen-history examples; no failure/duplicate injection.
const Narration = preload("res://scripts/presentation/round_narration.gd")
const Resolver = preload("res://scripts/results/round_resolver.gd")
var failures: Array[String] = []
var examples: Array[Dictionary] = []
var copy = load("res://resources/presentation/reveal_tuning.tres")
var rules = load("res://resources/arena/option_rules.tres")

func _initialize() -> void:
	var runner := Node.new()
	runner.name = "NarrativeChecks"
	root.add_child(runner)
	current_scene = runner
	call_deferred("_run")

func actor(id: String, initial: String, claim: String, intention: String, final: String, defaulted: bool = false) -> Dictionary:
	return {"actorId": id, "initialCard": initial, "identityClaim": claim, "switchClaim": intention, "finalCard": final, "defaulted": false, "claimPhases": {"identity_claim": {"defaulted": false}, "switch_claim": {"defaulted": defaulted}}, "finalState": {"defaulted": defaulted}}

func example(label: String, own: Dictionary, other: String, expected: String, identity_truth: bool, intention_truth: bool, switched: bool, defaulted: bool = false) -> void:
	var history := {"rulesRevision": rules.revision, "condition": 0, "actors": [own, actor("b", other, other, "keep", other)]}
	var envelope := {"history": history, "result": Resolver.calculate(history, rules), "recipients": [{"actorId": "a", "displayName": "You"}, {"actorId": "b", "displayName": "Velvet"}]}
	Resolver.freeze(envelope)
	var lines := Narration.beats(envelope, copy)
	var result: Dictionary = envelope.result.actors[0]
	var truth: String = copy.truth_copy
	if not identity_truth:
		truth = copy.lie_copy
	var intention_text: String = copy.truth_copy
	if not intention_truth:
		intention_text = copy.lie_copy
	var action_text: String = copy.keep_copy
	if switched:
		action_text = copy.switch_copy
	if result.outcome != expected or result.identityTruth != identity_truth or result.intentionTruth != intention_truth or result.actualSwitch != switched:
		failures.append(label + ": result disagreement")
	if lines.size() != 8 or not lines[0].contains(own.initialCard) or not lines[2].contains(own.identityClaim) or not lines[2].contains(truth) or not lines[4].contains(intention_text) or not lines[6].contains(action_text) or not lines[6].contains(own.finalCard):
		failures.append(label + ": narrative disagreement")
	if defaulted and (not lines[4].contains(copy.default_copy) or not lines[6].contains(copy.default_copy)):
		failures.append(label + ": defaults missing")
	examples.append({"example": label, "result": result, "localBeats": [lines[0], lines[2], lines[4], lines[6]]})

func _run() -> void:
	example("truthful Keep / win", actor("a", "Rock", "Rock", "keep", "Rock"), "Scissor", "win", true, true, false)
	example("deceptive identity and Switch promise / loss", actor("a", "Rock", "Paper", "switch", "Rock"), "Paper", "loss", false, false, false)
	example("truthful Switch / draw", actor("a", "Paper", "Paper", "switch", "Rock"), "Rock", "draw", true, true, true)
	example("default Keep contradicted by final leftmost / win", actor("a", "Paper", "Paper", "keep", "Rock", true), "Scissor", "win", true, false, true, true)
	print("M06_EXAMPLES " + JSON.stringify({"examples": examples, "failures": failures}))
	quit(int(not failures.is_empty()))
