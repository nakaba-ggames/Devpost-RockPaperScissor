extends Control
## Shared read-only presentation; no gameplay-node reads or history calculation.
@export_enum("stats", "records", "leaderboard", "quests") var view_kind: String = "stats"
@export var view_title: String = "Detailed Stats"
@export var tuning: Resource
const MENU_ICONS = preload("res://resources/presentation/menu_icons.tres")
const METRICS: Array[String] = ["overallPoints", "winRate", "lieCount", "honestCount"]
const FINAL_CARD = preload("res://scenes/ui/result_card.tscn")
const SOUND_CONFIG = preload("res://resources/presentation/ui_sound_config.tres")

@onready var content: VBoxContainer = $Content
@onready var rows: VBoxContainer = $Content/Scroll/Rows
@onready var status: Label = $Content/Status
@onready var category: OptionButton = $Content/Category
@onready var more: Button = $Content/More
@onready var retry: Button = $Content/Retry
var provider: ProfileProvider
var next_cursor: String = ""
var pending_cursor: String = ""
var generation: int = 0
var busy: bool = false
var moving: bool = false
var motion_tween: Tween
var content_top: float

func _ready() -> void:
	$Content/Header/Title.text = view_title
	$Content/Header/Icon.texture = MENU_ICONS.for_view(view_kind)
	_prepare_back_caption()
	# Preserve the authored insets in native and binary-exported inherited scenes.
	_apply_insets($Panel, tuning.panel_insets)
	_apply_insets(content, tuning.content_insets)
	content_top = content.offset_top
	category.visible = view_kind == "leaderboard"
	$Content/Header/Back.pressed.connect(close)
	more.pressed.connect(_load_more)
	retry.pressed.connect(_retry)
	category.item_selected.connect(_category_changed)

	if has_node("Backdrop"):
		$Backdrop.gui_input.connect(_on_backdrop_input)

func _on_backdrop_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		close()

func open(source: ProfileProvider) -> void:
	provider = source
	generation += 1
	show()
	moving = true
	_clear_rows()
	status.text = "Loading…"
	more.hide()
	retry.hide()

	SOUND_CONFIG.play(self, "modal_open")

	var panel := $Panel
	var backdrop := $Backdrop
	backdrop.modulate.a = 0.0
	modulate.a = 1.0
	panel.scale = Vector2.ONE * tuning.open_scale
	content.scale = Vector2.ONE * tuning.open_scale
	panel.modulate.a = 0.0
	content.modulate.a = 0.0
	panel.pivot_offset = panel.size / 2.0
	content.pivot_offset = content.size / 2.0

	if motion_tween and motion_tween.is_valid():
		motion_tween.kill()
	motion_tween = create_tween().set_parallel(true).set_trans(tuning.open_transition).set_ease(tuning.open_ease)
	motion_tween.tween_property(backdrop, "modulate:a", tuning.dimmer_alpha, tuning.open_seconds)
	motion_tween.tween_property(panel, "scale", Vector2.ONE, tuning.open_seconds)
	motion_tween.tween_property(content, "scale", Vector2.ONE, tuning.open_seconds)
	motion_tween.tween_property(panel, "modulate:a", 1.0, tuning.open_seconds)
	motion_tween.tween_property(content, "modulate:a", 1.0, tuning.open_seconds)
	await motion_tween.finished
	moving = false
	_query("")

func close() -> void:
	if moving:
		return
	generation += 1
	busy = false
	moving = true

	SOUND_CONFIG.play(self, "modal_close")

	var panel := $Panel
	var backdrop := $Backdrop
	if motion_tween and motion_tween.is_valid():
		motion_tween.kill()
	# Step 3.6: Hiding is quicker than showing (0.2s vs 0.35s)
	motion_tween = create_tween().set_parallel(true).set_trans(tuning.close_transition).set_ease(tuning.close_ease)
	motion_tween.tween_property(backdrop, "modulate:a", 0.0, tuning.close_seconds)
	motion_tween.tween_property(panel, "scale", Vector2.ONE * tuning.close_scale, tuning.close_seconds)
	motion_tween.tween_property(content, "scale", Vector2.ONE * tuning.close_scale, tuning.close_seconds)
	motion_tween.tween_property(panel, "modulate:a", 0.0, tuning.close_seconds)
	motion_tween.tween_property(content, "modulate:a", 0.0, tuning.close_seconds)
	await motion_tween.finished
	hide()
	moving = false
	print("M07 closed: " + view_kind)

