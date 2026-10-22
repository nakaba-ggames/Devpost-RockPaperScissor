extends Control
## Shared read-only presentation; no gameplay-node reads or history calculation.
@export_enum("stats", "records", "leaderboard", "quests") var view_kind: String = "stats"
@export var view_title: String = "Detailed Stats"
@export var tuning: Resource
const METRICS: Array[String] = ["overallPoints", "winRate", "lieCount", "honestCount"]
const FINAL_CARD = preload("res://scenes/ui/reveal_card.tscn")
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
	if view_kind == "quests":
		$Content/DevClock/Daily.pressed.connect(_advance_clock.bind("daily"))
		$Content/DevClock/Weekly.pressed.connect(_advance_clock.bind("weekly"))

func open(source: ProfileProvider) -> void:
	provider = source
	generation += 1
	show()
	moving = true
	_clear_rows()
	status.text = "Loading…"
	more.hide()
	retry.hide()
	modulate.a = 0.0
	content.offset_top = content_top + tuning.travel_pixels
	if motion_tween:
		motion_tween.kill()
	motion_tween = create_tween().set_parallel(true).set_trans(tuning.transition).set_ease(tuning.ease)
	motion_tween.tween_property(self, "modulate:a", 1.0, tuning.fade_seconds)
	motion_tween.tween_property(content, "offset_top", content_top, tuning.fade_seconds)
	await motion_tween.finished
	moving = false
	_query("")

func close() -> void:
	if moving:
		return
	generation += 1
	busy = false
	moving = true
	if motion_tween:
		motion_tween.kill()
	motion_tween = create_tween().set_parallel(true).set_trans(tuning.transition).set_ease(tuning.ease)
	motion_tween.tween_property(self, "modulate:a", 0.0, tuning.fade_seconds)
	motion_tween.tween_property(content, "offset_top", content_top + tuning.travel_pixels, tuning.fade_seconds)
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
		response = await provider.request_quests()
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
			status.text = "No history retained this session."
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

func _render_stats(data: Dictionary) -> void:
	if data.matches == 0:
		status.text = "No history retained this session."
	_label("%d matches • %d W / %d L / %d D" % [data.matches, data.wins, data.losses, data.draws], rows, true)
	_label("Win Rate  %s\nWin Streak  %d\nAllegiance  %s" % [_percent(data.winRate), data.winStreak, data.allegiance])
	_label("Winning final cards", rows, true)
	for card in ["Rock", "Paper", "Scissor"]:
		_label("%s  %s" % [card, _percent(data.winningCards[card])])
	_label("Winning claims", rows, true)
	_label("Lie  %s\nHonest  %s" % [_percent(data.lyingWinPercent), _percent(data.honestWinPercent)])
	_label("All credited matches", rows, true)
	_label("Lie Count  %d\nHonest Count  %d" % [data.lieCount, data.honestCount])

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
	_label("Result • %s • +%d points" % [str(record.outcome).capitalize(), record.points], group, true)
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
	card.get_node("Face").text = actor.finalCard
	card.get_node("Caption").text = display_name
	if actor.outcome == "loss":
		card.get_node("Visual").modulate.a = tuning.losing_alpha
		card.get_node("Face").modulate.a = tuning.losing_alpha

func _render_entry(entry: Dictionary) -> void:
	var value := str(entry[METRICS[category.selected]])
	if category.selected == 1:
		value = _percent(entry.winRate)
	_label("%d. %s\n%s" % [entry.position, entry.displayName, value], rows, true)

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
	$Content/DevClock.visible = data.developmentOnly
	if data.has("serverTime"):
		var local_time := Time.get_datetime_string_from_unix_time(int(data.serverTime) + 7 * 3600).replace("T", " ")
		status.text = "Dev time • %s GMT+7\nReset 05:00 daily / Monday weekly" % local_time
	_label("Weekly objectives", rows, true)
	for quest in data.weeklyQuests:
		_render_quest(quest)
	if data.weeklyQuests.is_empty():
		_label("No weekly objectives configured.")
	_label("Today's daily history", rows, true)
	_label("Completed rewards arrive on menu entry.")
	for quest in data.dailyHistory:
		_render_quest(quest)

func _render_quest(quest: Dictionary) -> void:
	_label("%s\n%d/%d • %s • +%d points" % [quest.title, quest.progress, quest.target, str(quest.state).capitalize(), quest.rewardPoints])

func _advance_clock(period: String) -> void:
	if busy or moving:
		return
	provider.development_advance_quest_clock(period)
	_query("")
