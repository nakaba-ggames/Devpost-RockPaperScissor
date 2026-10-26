extends Control
## Read-only presentation companion. The arena/coordinator retain every decision.
const PREVIOUS_CARD = preload("res://scenes/ui/decision_card.tscn")
const SOUND = preload("res://resources/presentation/ui_sound_config.tres")
@export var tuning: Resource
@onready var arena: Control = get_parent()
var header_tween: Tween
var retreat_tween: Tween
var header_homes: Dictionary = {}
var local_streak: Variant = null
var local_portrait: Texture2D
var opponent_profile: Dictionary = {}
var previous_choice: Control
var previous_choice_card: Button

func set_local_streak(value: int) -> void:
	local_streak = value

func set_local_persona(lies: int, honest: int) -> void:
	local_portrait = tuning.persona.avatar(lies, honest)

func _ready() -> void:
	previous_choice = Control.new()
	previous_choice.name = "PreviousChoiceReminder"
	previous_choice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	previous_choice.z_index = 3
	add_child(previous_choice)
	previous_choice_card = PREVIOUS_CARD.instantiate()
	previous_choice.add_child(previous_choice_card)
	previous_choice_card.size = Vector2(136, 200)
	previous_choice_card.disabled = true
	previous_choice_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	previous_choice_card.focus_mode = Control.FOCUS_NONE
	previous_choice.hide()
	get_viewport().size_changed.connect(_fit_dimmer)
	arena.resized.connect(_fit_dimmer)
	_fit_dimmer.call_deferred()

func _process(_delta: float) -> void:
	if arena.is_visible_in_tree():
		_fit_dimmer()

func _fit_dimmer() -> void:
	# The arena is centered inside the shared UI, rather than a screen-sized root.
	var dimmer: Control = arena.get_node("Dimmer")
	dimmer.position = -arena.global_position
	dimmer.size = get_viewport_rect().size

func begin(context: MatchContext) -> void:
	if retreat_tween and retreat_tween.is_valid():
		retreat_tween.kill()
	show()
	modulate.a = 1.0
	_fit_dimmer.call_deferred()
	arena.get_node("PlayerName").text = context.local_player.display_name
	arena.get_node("OpponentName").text = context.opponent.display_name
	$LocalHeader/Streak.text = _streak(local_streak)
	$OpponentHeader/Streak.text = _streak(context.opponent.public_profile.get("winStreak"))
	opponent_profile = context.opponent.public_profile
	var opponent_portrait: Texture2D = tuning.persona.avatar_from_public(opponent_profile)
	if local_portrait == null:
		local_portrait = tuning.persona.angel
	$LocalHeader/Avatar.texture = local_portrait
	$OpponentHeader/Avatar.texture = opponent_portrait
	arena.get_node("PlayerBubble/Avatar").texture = local_portrait
	arena.get_node("OpponentBubble/Avatar").texture = opponent_portrait
	$PhaseClock/Badge.texture = tuning.persona.devil
	$TendencyPanel.hide()
	$OpponentHeader/Streak.hide()
	arena.get_node("Phase").hide()
	arena.get_node("LocalChoice").hide()
	arena.get_node("Condition").hide()
	arena.get_node("Tendency").hide()
	$PhaseClock.hide()
	_slide_headers()

func _streak(streak: Variant) -> String:
	if streak == null:
		return "—"
	return "W ×%d" % int(streak)

func _percent(value: Variant) -> String:
	if value == null:
		return "N/A"
	return "%.0f%%" % float(value)

func _slide_headers() -> void:
	if header_tween and header_tween.is_valid():
		header_tween.kill()
	for node in header_homes:
		node.position = header_homes[node]
	header_homes.clear()
	header_tween = create_tween().set_parallel(true).set_trans(tuning.transition).set_ease(tuning.ease)
	var left := [$LocalHeader, arena.get_node("PlayerName")]
	var right := [$OpponentHeader, arena.get_node("OpponentName")]
	for node in left + right:
		var control: Control = node
		var home := control.position
		header_homes[control] = home
		var offset: float = -control.get_global_rect().end.x - tuning.offscreen_margin
		if node in right:
			offset = get_viewport_rect().size.x - control.global_position.x + tuning.offscreen_margin
		control.position.x += offset
		header_tween.tween_property(control, "position", home, tuning.header_seconds)

