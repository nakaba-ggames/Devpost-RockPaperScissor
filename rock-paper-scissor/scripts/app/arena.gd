extends Control
signal return_requested
signal option_complete(context: MatchContext)
@export var motion: ArenaMotion
@onready var coordinator: OptionCoordinator = $Coordinator
@onready var opponent_adapter: Node = $DevelopmentOpponent
var context: MatchContext
var presentation_tween: Tween
var announcement_tweens: Dictionary = {}
var card_tweens: Dictionary = {}
var dim_tween: Tween
var condition_titles: Array[String] = ["Devil's Seduction", "Angel's Confession", "No modifier"]
var condition_details: Array[String] = ["Lie at least once to fulfill the condition.", "Never lie in either claim to fulfill the condition.", "Base rewards apply."]

func _ready() -> void:
	$Choices/Rock.pressed.connect(_choose.bind("Rock"))
	$Choices/Paper.pressed.connect(_choose.bind("Paper"))
	$Choices/Scissor.pressed.connect(_choose.bind("Scissor"))
	$Return.pressed.connect(_leave)
	coordinator.decision_accepted.connect(_decision)
	coordinator.option_locked.connect(_locked)

func begin(match_context: MatchContext, selected_condition: int) -> void:
	context = match_context
	if not coordinator.begin_match(context, selected_condition):
		$Boundary.text = "Arena rules missing. Return to the development menu."
		$Return.show()
		return
	$OpponentName.text = context.opponent.display_name
	$PlayerName.text = context.local_player.display_name + " • You"
	$Condition.text = condition_titles[selected_condition]
	# No account history has been fetched. Never invent a denominator/sample.
	$Tendency.text = "Opponent initial choices\nRock N/A   •   Paper N/A   •   Scissor N/A"
	$PlayerTell.text = ""
	$OpponentTell.text = ""
	$LocalChoice.text = "Choose your initial card"
	$Phase.text = "ARENA INTRO"
	$Clock.text = "Option opens after the condition"
	$Boundary.text = ""
	$Return.hide()
	$Choices.hide()
	$PhaseEnds.hide()
	$Dimmer.modulate.a = 0.0
	$Intro.text = condition_titles[selected_condition] + "\n\n" + condition_details[selected_condition]
	$Intro.modulate.a = 0.0
	$Intro.show()
	for side in ["PlayerCards", "OpponentCards"]:
		for index in range(3):
			var card: Control = get_node(side).get_child(index)
			card.scale = motion.card_scale
			card.position = _home_position(side, index)
			card.modulate = Color(1, 1, 1, 0)
			var tween := _tween()
			tween.tween_property(card, "modulate:a", 1.0, motion.intro_fade_seconds)
	presentation_tween = _tween()
	presentation_tween.tween_property($Intro, "modulate:a", 1.0, motion.intro_fade_seconds)
	presentation_tween.tween_interval(motion.intro_hold_seconds)
	presentation_tween.tween_property($Intro, "modulate:a", 0.0, motion.intro_fade_seconds)
	await presentation_tween.finished
	$Intro.hide()
	$Choices.show()
	for button in $Choices.get_children():
		button.disabled = false
	$Phase.text = "OPTION • INITIAL CHOICE"
	_dim(motion.dim_alpha)
	# Intro presentation precedes phase start. Selection tweens never set timing.
	coordinator.start_option()
	opponent_adapter.begin(coordinator)

func _process(_delta: float) -> void:
	if coordinator.phase == "option":
		$Clock.text = "%.1f s • reconsider until time expires" % coordinator.seconds_left()

func _choose(choice: String) -> void:
	if context != null:
		coordinator.accept_choice(context.local_player.player_id, choice)

func _decision(actor_id: String, revised: bool) -> void:
	var participant := context.opponent
	var label: Label = $OpponentTell
	var side := "OpponentCards"
	if actor_id == context.local_player.player_id:
		participant = context.local_player
		label = $PlayerTell
		side = "PlayerCards"
		$LocalChoice.text = "Your choice: " + coordinator.history.actor(actor_id).initial_card
	var message := participant.display_name + " decided…"
	if revised:
		message = participant.display_name + " Changed their mind"
	_announce(label, message)
	_move_cards(side, coordinator.history.actor(actor_id))