func reset() -> void:
	generation += 1
	if motion_tween:
		motion_tween.kill()
	busy = false
	moving = false
	hide()
	_clear_rows()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()

func _category_changed(_index: int) -> void:
	SOUND_CONFIG.play(self, "tab_select")
	generation += 1
	busy = false
	_query("")

func _load_more() -> void:
	_query(next_cursor)

func _retry() -> void:
	_query(pending_cursor)

func _query(cursor: String) -> void:
	if busy or not visible:
		return
	busy = true
	pending_cursor = cursor
	var ticket := generation
	if cursor.is_empty():
		_clear_rows()
		$Content/Scroll.scroll_vertical = 0
	status.text = "Loading…"
	more.hide()
	retry.hide()
	var response: Dictionary
	if view_kind == "stats":
		response = await provider.request_stats()
	elif view_kind == "records":
		response = await provider.request_records(cursor, tuning.page_size)
	elif view_kind == "quests":
		response = await provider.request_quests(cursor)
	else:
		response = await provider.request_leaderboard(METRICS[category.selected], cursor, tuning.page_size)
	if ticket != generation or not visible:
		return
	busy = false
	if response.has("error"):
		status.text = str(response.error.message)
		retry.visible = response.error.retryable
		return
	status.text = ""
	if view_kind == "stats":
		_render_stats(response)
	elif view_kind == "quests":
		next_cursor = response.get("nextCursor", "")
		more.visible = not next_cursor.is_empty()
		_render_quests(response)
	else:
		next_cursor = response.nextCursor
		more.visible = not next_cursor.is_empty()
		if view_kind == "records":
			for record in response.records:
				_render_record(record)
		else:
			for entry in response.entries:
				_render_entry(entry)
		if rows.get_child_count() == 0:
			status.text = "No saved history yet."
	_animate_rows()
	print("M07 view ready: %s rows=%d next=%s" % [view_kind, rows.get_child_count(), next_cursor])
	var back := $Content/Header/Back
	# Invalidate the focused button after the scroll content changes its layout.
	back.call_deferred("queue_redraw")
	print("M07 header: %s rect=%s scale=%s visible=%s alpha=%s" % [view_kind, back.get_global_rect(), back.scale, back.is_visible_in_tree(), back.modulate.a])

func _clear_rows() -> void:
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	next_cursor = ""

func _label(text: String, parent: Node = rows, large: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 21)
	if large:
		label.add_theme_font_size_override("font_size", 25)
	parent.add_child(label)
	return label

func _percent(value: Variant) -> String:
	if value == null:
		return "N/A"
	return "%.1f%%" % float(value)