func prepare_choices(phase: String) -> void:
	for side in ["PlayerCards", "OpponentCards"]:
		arena.get_node(side).show()
	var choices := arena.get_node("Choices")
	previous_choice.hide()
	if phase == "final_choice":
		var initial_card: String = arena.coordinator.history.actor(arena.context.local_player.player_id).initial_card
		previous_choice_card.configure_face(initial_card)
		previous_choice.position = arena.motion.previous_choice_position
		previous_choice.scale = Vector2.ONE * arena.motion.previous_choice_scale
		previous_choice.show()
	# Reset all phase-specific layout each time, including replay/next round.
	choices.position.y = arena.motion.choices_y
	arena.get_node("LocalChoice").position.y = arena.motion.instruction_y
	if phase == "final_choice":
		choices.position.y = arena.motion.final_choices_y
		arena.get_node("LocalChoice").position.y = arena.motion.final_instruction_y
	for card in choices.get_children():
		card.configure_face(str(card.name))
		card.show()
	if phase == "switch_claim":
		choices.get_node("Rock").configure_face("Keep")
		choices.get_node("Paper").configure_face("Switch")
		choices.get_node("Scissor").hide()
	$PhaseClock.show()
	arena.get_node("Clock").show()
	arena.get_node("Tendency").hide()
	arena.get_node("Phase").hide()
	arena.get_node("Condition").hide()
	var instruction := "PICK YOUR CHOICE"
	if phase == "identity_claim":
		instruction = "WHAT DID YOU PICK?"
	elif phase == "switch_claim":
		instruction = "KEEP OR SWITCH?"
	elif phase == "final_choice":
		instruction = "YOUR FINAL CHOICE"
	arena.get_node("LocalChoice").text = instruction
	arena.get_node("LocalChoice").show()
	$PhaseClock.tooltip_text = phase.replace("_", " ").capitalize()
	_update_tendency(phase)

func select_card(value: String) -> void:
	for card in arena.get_node("Choices").get_children():
		card.set_selected(str(card.name) == value, true)

func update_clock(seconds: float, duration: float) -> void:
	$PhaseClock.update_time(seconds, duration)

func phase_locked() -> void:
	previous_choice.hide()
	update_clock(0.0, arena.coordinator.rules.option_seconds)
	for side in ["PlayerCards", "OpponentCards"]:
		arena.get_node(side).show()
	SOUND.play(self, "phase_end")

func reset_visuals() -> void:
	previous_choice.hide()
	for animation in [header_tween, retreat_tween]:
		if animation and animation.is_valid():
			animation.kill()
	for node in header_homes:
		node.position = header_homes[node]
	header_homes.clear()
	$PhaseClock.hide()
	hide()

func retreat(seconds: float) -> void:
	retreat_tween = create_tween().set_trans(tuning.transition).set_ease(tuning.ease)
	retreat_tween.tween_property(self, "modulate:a", 0.0, seconds)

func _update_tendency(phase: String) -> void:
	var token := $TendencyPanel/Row/Rock
	var icon: Texture2D = tuning.rock_icon
	var value: Variant = null
	var scope := ""
	var explanation := "No history available"
	token.get_node("Icon/SecondIcon").hide()
	if phase == "option":
		var percentages: Dictionary = opponent_profile.get("initialCardPercentages", {})
		var highest := -1.0
		for card in ["Rock", "Paper", "Scissor"]:
			var percentage: Variant = percentages.get(card)
			if percentage != null and float(percentage) > highest:
				highest = float(percentage)
				value = percentage
				explanation = "Most frequent initial choice: " + card
				icon = tuning.rock_icon
				if card == "Paper":
					icon = tuning.paper_icon
				elif card == "Scissor":
					icon = tuning.scissor_icon
	elif phase in ["identity_claim", "switch_claim"]:
		icon = tuning.persona.devil
		value = opponent_profile.get("liePercentage")
		scope = "LIE"
		explanation = "Overall completed-round lie rate; separate claim-phase rates are unavailable."
	else:
		icon = tuning.keep_icon
		var switches: Variant = opponent_profile.get("switchPercentage")
		if switches != null:
			value = 100.0 - float(switches)
			explanation = "Usually keeps the initial card"
			if float(switches) > 50.0:
				value = switches
				icon = tuning.switch_icon
				explanation = "Usually switches the initial card"
	token.get_node("Icon").texture = icon
	token.get_node("Percent").text = _percent(value)
	token.get_node("Scope").text = scope
	$TendencyPanel.tooltip_text = explanation
	$TendencyPanel.show()
