extends SceneTree
## One representative compatibility fixture, never uploaded as gameplay.
const Wire = preload("res://scripts/api/history_wire.gd")
func _initialize() -> void:
	var match_id := "12000000-0000-0000-0000-000000000001"
	var snapshot := {"matchId": match_id, "condition": 2, "optionStarted": 0, "optionDeadline": 15000, "optionLocked": 15000,
		"claimTiming": {"identity_claim": {"started": 16000, "deadline": 31000, "locked": 31000}, "switch_claim": {"started": 32000, "deadline": 47000, "locked": 47000}},
		"finalTiming": {"started": 48000, "deadline": 63000, "locked": 63000}, "actors": []}
	var expected: Array = []
	for actor_index in range(2):
		var actor := {"actorId": "12000000-0000-0000-0000-00000000000%d" % (actor_index + 2), "startingOrder": ["Scissor", "Rock", "Paper"], "events": []}
		for phase_index in range(4):
			var count := 20
			if actor_index == 1 and phase_index == 3:
				count = 1
			for revision in range(count):
				var phase: String = Wire.PHASES[phase_index]
				var field: String = ["initialCard", "identityClaim", "switchClaim", "finalCard"][phase_index]
				var value: String = Wire.CARDS[revision % 3]
				if phase_index == 2:
					value = ["keep", "switch"][revision % 2]
				var kind := "decision"
				var elapsed := phase_index * 16000 + revision * 100 + actor_index
				if actor_index == 1 and phase_index == 3:
					value = "Scissor"
					kind = "default"
					elapsed = 63000
				var sequence := phase_index * 100 + revision * 2 + actor_index + 1
				if kind == "default":
					sequence = 399
				actor[field] = value
				actor.events.append({"matchId": match_id, "actorId": actor.actorId, "phase": phase, "sequence": sequence, "revision": revision, "elapsedMsec": elapsed, "kind": kind, "revised": revision > 0, "payload": {field: value}})
				expected.append({"actorIndex": actor_index, "event": {"phase": phase, "sequence": sequence, "revision": revision, "elapsedMsec": elapsed, "value": value, "kind": kind}})
		snapshot.actors.append(actor)
	expected.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.event.sequence < b.event.sequence)
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		quit(1)
		return
	var wire := Wire.encode(snapshot, args[0], 32)
	var output := FileAccess.open(args[1], FileAccess.WRITE)
	if output == null:
		quit(1)
		return
	output.store_string(JSON.stringify({"wire": wire, "expected": expected, "richBytes": JSON.stringify(snapshot).to_utf8_buffer().size()}))
	output.close()
	print("M12 representative: 80/61 actor events; default retained; 32 events per upload chunk.")
	quit(0)