func _create_card(bg_color: Color = Color(0.06, 0.1, 0.14, 0.75), border_color: Color = Color(0.18, 0.28, 0.38, 0.45)) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _render_stats(data: Dictionary) -> void:
	if data.matches == 0:
		status.text = "Your first match starts your record."

	# Card 1: Match Summary
	var overview_card := _create_card(Color(0.08, 0.12, 0.18, 0.85), Color(0.3, 0.45, 0.6, 0.6))
	var ov_box := VBoxContainer.new()
	ov_box.add_theme_constant_override("separation", 6)

	var ov_header := Label.new()
	ov_header.text = "MATCH SUMMARY"
	ov_header.add_theme_font_size_override("font_size", 16)
	ov_header.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
	ov_box.add_child(ov_header)

	var row1 := HBoxContainer.new()
	var matches_lbl := Label.new()
	matches_lbl.text = "%d Matches" % data.matches
	matches_lbl.add_theme_font_size_override("font_size", 22)
	matches_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var record_lbl := Label.new()
	record_lbl.text = "%dW / %dL / %dD" % [data.wins, data.losses, data.draws]
	record_lbl.add_theme_font_size_override("font_size", 20)
	record_lbl.add_theme_color_override("font_color", Color(0.85, 0.72, 0.45))
	row1.add_child(matches_lbl)
	row1.add_child(record_lbl)
	ov_box.add_child(row1)

	var row2 := VBoxContainer.new()
	var winrate_lbl := Label.new()
	winrate_lbl.text = "Win Rate: %s" % _percent(data.winRate)
	winrate_lbl.add_theme_font_size_override("font_size", 18)
	winrate_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var streak_lbl := Label.new()
	streak_lbl.text = "Win streak: %d" % data.winStreak
	streak_lbl.add_theme_font_size_override("font_size", 18)
	streak_lbl.add_theme_color_override("font_color", Color(0.5, 0.85, 0.7))
	row2.add_child(winrate_lbl)
	row2.add_child(streak_lbl)
	ov_box.add_child(row2)
	overview_card.add_child(ov_box)
	rows.add_child(overview_card)

	# Card 2: Winning Final Cards
	var cards_panel := _create_card()
	var cb_box := VBoxContainer.new()
	cb_box.add_theme_constant_override("separation", 8)
	var cb_title := Label.new()
	cb_title.text = "WINNING FINAL CARDS"
	cb_title.add_theme_font_size_override("font_size", 16)
	cb_title.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
	cb_box.add_child(cb_title)

	var cards_row := HBoxContainer.new()
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.add_theme_constant_override("separation", 16)
	for card_name in ["Rock", "Paper", "Scissor"]:
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var c_name := Label.new()
		c_name.text = card_name.to_upper()
		c_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		c_name.add_theme_font_size_override("font_size", 16)
		var c_val := Label.new()
		c_val.text = _percent(data.winningCards[card_name])
		c_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		c_val.add_theme_font_size_override("font_size", 20)
		c_val.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
		col.add_child(c_name)
		col.add_child(c_val)
		cards_row.add_child(col)
	cb_box.add_child(cards_row)
	cards_panel.add_child(cb_box)
	rows.add_child(cards_panel)

	# Card 3: Claims & Allegiance
	var claim_card := _create_card()
	var cl_box := VBoxContainer.new()
	cl_box.add_theme_constant_override("separation", 6)
	var cl_title := Label.new()
	cl_title.text = "CLAIM EFFECTIVENESS"
	cl_title.add_theme_font_size_override("font_size", 16)
	cl_title.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
	cl_box.add_child(cl_title)

	var cl_row := VBoxContainer.new()
	var lie_lbl := Label.new()
	lie_lbl.text = "Lie Win: %s (%d)" % [_percent(data.lyingWinPercent), data.lieCount]
	lie_lbl.add_theme_font_size_override("font_size", 18)
	lie_lbl.add_theme_color_override("font_color", Color(0.95, 0.45, 0.4))
	lie_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var honest_lbl := Label.new()
	honest_lbl.text = "Honest Win: %s (%d)" % [_percent(data.honestWinPercent), data.honestCount]
	honest_lbl.add_theme_font_size_override("font_size", 18)
	honest_lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 0.95))
	cl_row.add_child(lie_lbl)
	cl_row.add_child(honest_lbl)
	cl_box.add_child(cl_row)
	claim_card.add_child(cl_box)
	rows.add_child(claim_card)

func _render_record(record: Dictionary) -> void:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 12)
	rows.add_child(group)
	var own: Dictionary = {}
	var opponent: Dictionary = {}
	for actor in record.actors:
		if actor.actorId == record.ownerId:
			own = actor
		else:
			opponent = actor
	_label("vs " + str(opponent.displayName), group, true)
	_label("Initial\nYou: %s\n%s: %s" % [own.initialCard, opponent.displayName, opponent.initialCard], group)
	var points_text := "Points N/A"
	if record.points != null:
		points_text = "+%d points" % record.points
	_label("Result • %s • %s" % [str(record.outcome).capitalize(), points_text], group, true)
	var pair := HBoxContainer.new()
	pair.alignment = BoxContainer.ALIGNMENT_CENTER
	pair.add_theme_constant_override("separation", 32)
	group.add_child(pair)
	_final_card(own, "You", pair)
	_final_card(opponent, opponent.displayName, pair)

func _final_card(actor: Dictionary, display_name: String, parent: Node) -> void:
	var card := FINAL_CARD.instantiate()
	card.custom_minimum_size = Vector2(150, 280)
	parent.add_child(card)
	card.reveal_face(str(actor.finalCard), display_name)
	if actor.outcome == "loss":
		card.get_node("Visual").modulate.a = tuning.losing_alpha
		card.get_node("Icon").modulate.a = tuning.losing_alpha

func _render_entry(entry: Dictionary) -> void:
	var card := _create_card(Color(0.06, 0.1, 0.14, 0.75), Color(0.15, 0.22, 0.3, 0.4))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)

	var pos: int = int(entry.position)
	var rank_badge := Label.new()
	rank_badge.text = "#%d" % pos
	rank_badge.custom_minimum_size = Vector2(48, 0)
	rank_badge.add_theme_font_size_override("font_size", 22)

	if pos == 1:
		rank_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	elif pos == 2:
		rank_badge.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	elif pos == 3:
		rank_badge.add_theme_color_override("font_color", Color(0.85, 0.55, 0.35))
	else:
		rank_badge.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	row.add_child(rank_badge)

	var name_lbl := Label.new()
	name_lbl.text = str(entry.displayName)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(name_lbl)

	var val_str := str(entry[METRICS[category.selected]])
	if category.selected == 1:
		val_str = _percent(entry.winRate)
	var val_lbl := Label.new()
	val_lbl.text = val_str
	val_lbl.add_theme_font_size_override("font_size", 20)
	val_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	row.add_child(val_lbl)

	card.add_child(row)
	rows.add_child(card)

