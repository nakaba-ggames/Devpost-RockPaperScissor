extends Control
## Reads only an acknowledged frozen envelope. Never settles or credits a result.
signal card_suspense(angle: float)
signal continue_requested
signal retreat_requested(seconds: float)
signal outcome_requested(seconds: float)
signal cinematic_started
signal winner_revealed
const CurtainMotion = preload("res://scripts/presentation/curtain_motion.gd")
const Narration = preload("res://scripts/presentation/round_narration.gd")
@export var tuning: Resource
var state: String = "idle"
var lines: Array[String] = []
var submission: Dictionary = {}
var local_result: Dictionary = {}
var tween: Tween
var pulse: Tween
var projector: Tween
var emphasis: Tween
var film_fade: Tween
var retryable: bool = false
var skip_requested: bool = false
var exiting: bool = false
var grain_time: float = 0.0
var suspense_active: bool = false
var suspense_elapsed: float = 0.0
var suspense_duration: float = 0.0
var suspense_phase: float = 0.0
var suspense_frequency: float = 0.0
var shot_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	$Continue.pressed.connect(_continue)
	$Skip.pressed.connect(_skip)
	$FilmAudio.bus = tuning.effect_bus
	$Flash.color = tuning.flash_color
	var material: ShaderMaterial = $Projector.material.duplicate()
	$Projector.material = material
	material.set_shader_parameter("strength", tuning.grain_strength)
	material.set_shader_parameter("pixel_size", tuning.grain_pixel_size)
	material.set_shader_parameter("frame_rate", tuning.grain_frame_rate)
	material.set_shader_parameter("vignette_strength", tuning.vignette_strength)
	reset()

func _process(delta: float) -> void:
	if not visible:
		return
	_fit_screen_layers()
	if suspense_active:
		suspense_elapsed += delta
		var progress := clampf(suspense_elapsed / maxf(suspense_duration, 0.01), 0.0, 1.0)
		suspense_frequency = lerpf(tuning.shake_start_hz, tuning.shake_end_hz, progress)
		suspense_phase += TAU * suspense_frequency * delta
		var angle := sin(suspense_phase) * deg_to_rad(lerpf(tuning.shake_start_degrees, tuning.shake_end_degrees, progress))
		card_suspense.emit(angle)
		if state in ["cards_entering", "outcome"]:
			for card in [$Outcome/LocalCard, $Outcome/OpponentCard]:
				var visual: Control = card.get_node("Visual")
				visual.pivot_offset = visual.size / 2.0
				visual.rotation = angle
	if $Projector.visible:
		grain_time += delta
		$Projector.material.set_shader_parameter("elapsed", grain_time)

func _fit_screen_layers() -> void:
	var origin := -global_position
	var viewport_size := get_viewport_rect().size
	for layer in [$Treatment, $Projector, $Flash]:
		layer.position = origin
		layer.size = viewport_size
	for curtain in [$CurtainLeft, $CurtainRight]:
		curtain.position.y = origin.y
		curtain.size = Vector2(viewport_size.x / 2.0 + tuning.curtain_overlap_pixels, viewport_size.y)

func waiting(delivery_state: String, detail: String, can_retry: bool) -> void:
	state = delivery_state
	retryable = can_retry
	modulate.a = 1.0
	show()
	$Status.visible = delivery_state != "pending" and not detail.is_empty()
	$Status.text = "" if delivery_state == "pending" else detail
	$Retry.visible = can_retry
	$Retry.disabled = not can_retry
	if pulse and pulse.is_valid():
		pulse.kill()
	$Status.modulate.a = 0.0
	pulse = _tween().set_loops()
	pulse.tween_property($Status, "modulate:a", 1.0, tuning.status_pulse_seconds)
	pulse.tween_property($Status, "modulate:a", tuning.continue_min_alpha, tuning.status_pulse_seconds)

