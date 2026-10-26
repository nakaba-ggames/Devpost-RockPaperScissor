class_name TitleIntroSequence
extends Control
## Shared title playback. The live root supplies readiness; offline waits stay isolated.
signal sfx_requested(sound_id: String)
signal pattern_background_activated
signal intro_completed
signal live_entry_state_changed
signal web_start_requested

const SOUND_CONFIG = preload("res://resources/presentation/ui_sound_config.tres")
@export var motion: Resource = preload("res://resources/presentation/title_motion.tres")
# Preserve the existing scene's audio slots; the shared .tres is the fallback.
@export var sfx_rock: AudioStream
@export var sfx_paper: AudioStream
@export var sfx_scissors: AudioStream
@export var sfx_devils: AudioStream
@export var sfx_chring: AudioStream
@export var sfx_tap: AudioStream

@onready var title_root: Control = $TitleContainer
@onready var devils_group: Control = $TitleContainer/DevilsGroup
@onready var rock_label: Label = $TitleContainer/RPSGroup/RockLabel
@onready var paper_label: Label = $TitleContainer/RPSGroup/PaperLabel
@onready var scissors_label: Label = $TitleContainer/RPSGroup/ScissorsLabel
@onready var spinner_group: Control = $SpinnerGroup
@onready var spinner_icon: TextureRect = $SpinnerGroup/SpinnerIcon
@onready var status_label: Label = $SpinnerGroup/StatusLabel
@onready var tap_prompt: Label = $TapPrompt
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var can_tap: bool = false
var is_active: bool = false
var generation: int = 0
var sequence_tween: Tween
var loop_tweens: Array[Tween] = []
var live_entry_gate: bool = false
var live_entry_ready: bool = false
var live_entry_status: String = "CONNECTING TO SERVER..."
var prompt_reached: bool = false
var awaiting_web_start: bool = false
var web_start_confirmed: bool = false
@onready var prompt_copy: String = $TapPrompt.text

func set_live_entry_state(text: String, ready: bool) -> void:
	live_entry_status = text.to_upper()
	live_entry_ready = ready
	if not live_entry_gate or not is_active:
		return
	status_label.text = live_entry_status
	if prompt_reached:
		can_tap = ready
		tap_prompt.text = prompt_copy
		if not ready:
			tap_prompt.text = live_entry_status
	live_entry_state_changed.emit()

func _ready() -> void:
	reset_state()

func reset_state() -> void:
	generation += 1
	is_active = false
	can_tap = false
	prompt_reached = false
	awaiting_web_start = false
	live_entry_state_changed.emit()
	tap_prompt.text = prompt_copy
	if sequence_tween and sequence_tween.is_valid():
		sequence_tween.kill()
	_stop_loop_tweens()
	title_root.scale = Vector2.ONE
	title_root.modulate.a = 1.0
	for item in [devils_group, rock_label, paper_label, scissors_label]:
		item.scale = Vector2.ZERO
		item.modulate.a = 0.0
		item.rotation = 0.0
	spinner_icon.rotation = 0.0
	spinner_group.hide()
	spinner_group.modulate.a = 0.0
	status_label.text = ""
	tap_prompt.hide()
	hide()

func _stop_loop_tweens() -> void:
	for tween in loop_tweens:
		if tween and tween.is_valid():
			tween.kill()
	loop_tweens.clear()

