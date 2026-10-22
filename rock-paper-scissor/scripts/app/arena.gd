extends Control
signal return_requested
signal option_complete(context: MatchContext)
signal claims_complete(context: MatchContext)
signal round_complete(context: MatchContext)
var candidate: String = ""
@export var motion: ArenaMotion
@onready var coordinator: OptionCoordinator = $Coordinator
@onready var opponent_adapter: Node = $DevelopmentOpponent
@onready var chat_session: MatchChatSession = $ChatSession
var chat_open_allowed: bool = true
var chat_tween: Tween
var chat_closing: bool = false
var chat_content_x: float = 0.0
var context: MatchContext
var presentation_tween: Tween
var announcement_tweens: Dictionary = {}
var card_tweens: Dictionary = {}
var dim_tween: Tween
var condition_titles: Array[String] = ["Devil's Seduction", "Angel's Confession", "No modifier"]
var condition_details: Array[String] = ["Lie at least once to fulfill the condition.", "Never lie in either claim to fulfill the condition.", "Base rewards apply."]

func _ready() -> void:
	chat_content_x = $ChatOverlay/Content.position.x
	$Choices/Rock.pressed.connect(_choose.bind("Rock"))
	$Choices/Paper.pressed.connect(_choose.bind("Paper"))
	$Choices/Scissor.pressed.connect(_choose.bind("Scissor"))
	$Return.pressed.connect(_leave)
	coordinator.decision_accepted.connect(_decision)
	coordinator.option_locked.connect(_locked.bind("option"))
	coordinator.claim_locked.connect(_locked)
	coordinator.final_locked.connect(_locked.bind("final_choice"))
	$ConfirmSwitch.pressed.connect(_confirm_final)
	$ChatTrigger.pressed.connect(_open_chat)
	$ChatOverlay/Content/Close.pressed.connect(_close_chat)
	$ChatOverlay/Content/Send.pressed.connect(_send_chat)
	$ChatOverlay/Content/Input.text_submitted.connect(_submit_chat)
	chat_session.message_received.connect(_chat_message)

func begin(match_context: MatchContext, selected_condition: int) -> void:
	context = match_context
	chat_session.begin(context)
	set_chat_open_allowed(true)
	$ChatOverlay.hide()
	$ChatOverlay/Content/Scroll/Messages.text = "No messages this match."
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
	$ConfirmSwitch.hide()
	candidate = ""
	$Choices.hide()
	$OpponentBubble.hide()
	$PlayerBubble.hide()
	$Choices/Rock.text = "Rock"
	$Choices/Paper.text = "Paper"
	$Choices/Scissor.text = "Scissor"
	$Choices/Scissor.show()
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
	$Choices.position.y = 704.0
	var order := coordinator.history.actor(context.local_player.player_id).starting_order
	for button in $Choices.get_children():
		$Choices.move_child(button, order.find(str(button.name)))
	$Choices.show()
	for button in $Choices.get_children():
		button.disabled = false
	$Phase.text = "OPTION • INITIAL CHOICE"
	_dim(motion.dim_alpha)
	# Intro presentation precedes phase start. Selection tweens never set timing.
	coordinator.start_option()
	opponent_adapter.begin(coordinator)

func _process(_delta: float) -> void:
	if coordinator.phase in ["option", "identity_claim", "switch_claim", "final_choice"]:
		$Clock.text = "%.1f s • reconsider until time expires" % coordinator.seconds_left()

func _choose(choice: String) -> void:
	if context != null:
		if coordinator.phase == "option":
			coordinator.accept_choice(context.local_player.player_id, choice)
		elif coordinator.phase == "final_choice":
			candidate = choice
			$ConfirmSwitch.disabled = false
			$LocalChoice.text = "Initial: " + coordinator.history.actor(context.local_player.player_id).initial_card + " • Candidate: " + candidate
			for button in $Choices.get_children():
				var target := Color.WHITE
				if button.text != candidate:
					target = Color(motion.unselected_brightness, motion.unselected_brightness, motion.unselected_brightness)
				var tween := _tween()
				tween.tween_property(button, "modulate", target, motion.announcement_seconds)
		else:
			var value := choice
			if coordinator.phase == "switch_claim":
				value = "keep"
				if choice == "Paper":
					value = "switch"
			coordinator.accept_claim(context.local_player.player_id, value)

func _decision(actor_id: String, revised: bool) -> void:
	var participant := context.opponent
	var label: Label = $OpponentTell
	var side := "OpponentCards"
	if actor_id == context.local_player.player_id:
		participant = context.local_player
		label = $PlayerTell
		side = "PlayerCards"
		if coordinator.phase == "option":
			$LocalChoice.text = "Your choice: " + coordinator.history.actor(actor_id).initial_card
	var message := participant.display_name + " decided…"
	if revised:
		message = participant.display_name + " Changed their mind"
	_announce(label, message)
	if coordinator.phase == "option":
		_move_cards(side, coordinator.history.actor(actor_id))
	elif coordinator.phase == "final_choice":
		if actor_id == context.local_player.player_id:
			$LocalChoice.text = "Initial: " + coordinator.history.actor(actor_id).initial_card + " • Submitted: " + coordinator.history.actor(actor_id).final_card
		_submission_effect(side, actor_id)
	else:
		_update_bubble(actor_id, coordinator.phase)

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

