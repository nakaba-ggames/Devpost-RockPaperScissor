extends Node
## No live transport or production bot policy. Reads only its own fixture.
@export var fixture: ArenaFixture
var coordinator: OptionCoordinator
var acted: bool = false
var revised: bool = false

func begin(controller: OptionCoordinator) -> void:
	coordinator = controller
	acted = false
	revised = false

func _process(_delta: float) -> void:
	if coordinator == null or coordinator.phase != "option":
		return
	var elapsed := (coordinator.elapsed_msec() - coordinator.history.option_started_elapsed_msec) / 1000.0
	if not acted and elapsed >= fixture.opponent_decision_seconds:
		acted = true
		coordinator.accept_choice(coordinator.context.opponent.player_id, fixture.opponent_initial)
	if not revised and elapsed >= fixture.opponent_revision_seconds:
		revised = true
		coordinator.accept_choice(coordinator.context.opponent.player_id, fixture.opponent_revised)