func present(envelope: Dictionary, receipt: Dictionary, actor_id: String) -> void:
	if state in ["retreat", "curtains", "narration", "blackout", "cards_entering", "outcome", "complete"]:
		return
	if not tuning.authoring_agreed:
		waiting("authoring", "Result acknowledged. Cinematic authoring awaits creator direction.", false)
		return
	submission = envelope.duplicate(true)
	local_result = {}
	lines = Narration.beats(submission, tuning)
	for result in submission.result.actors:
		if result.actorId == actor_id:
			local_result = result
	if pulse and pulse.is_valid():
		pulse.kill()
	$Status.hide()
	$Retry.hide()
	$Notice.hide()
	$Notice.text = tuning.committed_copy
	if receipt.get("simulated", false):
		$Notice.text = tuning.preview_copy
	modulate.a = 1.0
	show()
	state = "retreat"
	cinematic_started.emit()
	print("Reveal accepted: simulated=%s serverAcknowledged=%s persisted=%s" % [receipt.get("simulated", false), receipt.get("serverAcknowledged", false), receipt.get("persisted", false)])
	retreat_requested.emit(tuning.retreat_seconds)
	await get_tree().create_timer(tuning.retreat_seconds).timeout
	state = "curtains"
	await _curtains(true)
	_start_film()
	$Treatment.modulate.a = tuning.dim_alpha
	$Projector.show()
	await get_tree().create_timer(tuning.curtain_hold_seconds).timeout
	await _curtains(false)
	state = "narration"
	$Skip.visible = tuning.allow_skip_narration
	$Narrative.show()
	for index in range(lines.size()):
		if skip_requested:
			break
		if index == tuning.shake_start_beat:
			suspense_active = true
			suspense_elapsed = 0.0
			suspense_phase = 0.0
			var remaining_beats := lines.size() - index
			var remaining_pairs := float(remaining_beats) / 2.0
			suspense_duration = remaining_beats * (tuning.text_hold_seconds + tuning.fade_seconds * 2.0) + remaining_pairs * tuning.fade_seconds + tuning.fade_seconds + tuning.black_hold_seconds + tuning.card_enter_seconds + tuning.flash_seconds * tuning.flash_peak_fraction
		$Narrative.text = lines[index].to_upper()
		$Narrative.modulate.a = 0.0
		tween = _tween()
		tween.tween_property($Narrative, "modulate:a", 1.0, tuning.fade_seconds)
		tween.tween_interval(tuning.text_hold_seconds)
		tween.tween_property($Narrative, "modulate:a", 0.0, tuning.fade_seconds)
		await tween.finished
		if (index + 1) % 2 == 0:
			var progress := float(index + 1) / float(lines.size())
			tween = _tween()
			tween.tween_property($Treatment, "modulate:a", lerpf(tuning.dim_alpha, tuning.final_dim_alpha, progress), tuning.fade_seconds)
			await tween.finished
			print("Reveal phase %d complete: dim=%.3f" % [(index + 1) / 2, $Treatment.modulate.a])
	$Skip.hide()
	$Narrative.hide()
	state = "blackout"
	$Projector.hide()
	tween = _tween()
	tween.tween_property($Treatment, "modulate:a", tuning.final_dim_alpha, tuning.fade_seconds)
	await tween.finished
	_stop_film()
	# The arena clears visual state under opaque black; result/context remain frozen.
	outcome_requested.emit(tuning.fade_seconds)
	await get_tree().create_timer(tuning.black_hold_seconds).timeout
	await _enter_result_cards(actor_id)
	await _flash_result(actor_id)
	if tuning.outcome_animation != &"" and $OutcomeAnimation.has_animation(tuning.outcome_animation):
		$OutcomeAnimation.play(tuning.outcome_animation)
		await $OutcomeAnimation.animation_finished
	await get_tree().create_timer(tuning.outcome_hold_seconds).timeout
	state = "complete"
	$Continue.text = tuning.continue_copy
	$Continue.show()
	$Continue.modulate.a = 1.0
	$Continue.disabled = false
	pulse = _tween().set_loops()
	pulse.tween_property($Continue, "modulate:a", tuning.continue_min_alpha, tuning.continue_pulse_seconds)
	pulse.tween_property($Continue, "modulate:a", 1.0, tuning.continue_pulse_seconds)
	print("Reveal complete: result cards and Continue ready")

