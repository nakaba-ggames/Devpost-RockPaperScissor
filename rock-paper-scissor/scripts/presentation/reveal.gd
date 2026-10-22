extends Control
## Presentation of an accepted, frozen result. No gameplay or persistence writes.
signal continue_requested
signal retreat_requested(seconds: float)
signal outcome_requested(seconds: float)
const Narration = preload("res://scripts/presentation/round_narration.gd")
@export var tuning: Resource
var state: String = "idle"
var lines: Array[String] = []
var submission: Dictionary = {}
var local_result: Dictionary = {}
var tween: Tween
var pulse: Tween
var projector: Tween
var retryable: bool = false
var skip_requested: bool = false

func _ready() -> void:
	$Continue.pressed.connect(_continue)
	$Skip.pressed.connect(_skip)
	hide()

func waiting(delivery_state: String, detail: String, can_retry: bool) -> void:
	state = delivery_state
	retryable = can_retry
	show()
	$Status.show()
	$Status.text = detail
	$Retry.visible = can_retry
	$Retry.disabled = not can_retry
	if pulse:
		pulse.kill()
	$Status.modulate.a = 0.0
	pulse = _tween().set_loops()
	pulse.tween_property($Status, "modulate:a", 1.0, tuning.status_pulse_seconds)
	pulse.tween_property($Status, "modulate:a", 0.45, tuning.status_pulse_seconds)