func _locked(locked_phase: String) -> void:
	$ConfirmSwitch.disabled = true
	for button in $Choices.get_children():
		button.disabled = true
	$Clock.text = "0.0 s • decisions locked"
	for actor_history in coordinator.history.initial_choices:
		if locked_phase == "option":
			var side := "OpponentCards"
			if actor_history.actor_id == context.local_player.player_id:
				side = "PlayerCards"
				$LocalChoice.text = "Your locked card: " + actor_history.initial_card
				if actor_history.defaulted:
					$LocalChoice.text += " • leftmost default"
			_move_cards(side, actor_history)
		elif locked_phase == "final_choice":
			var side := "OpponentCards"
			if actor_history.actor_id == context.local_player.player_id:
				side = "PlayerCards"
			if actor_history.final_state.defaulted:
				_submission_effect(side, actor_history.actor_id)
		else:
			_update_bubble(actor_history.actor_id, locked_phase)
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
	if locked_phase == "option":
		coordinator.finish_presentation()
		option_complete.emit(context)
		await _prepare_claim("identity_claim")
	elif locked_phase == "identity_claim":
		await _prepare_claim("switch_claim")
	elif locked_phase == "switch_claim":
		coordinator.finish_claims_presentation()
		claims_complete.emit(context)
		_prepare_final()
	else:
		$ConfirmSwitch.hide()
		$Phase.text = "LOCAL ROUND COMPLETE"
		$Boundary.text = "M05 development boundary • Simulated receipt only.\nM06 reveal pending. No points or history saved."
		$Return.show()
		$Return.modulate.a = 0.0
		presentation_tween = _tween()
		presentation_tween.tween_property($Return, "modulate:a", 1.0, motion.intro_fade_seconds)
		await presentation_tween.finished
		coordinator.finish_final_presentation()
		round_complete.emit(context)

func _prepare_claim(next_phase: String) -> void:
	$Phase.text = "CLAIM • IDENTITY"
	$PlayerTell.text = ""
	$OpponentTell.text = ""
	$Tendency.text = "Opponent lie tendency: N/A\n" + condition_details[coordinator.history.arena_condition]
	if next_phase == "identity_claim":
		# Retain the one chosen representative. Its face never reveals identity.
		presentation_tween = _tween().set_parallel(true)
		for side in ["PlayerCards", "OpponentCards"]:
			if card_tweens.has(side):
				card_tweens[side].kill()
			var actor_id := context.opponent.player_id
			if side == "PlayerCards":
				actor_id = context.local_player.player_id
			var actor_history := coordinator.history.actor(actor_id)
			for index in range(3):
				if actor_history.starting_order[index] != actor_history.initial_card:
					var card: Control = get_node(side).get_child(index)
					presentation_tween.tween_property(card, "position:x", card.position.x + motion.unused_card_exit_distance, motion.card_seconds)
					presentation_tween.tween_property(card, "modulate:a", 0.0, motion.card_seconds)
		for bubble in [$OpponentBubble, $PlayerBubble]:
			bubble.get_node("Text").text = "…"
			bubble.modulate.a = 0.0
			bubble.show()
			presentation_tween.tween_property(bubble, "modulate:a", 1.0, motion.bubble_seconds)
		await presentation_tween.finished
	else:
		$Phase.text = "CHANGE CLAIM • INTENTION"
		$Choices.move_child($Choices/Rock, 0)
		$Choices.move_child($Choices/Paper, 1)
		$Choices/Rock.text = "Keep"
		$Choices/Paper.text = "Switch"
		$Choices/Scissor.hide()
		for bubble in [$OpponentBubble, $PlayerBubble]:
			_announce(bubble.get_node("Text"), "…")
	$Choices.show()
	$Choices.modulate.a = 0.0
	for button in $Choices.get_children():
		button.disabled = false
	_dim(motion.dim_alpha)
	var tween := _tween()
	tween.tween_property($Choices, "modulate:a", 1.0, motion.dim_seconds)
	# The full window begins with visible controls; no animation extends it.
	coordinator.start_claim(next_phase)

func _update_bubble(actor_id: String, phase_name: String) -> void:
	var bubble: Control = $OpponentBubble
	if actor_id == context.local_player.player_id:
		bubble = $PlayerBubble
	var actor_history := coordinator.history.actor(actor_id)
	var text := "I chose " + actor_history.identity_claim
	if phase_name == "switch_claim":
		text = "I'll keep my choosing"
		if actor_history.switch_claim == "switch":
			text = "I'll switch my choosing"
	_announce(bubble.get_node("Text"), text)
	var tween := _tween()
	bubble.pivot_offset = bubble.size / 2.0
	bubble.scale = motion.bubble_start_scale
	tween.tween_property(bubble, "scale", Vector2.ONE, motion.bubble_seconds)