func _announce(label: Label, message: String) -> void:
	if announcement_tweens.has(label):
		announcement_tweens[label].kill()
	label.text = message
	label.modulate.a = 0.0
	var tween := _tween()
	announcement_tweens[label] = tween
	tween.tween_property(label, "modulate:a", 1.0, motion.announcement_seconds)

func _move_cards(side: String, history: InitialChoiceHistory) -> void:
	if card_tweens.has(side):
		card_tweens[side].kill()
	var tween := _tween().set_parallel(true)
	card_tweens[side] = tween
	for index in range(3):
		var card: Control = get_node(side).get_child(index)
		var target := _home_position(side, index)
		var brightness := motion.unselected_brightness
		if history.starting_order[index] == history.initial_card:
			target.x = (size.x - 150.0 * motion.card_scale.x) / 2.0
			target.y = motion.opponent_submission_y
			if side == "PlayerCards":
				target.y = motion.player_submission_y
			brightness = 1.0
		tween.tween_property(card, "position", target, motion.card_seconds)
		tween.tween_property(card, "modulate", Color(brightness, brightness, brightness, 1), motion.card_seconds)

func _home_position(side: String, index: int) -> Vector2:
	var y := motion.opponent_y
	if side == "PlayerCards":
		y = motion.player_y
	var center_x := (size.x - 150.0 * motion.card_scale.x) / 2.0
	return Vector2(center_x + (index - 1) * motion.card_spacing, y)

func _locked() -> void:
	for button in $Choices.get_children():
		button.disabled = true
	$Clock.text = "0.0 s • choices locked"
	for actor_history in coordinator.history.initial_choices:
		var side := "OpponentCards"
		if actor_history.actor_id == context.local_player.player_id:
			side = "PlayerCards"
			$LocalChoice.text = "Your locked choice: " + actor_history.initial_card
			if actor_history.defaulted:
				$LocalChoice.text += " • leftmost default"
		_move_cards(side, actor_history)
	_dim(0.0)
	$PhaseEnds.modulate.a = 0.0
	$PhaseEnds.scale = motion.feedback_start_scale
	$PhaseEnds.pivot_offset = $PhaseEnds.size / 2.0
	$PhaseEnds.show()
	presentation_tween = _tween().set_parallel(true)
	presentation_tween.tween_property($PhaseEnds, "modulate:a", 1.0, motion.phase_end_fade_seconds)
	presentation_tween.tween_property($PhaseEnds, "scale", Vector2.ONE, motion.phase_end_fade_seconds)
	presentation_tween.set_parallel(false)
	presentation_tween.tween_interval(motion.phase_end_hold_seconds)
	presentation_tween.tween_property($PhaseEnds, "modulate:a", 0.0, motion.phase_end_fade_seconds)
	await presentation_tween.finished
	$PhaseEnds.hide()
	$Choices.hide()
	$Phase.text = "OPTION COMPLETE"
	$Boundary.text = "M03 development boundary\nClaim begins in M04. No round is saved."
	$Return.show()
	$Return.modulate.a = 0.0
	presentation_tween = _tween()
	presentation_tween.tween_property($Return, "modulate:a", 1.0, motion.intro_fade_seconds)
	await presentation_tween.finished
	coordinator.finish_presentation()
	option_complete.emit(context)

func _dim(alpha: float) -> void:
	if dim_tween:
		dim_tween.kill()
	dim_tween = _tween()
	dim_tween.tween_property($Dimmer, "modulate:a", alpha, motion.dim_seconds)

func _tween() -> Tween:
	return create_tween().set_trans(motion.transition).set_ease(motion.ease)

func _leave() -> void:
	# Only leaves this context; matchmaking releases its reservation by match ID.
	coordinator.leave_context()
	context = null
	return_requested.emit()