func _curtains(close: bool) -> void:
	var sound: AudioStream = tuning.curtain_open_sound
	if close:
		sound = tuning.curtain_close_sound
	_play_effect(sound)
	tween = CurtainMotion.animate(self, $CurtainLeft, $CurtainRight, -global_position, get_viewport_rect().size, tuning, close)
	await tween.finished
	if not close:
		$CurtainLeft.hide()
		$CurtainRight.hide()

func _start_film() -> void:
	if tuning.film_roll_sound == null:
		return
	var stream: AudioStream = tuning.film_roll_sound.duplicate()
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	$FilmAudio.stream = stream
	$FilmAudio.volume_db = tuning.film_volume_db
	$FilmAudio.play()

func _stop_film() -> void:
	film_fade = _tween()
	film_fade.tween_property($FilmAudio, "volume_db", tuning.silent_db, tuning.film_fade_seconds)
	film_fade.tween_callback($FilmAudio.stop)

func _enter_result_cards(_actor_id: String) -> void:
	state = "cards_entering"
	$Outcome.show()
	$Outcome.modulate.a = 1.0
	$Outcome.scale = Vector2.ONE
	for node in [$Outcome/Title, $Outcome/Versus, $Outcome/Winner, $Outcome/WinnerName, $Outcome/Points]:
		node.modulate.a = 0.0
	$Outcome/Title.text = tuning.result_title
	var origin := -global_position
	var local: Control = $Outcome/LocalCard
	var opponent: Control = $Outcome/OpponentCard
	for card in [local, opponent]:
		card.face_down()
		card.scale = Vector2.ONE
		card.modulate = Color.WHITE
		card.pivot_offset = card.get_node("Visual").size / 2.0
	local.position = tuning.local_card_position
	opponent.position = tuning.opponent_card_position
	local.position.x = origin.x - local.get_node("Visual").size.x - tuning.offscreen_margin
	opponent.position.x = origin.x + get_viewport_rect().size.x + tuning.offscreen_margin
	tween = create_tween().set_parallel(true).set_trans(tuning.card_transition).set_ease(tuning.card_ease)
	tween.tween_property(local, "position", tuning.local_card_position, tuning.card_enter_seconds)
	tween.tween_property(opponent, "position", tuning.opponent_card_position, tuning.card_enter_seconds)
	await tween.finished

func _flash_result(actor_id: String) -> void:
	$Flash.show()
	$Flash.modulate.a = 0.0
	tween = create_tween().set_trans(tuning.flash_transition)
	tween.tween_property($Flash, "modulate:a", 1.0, tuning.flash_seconds * tuning.flash_peak_fraction).set_ease(tuning.flash_in_ease)
	tween.tween_callback(_show_result.bind(actor_id))
	tween.tween_property($Flash, "modulate:a", 0.0, tuning.flash_seconds * (1.0 - tuning.flash_peak_fraction)).set_ease(tuning.flash_out_ease)
	await tween.finished
	$Flash.hide()
	if emphasis and emphasis.is_running():
		await emphasis.finished