# Future cinematic may disable opening. Existing-overlay close choreography is
# creator-owned: this gate deliberately leaves an already-open overlay alone.
func set_chat_open_allowed(allowed: bool) -> void:
	chat_open_allowed = allowed
	$ChatTrigger.disabled = not allowed

func _open_chat() -> void:
	if not chat_open_allowed or $ChatOverlay.visible:
		return
	if chat_tween:
		chat_tween.kill()
	chat_closing = false
	$ChatOverlay.show()
	$ChatOverlay.modulate.a = 0.0
	$ChatOverlay/Content.position.x = chat_content_x + motion.chat_slide_distance
	chat_tween = _tween().set_parallel(true)
	chat_tween.tween_property($ChatOverlay, "modulate:a", 1.0, motion.chat_seconds)
	chat_tween.tween_property($ChatOverlay/Content, "position:x", chat_content_x, motion.chat_seconds)

func _close_chat() -> void:
	if chat_closing or not $ChatOverlay.visible:
		return
	chat_closing = true
	if chat_tween:
		chat_tween.kill()
	chat_tween = _tween().set_parallel(true)
	chat_tween.tween_property($ChatOverlay, "modulate:a", 0.0, motion.chat_seconds)
	chat_tween.tween_property($ChatOverlay/Content, "position:x", chat_content_x + motion.chat_slide_distance, motion.chat_seconds)
	await chat_tween.finished
	$ChatOverlay.hide()
	chat_closing = false

func _send_chat() -> void:
	if chat_session.send_text($ChatOverlay/Content/Input.text):
		$ChatOverlay/Content/Input.clear()

func _submit_chat(_text: String) -> void:
	_send_chat()

func _chat_message(_message: Dictionary) -> void:
	var lines := PackedStringArray()
	for message in chat_session.messages:
		var sender := "Peer"
		if message.actorId == context.local_player.player_id:
			sender = "You • local preview, not delivered"
		lines.append(sender + "\n" + str(message.text))
	$ChatOverlay/Content/Scroll/Messages.text = "\n\n".join(lines)
	await get_tree().process_frame
	$ChatOverlay/Content/Scroll.scroll_vertical = int($ChatOverlay/Content/Scroll.get_v_scroll_bar().max_value)

func _dim(alpha: float) -> void:
	if dim_tween:
		dim_tween.kill()
	dim_tween = _tween()
	dim_tween.tween_property($Dimmer, "modulate:a", alpha, motion.dim_seconds)

func _tween() -> Tween:
	return create_tween().set_trans(motion.transition).set_ease(motion.ease)

func _leave() -> void:
	# Only leaves this context; matchmaking releases its reservation by match ID.
	chat_session.dispose()
	$ChatOverlay.hide()
	coordinator.leave_context()
	context = null
	return_requested.emit()

func _prepare_final() -> void:
	$Phase.text = "CHANGE • FINAL CHOICE"
	$PlayerTell.text = ""
	$OpponentTell.text = ""
	$PlayerBubble.hide()
	$OpponentBubble.hide()
	var tendency := "N/A"
	if context.opponent.switch_percentage != null:
		tendency = "%.1f%%" % float(context.opponent.switch_percentage)
	$Tendency.text = "Opponent switching tendency: " + tendency
	$LocalChoice.text = "Initial: " + coordinator.history.actor(context.local_player.player_id).initial_card + " • Select, then confirm below"
	candidate = ""
	var order := coordinator.history.actor(context.local_player.player_id).starting_order
	for button in $Choices.get_children():
		button.show()
		button.text = str(button.name)
		button.disabled = false
		button.modulate = Color.WHITE
		$Choices.move_child(button, order.find(str(button.name)))
	$Choices.position.y = motion.final_choices_y
	$Choices.show()
	$Choices.modulate.a = 0.0
	$ConfirmSwitch.show()
	$ConfirmSwitch.modulate.a = 0.0
	$ConfirmSwitch.disabled = true
	_dim(motion.dim_alpha)
	var tween := _tween().set_parallel(true)
	tween.tween_property($Choices, "modulate:a", 1.0, motion.dim_seconds)
	tween.tween_property($ConfirmSwitch, "modulate:a", 1.0, motion.dim_seconds)
	coordinator.start_final()

func _confirm_final() -> void:
	if context != null and not candidate.is_empty():
		coordinator.accept_final(context.local_player.player_id, candidate)

func _submission_effect(side: String, actor_id: String) -> void:
	# Pulse the existing face-down representative identically for keep/switch.
	var own := coordinator.history.actor(actor_id)
	var card: Control = get_node(side).get_child(own.starting_order.find(own.initial_card))
	var effect: CPUParticles2D = $OpponentSubmissionEffect
	if side == "PlayerCards":
		effect = $PlayerSubmissionEffect
	effect.position = card.position + card.size * card.scale / 2.0
	effect.restart()
	effect.emitting = true
	var tween := _tween()
	tween.tween_property(card, "scale", motion.card_scale * motion.submission_pulse_scale, motion.submission_pulse_seconds)
	tween.tween_property(card, "scale", motion.card_scale, motion.submission_pulse_seconds)
