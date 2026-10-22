extends Node
## No live transport or production bot policy. Reads only its own fixture.
@export var fixture: ArenaFixture
var coordinator: OptionCoordinator
var acted: bool = false
var revised: bool = false
var observed_phase: String = ""

func begin(controller: OptionCoordinator) -> void:
	coordinator = controller
	acted = false
	revised = false

func _process(_delta: float) -> void:
	if coordinator == null or not coordinator.phase in ["option", "identity_claim", "switch_claim"]:
		return
	if observed_phase != coordinator.phase:
		observed_phase = coordinator.phase
		acted = false
		revised = false
	var started := coordinator.history.option_started_elapsed_msec
	if observed_phase != "option":
		started = coordinator.history.claim_timing[observed_phase].started
	var elapsed := (coordinator.elapsed_msec() - started) / 1000.0
	if not acted and elapsed >= fixture.opponent_decision_seconds:
		acted = true
		_submit(false)
	if not revised and elapsed >= fixture.opponent_revision_seconds:
		revised = true
		_submit(true)

func _submit(is_revision: bool) -> void:
	var value := fixture.opponent_initial
	if is_revision:
		value = fixture.opponent_revised
	if observed_phase == "identity_claim":
		value = fixture.opponent_identity
		if is_revision:
			value = fixture.opponent_identity_revised
	elif observed_phase == "switch_claim":
		value = fixture.opponent_switch
		if is_revision:
			value = fixture.opponent_switch_revised
	if observed_phase == "option":
		coordinator.accept_choice(coordinator.context.opponent.player_id, value)
	else:
		coordinator.accept_claim(coordinator.context.opponent.player_id, value)