func _animate_rows() -> void:
	rows.modulate.a = 0.0
	var tween := create_tween().set_trans(tuning.transition).set_ease(tuning.ease)
	tween.tween_property(rows, "modulate:a", 1.0, tuning.fade_seconds)

func _apply_insets(control: Control, insets: Vector4) -> void:
	control.offset_left = insets.x
	control.offset_top = insets.y
	control.offset_right = -insets.z
	control.offset_bottom = -insets.w

func _prepare_back_caption() -> void:
	# Keep navigation text independently drawable on the web renderer.
	# The existing inherited button still owns input, styling and press motion.
	var back: Button = $Content/Header/Back
	back.text = ""
	back.tooltip_text = "Back to menu"
	var caption := Label.new()
	caption.name = "BackCaption"
	caption.text = "Back"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.add_theme_font_size_override("font_size", back.get_theme_font_size("font_size"))
	caption.add_theme_color_override("font_color", back.get_theme_color("font_color"))
	back.add_child(caption)
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _render_quests(data: Dictionary) -> void:
	if data.has("serverTime"):
		var local_time := Time.get_datetime_string_from_unix_time(int(data.serverTime) + 7 * 3600).replace("T", " ")
		status.text = "Server time • %s GMT+7\nReset 05:00 daily / Monday weekly" % local_time
	_label("Weekly Objectives", rows, true)
	for quest in data.weeklyQuests:
		_render_quest(quest)
	if data.weeklyQuests.is_empty():
		_label("No weekly objectives configured.")
	_label("Daily History", rows, true)
	_label("Completed rewards arrive on menu entry.")
	for quest in data.dailyHistory:
		_render_quest(quest)

func _render_quest(quest: Dictionary) -> void:
	var is_completed: bool = str(quest.state).to_lower() == "completed" or int(quest.progress) >= int(quest.target)
	var fill := Color(0.04, 0.08, 0.12, 0.8)
	var border := Color(0.2, 0.35, 0.5, 0.5)
	if is_completed:
		fill = Color(0.03, 0.1, 0.07, 0.8)
		border = Color(0.2, 0.6, 0.35, 0.6)
	var card := _create_card(fill, border)
	var q_box := VBoxContainer.new()
	q_box.add_theme_constant_override("separation", 6)

	var top_row := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = str(quest.title)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_lbl.add_theme_font_size_override("font_size", 20)
	top_row.add_child(title_lbl)

	var pts_lbl := Label.new()
	pts_lbl.text = "+%d PTS" % int(quest.rewardPoints)
	pts_lbl.add_theme_font_size_override("font_size", 18)
	pts_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.35))
	top_row.add_child(pts_lbl)
	q_box.add_child(top_row)

	var p_bar := ProgressBar.new()
	p_bar.custom_minimum_size = Vector2(0, 10)
	p_bar.show_percentage = false
	p_bar.add_theme_stylebox_override("background", tuning.quest_track)
	p_bar.add_theme_stylebox_override("fill", tuning.quest_fill)
	p_bar.max_value = float(quest.target)
	p_bar.value = float(quest.progress)
	q_box.add_child(p_bar)

	var bot_row := HBoxContainer.new()
	var prog_lbl := Label.new()
	prog_lbl.text = "%d / %d" % [int(quest.progress), int(quest.target)]
	prog_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prog_lbl.add_theme_font_size_override("font_size", 16)
	prog_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	bot_row.add_child(prog_lbl)

	var tag_lbl := Label.new()
	tag_lbl.text = str(quest.state).to_upper()
	if is_completed:
		tag_lbl.text = "COMPLETED"
	tag_lbl.add_theme_font_size_override("font_size", 16)
	var tag_color := Color(0.4, 0.75, 0.9)
	if is_completed:
		tag_color = Color(0.3, 0.9, 0.5)
	tag_lbl.add_theme_color_override("font_color", tag_color)
	bot_row.add_child(tag_lbl)
	q_box.add_child(bot_row)

	card.add_child(q_box)
	rows.add_child(card)