func _show_result(actor_id: String) -> void:
	_stop_suspense()
	state = "outcome"
	_play_effect(tuning.reveal_sound)
	winner_revealed.emit()
	var winner_name: String = tuning.draw_name
	var is_draw: bool = local_result.outcome == "draw"
	emphasis = create_tween().set_parallel(true).set_trans(tuning.card_transition).set_ease(tuning.card_ease)
	for result in submission.result.actors:
		var card: Control = $Outcome/OpponentCard
		if result.actorId == actor_id:
			card = $Outcome/LocalCard
		var display_name := _display_name(result.actorId)
		card.reveal_face(result.finalCard, display_name)
		var scale_value := 1.0
		var alpha := 1.0
		if result.outcome == "win":
			winner_name = display_name
			scale_value = tuning.winner_scale
		elif result.outcome == "loss":
			scale_value = tuning.loser_scale
			alpha = tuning.loser_alpha
		emphasis.tween_property(card, "scale", Vector2.ONE * scale_value, tuning.card_emphasis_seconds)
		emphasis.tween_property(card, "modulate:a", alpha, tuning.card_emphasis_seconds)
	$Outcome/Winner.text = tuning.winner_caption
	if is_draw:
		$Outcome/Winner.text = tuning.draw_caption
	$Outcome/WinnerName.text = winner_name
	$Outcome/Points.text = "+%d points • %s" % [local_result.points, local_result.classification]
	for recipient in submission.recipients:
		if recipient.actorId == actor_id and not recipient.eventualEligible:
			$Outcome/Points.text = tuning.ineligible_copy
	for node in [$Outcome/Title, $Outcome/Versus, $Outcome/Winner, $Outcome/WinnerName, $Outcome/Points]:
		emphasis.tween_property(node, "modulate:a", 1.0, tuning.card_emphasis_seconds)
	$Notice.visible = not $Notice.text.is_empty()

func _display_name(actor_id: String) -> String:
	for recipient in submission.recipients:
		if recipient.actorId == actor_id:
			return str(recipient.displayName)
	return "Player"

func _play_effect(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = tuning.effect_bus
	player.volume_db = tuning.effect_volume_db
	add_child(player)
	shot_players.append(player)
	player.finished.connect(func():
		shot_players.erase(player)
		player.queue_free()
	)
	player.play()

func _tween() -> Tween:
	return create_tween().set_trans(tuning.transition).set_ease(tuning.ease)

func _skip() -> void:
	if tuning.allow_skip_narration and state == "narration":
		skip_requested = true

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if state != "complete" or exiting or $Continue.disabled:
		return
	var tapped: bool = event is InputEventScreenTouch and event.pressed
	if event is InputEventMouseButton:
		tapped = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if tapped or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		$Continue.pressed.emit()

func _continue() -> void:
	if state != "complete" or exiting or $Continue.disabled:
		return
	exiting = true
	$Continue.disabled = true
	if pulse and pulse.is_valid():
		pulse.kill()
	tween = _tween()
	tween.tween_property(self, "modulate:a", 0.0, tuning.exit_seconds)
	await tween.finished
	_restore_result_cards()
	# Keep complete through this signal: the existing arena exit guard owns release.
	continue_requested.emit()

func _restore_result_cards() -> void:
	$Outcome/LocalCard.position = tuning.local_card_position
	$Outcome/OpponentCard.position = tuning.opponent_card_position
	for card in [$Outcome/LocalCard, $Outcome/OpponentCard]:
		card.scale = Vector2.ONE
		card.modulate = Color.WHITE
		card.face_down()

func reset() -> void:
	_stop_suspense()
	for animation in [tween, pulse, projector, emphasis, film_fade]:
		if animation and animation.is_valid():
			animation.kill()
	$OutcomeAnimation.stop()
	$FilmAudio.stop()
	for player in shot_players:
		if is_instance_valid(player):
			player.stop()
			player.queue_free()
	shot_players.clear()
	state = "idle"
	exiting = false
	submission = {}
	local_result = {}
	lines.clear()
	skip_requested = false
	grain_time = 0.0
	modulate.a = 1.0
	$Treatment.modulate.a = 0.0
	$Notice.text = ""
	_restore_result_cards()
	for node in [$Outcome, $Continue, $Narrative, $Skip, $Status, $Retry, $Projector, $CurtainLeft, $CurtainRight, $Flash, $Notice]:
		node.hide()
	$Continue.disabled = true
	hide()

func _stop_suspense() -> void:
	suspense_active = false
	suspense_elapsed = 0.0
	suspense_frequency = 0.0
	card_suspense.emit(0.0)
	for card in [$Outcome/LocalCard, $Outcome/OpponentCard]:
		card.get_node("Visual").rotation = 0.0