func play_sequence(wait_for_live_entry: bool = false) -> void:
	reset_state()
	live_entry_gate = wait_for_live_entry
	if live_entry_gate:
		live_entry_ready = false
		live_entry_status = "CONNECTING TO SERVER..."
	is_active = true
	var ticket := generation
	show()
	var background := _find_scrolling_background()
	if background:
		background.reset_preview()
	if live_entry_gate and OS.has_feature("web") and not web_start_confirmed:
		# A real browser gesture unlocks audio before the intro and service start.
		awaiting_web_start = true
		tap_prompt.text = motion.web_start_copy
		tap_prompt.modulate.a = 1.0
		tap_prompt.show()
		await web_start_requested
		if ticket != generation:
			return
		tap_prompt.hide()
		tap_prompt.text = prompt_copy
	await get_tree().process_frame
	if ticket != generation:
		return
	title_root.position.y = size.y * motion.top_fraction
	for control in [rock_label, paper_label, scissors_label, devils_group, title_root, spinner_icon]:
		control.pivot_offset = control.size / 2.0
	var words := [rock_label, paper_label, scissors_label]
	var streams := [sfx_rock, sfx_paper, sfx_scissors]
	var sounds := ["sfx_rock", "sfx_paper", "sfx_scissors"]
	for index in words.size():
		if index > 0:
			await get_tree().create_timer(motion.word_gap_seconds).timeout
			if ticket != generation:
				return
		_play_sound(streams[index], sounds[index])
		await _pop(words[index], motion.word_seconds)
		if ticket != generation:
			return
	await get_tree().create_timer(motion.devil_delay_seconds).timeout
	if ticket != generation:
		return
	_play_sound(sfx_devils, "sfx_devils")
	await _pop(devils_group, motion.devil_seconds)
	if ticket != generation:
		return
	_play_sound(sfx_chring, "sfx_chring")
	if background:
		background.flash(_activate_pattern.bind(background))
	for control in words:
		_start_rotation_loop(control)
	_start_spinner_loop()
	if live_entry_gate:
		status_label.text = live_entry_status
		while not live_entry_ready:
			await live_entry_state_changed
			if ticket != generation:
				return
	else:
		status_label.text = "Connecting to server..."
		await get_tree().create_timer(motion.server_preview_seconds).timeout
		if ticket != generation:
			return
		status_label.text = "Connecting to multiplayer server..."
		await get_tree().create_timer(motion.multiplayer_preview_seconds).timeout
		if ticket != generation:
			return
	sequence_tween = create_tween().set_parallel(true).set_trans(motion.center_transition).set_ease(motion.center_ease)
	sequence_tween.tween_property(spinner_group, "modulate:a", 0.0, motion.spinner_fade_seconds)
	sequence_tween.tween_property(title_root, "position:y", size.y * motion.center_fraction - title_root.size.y / 2.0, motion.center_seconds)
	await sequence_tween.finished
	if ticket != generation:
		return
	spinner_group.hide()
	tap_prompt.show()
	tap_prompt.modulate.a = 1.0
	var pulse := create_tween().set_loops().set_trans(motion.idle_transition).set_ease(motion.idle_ease)
	pulse.tween_property(tap_prompt, "modulate:a", motion.pulse_min_alpha, motion.pulse_seconds)
	pulse.tween_property(tap_prompt, "modulate:a", 1.0, motion.pulse_seconds)
	loop_tweens.append(pulse)
	prompt_reached = true
	can_tap = true
	if live_entry_gate:
		set_live_entry_state(live_entry_status, live_entry_ready)

func _pop(control: Control, seconds: float) -> void:
	control.modulate.a = 1.0
	sequence_tween = create_tween().set_trans(motion.pop_transition).set_ease(motion.pop_ease)
	sequence_tween.tween_property(control, "scale", Vector2.ONE, seconds)
	await sequence_tween.finished

func _activate_pattern(background: Node) -> void:
	background.set_pattern_active(true)
	pattern_background_activated.emit()

func _gui_input(event: InputEvent) -> void:
	_handle_continue(event)

func _unhandled_input(event: InputEvent) -> void:
	_handle_continue(event)

func _handle_continue(event: InputEvent) -> void:
	var tapped: bool = event is InputEventScreenTouch and event.pressed
	if event is InputEventMouseButton:
		tapped = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not tapped and not event.is_action_pressed("ui_accept"):
		return
	if awaiting_web_start:
		get_viewport().set_input_as_handled()
		awaiting_web_start = false
		web_start_confirmed = true
		web_start_requested.emit()
		return
	if can_tap:
		get_viewport().set_input_as_handled()
		_on_tap()

func _on_tap() -> void:
	if not can_tap:
		return
	can_tap = false
	prompt_reached = false
	_play_sound(sfx_tap, "sfx_tap")
	tap_prompt.hide()
	_stop_loop_tweens()
	sequence_tween = create_tween().set_parallel(true).set_trans(motion.exit_transition).set_ease(motion.exit_ease)
	sequence_tween.tween_property(title_root, "scale", Vector2.ONE * motion.exit_scale, motion.exit_seconds)
	sequence_tween.tween_property(title_root, "modulate:a", 0.0, motion.exit_seconds)
	await sequence_tween.finished
	is_active = false
	hide()
	intro_completed.emit()

func _start_rotation_loop(control: Control) -> void:
	# Pick a fresh duration and angle on each cycle.
	while is_active:
		var ticket := generation
		var seconds := randf_range(motion.rotation_seconds_min, motion.rotation_seconds_max)
		var angle := deg_to_rad(randf_range(-motion.rotation_degrees, motion.rotation_degrees))
		var tween := create_tween().set_trans(motion.idle_transition).set_ease(motion.idle_ease)
		tween.tween_property(control, "rotation", angle, seconds)
		loop_tweens.append(tween)
		await tween.finished
		loop_tweens.erase(tween)
		if ticket != generation or not is_active:
			return

func _start_spinner_loop() -> void:
	spinner_group.show()
	var fade := create_tween()
	fade.tween_property(spinner_group, "modulate:a", 1.0, motion.spinner_fade_seconds)
	loop_tweens.append(fade)
	var spin := create_tween().set_loops()
	spin.tween_property(spinner_icon, "rotation", TAU, motion.spinner_seconds).as_relative()
	loop_tweens.append(spin)

func _play_sound(stream: AudioStream, sound_id: String) -> void:
	sfx_requested.emit(sound_id)
	if stream:
		sfx_player.stream = stream
		sfx_player.play()
	else:
		SOUND_CONFIG.play(self, sound_id)

func _find_scrolling_background() -> Node:
	return get_parent().get_node_or_null("ScrollingBackground")