func present(envelope: Dictionary, receipt: Dictionary, actor_id: String) -> void:
	if state in ["retreat", "narration", "outcome", "complete"]:
		return
	if not tuning.authoring_agreed:
		waiting("authoring", "Result acknowledged. Cinematic authoring awaits creator direction.", false)
		return
	if not tuning.temporary_outcome_agreed and tuning.outcome_animation == &"":
		waiting("authoring", "Result acknowledged. Creator outcome animation is required.", false)
		return
	submission = envelope
	lines = Narration.beats(submission, tuning)
	for result in submission.result.actors:
		if result.actorId == actor_id:
			local_result = result
	if pulse:
		pulse.kill()
	$Status.hide()
	$Retry.hide()
	$Notice.text = tuning.committed_copy
	if receipt.get("simulated", false):
		$Notice.text = tuning.preview_copy
	show()
	state = "retreat"
	print("M06 receipt accepted before cinematic: simulated=%s serverAcknowledged=%s persisted=%s" % [receipt.get("simulated", false), receipt.get("serverAcknowledged", false), receipt.get("persisted", false)])
	retreat_requested.emit(tuning.retreat_seconds)
	tween = _tween()
	tween.tween_interval(tuning.retreat_seconds)
	await tween.finished
	tween = _tween()
	tween.tween_property($Treatment, "modulate:a", tuning.dim_alpha, tuning.fade_seconds)
	await tween.finished
	$CurtainLeft.show()
	$CurtainRight.show()
	$Projector.show()
	projector = _tween().set_loops()
	projector.tween_property($Projector, "modulate:a", tuning.projector_max_alpha, tuning.projector_cycle_seconds)
	projector.tween_property($Projector, "modulate:a", tuning.projector_min_alpha, tuning.projector_cycle_seconds)
	tween = _tween().set_parallel(true)
	tween.tween_property($CurtainLeft, "position:x", -$CurtainLeft.size.x, tuning.curtain_seconds)
	tween.tween_property($CurtainRight, "position:x", size.x, tuning.curtain_seconds)
	await tween.finished
	state = "narration"
	$Skip.visible = tuning.allow_skip_narration
	$Narrative.show()
	for index in range(lines.size()):
		if skip_requested:
			break
		var line: String = lines[index]
		$Narrative.text = line
		print("M06 narrative: " + line.replace("\n", " / "))
		$Narrative.modulate.a = 0.0
		tween = _tween()
		tween.tween_property($Narrative, "modulate:a", 1.0, tuning.fade_seconds)
		tween.tween_interval(tuning.text_hold_seconds)
		tween.tween_property($Narrative, "modulate:a", 0.0, tuning.fade_seconds)
		await tween.finished
		# Each pair recounts one phase for both players: 0.3 → full black.
		if (index + 1) % 2 == 0:
			var progress := float(index + 1) / float(lines.size())
			tween = _tween()
			tween.tween_property($Treatment, "modulate:a", lerpf(tuning.dim_alpha, tuning.final_dim_alpha, progress), tuning.fade_seconds)
			await tween.finished
	$Skip.hide()
	$Narrative.hide()
	projector.kill()
	tween = _tween()
	tween.tween_property($Treatment, "modulate:a", tuning.final_dim_alpha, tuning.fade_seconds)
	tween.tween_interval(tuning.black_hold_seconds)
	await tween.finished
	outcome_requested.emit(tuning.fade_seconds)
	tween = _tween().set_parallel(true)
	tween.tween_property($Treatment, "modulate:a", 0.0, tuning.fade_seconds)
	tween.tween_property($Projector, "modulate:a", 0.0, tuning.fade_seconds)
	await tween.finished
	$CurtainLeft.hide()
	$CurtainRight.hide()
	$Projector.hide()
	state = "outcome"
	print("M06 outcome begins: treatment alpha=%.1f" % $Treatment.modulate.a)
	var title: String = tuning.draw_copy
	if local_result.outcome == "win":
		title = tuning.win_copy
	elif local_result.outcome == "loss":
		title = tuning.loss_copy
	$Outcome/Title.text = title
	for result in submission.result.actors:
		for recipient in submission.recipients:
			if recipient.actorId == result.actorId:
				var card: Control = $Outcome/OpponentCard
				if result.actorId == actor_id:
					card = $Outcome/LocalCard
				card.get_node("Face").text = result.finalCard
				card.get_node("Caption").text = recipient.displayName
	$Outcome/Points.text = "+%d points • %s" % [local_result.points, local_result.classification]
	for recipient in submission.recipients:
		if recipient.actorId == actor_id and not recipient.eventualEligible:
			$Outcome/Points.text = tuning.ineligible_copy
	$Outcome.show()
	$Outcome.pivot_offset = $Outcome.size / 2.0
	if tuning.outcome_animation != &"" and $OutcomeAnimation.has_animation(tuning.outcome_animation):
		$OutcomeAnimation.play(tuning.outcome_animation)
		await $OutcomeAnimation.animation_finished
	elif tuning.temporary_outcome_agreed:
		$Outcome.modulate.a = 0.0
		$Outcome.scale = tuning.outcome_start_scale
		tween = _tween().set_parallel(true)
		tween.tween_property($Outcome, "modulate:a", 1.0, tuning.outcome_seconds)
		tween.tween_property($Outcome, "scale", Vector2.ONE, tuning.outcome_seconds)
		await tween.finished
	else:
		waiting("authoring", "Configured outcome animation is missing.", false)
		return
	tween = _tween()
	tween.tween_interval(tuning.outcome_hold_seconds)
	await tween.finished
	state = "complete"
	$Continue.show()
	$Continue.modulate.a = 0.0
	tween = _tween()
	tween.tween_property($Continue, "modulate:a", 1.0, tuning.continue_seconds)
	await tween.finished
	$Continue.disabled = false
	print("M06 presentation complete: Tap To Continue available")

func _tween() -> Tween:
	return create_tween().set_trans(tuning.transition).set_ease(tuning.ease)

func _skip() -> void:
	if tuning.allow_skip_narration and state == "narration":
		skip_requested = true

func _continue() -> void:
	if state == "complete" and not $Continue.disabled:
		$Continue.disabled = true
		continue_requested.emit()

func reset() -> void:
	if tween:
		tween.kill()
	if pulse:
		pulse.kill()
	if projector:
		projector.kill()
	$OutcomeAnimation.stop()
	state = "idle"
	submission = {}
	local_result = {}
	lines.clear()
	skip_requested = false
	$Treatment.modulate.a = 0.0
	$Notice.text = ""
	$CurtainLeft.position.x = 0.0
	$CurtainRight.position.x = size.x / 2.0
	for node in [$Outcome, $Continue, $Narrative, $Skip, $Status, $Retry, $Projector, $CurtainLeft, $CurtainRight]:
		node.hide()
	$Continue.disabled = true
	hide()
