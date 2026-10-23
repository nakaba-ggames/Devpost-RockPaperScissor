extends Node
const BotPersonality = preload("res://scripts/resources/bot_personality.gd")
const LocalBotPolicy = preload("res://scripts/bots/local_bot_policy.gd")
## Host seam only. Policy receives a detached own-only fragment + public condition.
@export var personality: BotPersonality
var policy := LocalBotPolicy.new()
var coordinator: OptionCoordinator
var observed_phase: String = ""
var schedule: Dictionary = {}
var acted: bool = false
var revised: bool = false
var last_policy_input: Dictionary = {}

func begin(controller: OptionCoordinator) -> void:
	coordinator = controller
	policy.personality = personality
	policy.rng.randomize()
	policy.planned_final = ""
	observed_phase = ""

func _process(_delta: float) -> void:
	if coordinator == null or not coordinator.phase in ["option", "identity_claim", "switch_claim", "final_choice"]:
		return
	if coordinator.context.session != null:
		if not coordinator.context.session.authority() or not coordinator.context.opponent.control_kind in ["fallback_bot", "development_bot", "takeover_bot"]:
			return
	if observed_phase != coordinator.phase:
		observed_phase = coordinator.phase
		schedule = policy.schedule()
		acted = false
		revised = false
		# Preserve an accepted human choice in the takeover window.
		if coordinator.context.opponent.takeover_side:
			var own := coordinator.history.actor(coordinator.context.opponent.player_id)
			var retained := own.initial_card
			if observed_phase == "identity_claim":
				retained = own.identity_claim
			elif observed_phase == "switch_claim":
				retained = own.switch_claim
			elif observed_phase == "final_choice":
				retained = own.final_card
			if not retained.is_empty():
				acted = true
				revised = true
	var started := coordinator.history.option_started_elapsed_msec
	if observed_phase == "final_choice":
		started = coordinator.history.final_timing.started
	elif observed_phase != "option":
		started = coordinator.history.claim_timing[observed_phase].started
	var elapsed := (coordinator.elapsed_msec() - started) / 1000.0
	if not acted and elapsed >= schedule.decision:
		acted = true
		_submit(false)
	if not revised and schedule.willRevise and elapsed >= schedule.revision:
		revised = true
		_submit(true)

func _submit(is_revision: bool) -> void:
	var own := coordinator.history.actor(coordinator.context.opponent.player_id)
	last_policy_input = {"phase": observed_phase, "revision": is_revision, "public": {"condition": coordinator.history.arena_condition}, "own": {"startingOrder": own.starting_order.duplicate(), "initialCard": own.initial_card, "identityClaim": own.identity_claim, "switchClaim": own.switch_claim, "finalCard": own.final_card, "events": own.events.duplicate(true)}}
	var value := policy.choose(last_policy_input.duplicate(true))
	if observed_phase == "option":
		coordinator.accept_choice(own.actor_id, value)
	elif observed_phase == "final_choice":
		coordinator.accept_final(own.actor_id, value)
	else:
		coordinator.accept_claim(own.actor_id, value)
