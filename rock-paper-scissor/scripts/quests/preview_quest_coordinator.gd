class_name PreviewQuestCoordinator
extends RefCounted
const Definition = preload("res://scripts/quests/quest_definition.gd")
const Catalogue = preload("res://scripts/quests/quest_catalogue.gd")
const Clock = preload("res://scripts/quests/preview_clock.gd")
const Instance = preload("res://scripts/quests/quest_instance.gd")
## No disk, network, profile writes or lifetime-statistics reads.
const DAY: int = 86400
const WEEK: int = 7 * DAY
# GMT+7 minus 05:00 cutoff = UTC + 2 hours.
const CUTOFF_SHIFT: int = 2 * 3600
var catalogue: Catalogue
var clock: Clock
var owner_id: String
var daily_start: int = -1
var weekly_start: int = -1
var daily_index: int = 0
var event_sequence: int = 0
var daily_history: Array[Instance] = []
var weekly: Array[Instance] = []
var current_daily: Instance

func _init(config: Catalogue, time_source: Clock, owner: String) -> void:
	catalogue = config
	clock = time_source
	owner_id = owner

static func periods(now: int) -> Dictionary:
	var day_index := int(floor(float(now + CUTOFF_SHIFT) / DAY))
	var daily := day_index * DAY - CUTOFF_SHIFT
	# Unix epoch was Thursday: Monday is day index -3.
	var weekly := daily - posmod(day_index + 3, 7) * DAY
	return {"daily": daily, "weekly": weekly}

func refresh_periods() -> void:
	var now := clock.now_unix()
	var bounds := periods(now)
	# Expiry is always applied before settlement, including completed/unpaid.
	for quest in daily_history + weekly:
		quest.expire(now)
	if bounds.daily != daily_start:
		daily_start = bounds.daily
		daily_index = 0
		daily_history.clear()
		current_daily = null
		_assign_daily()
	if bounds.weekly != weekly_start:
		weekly_start = bounds.weekly
		weekly.clear()
		for definition in catalogue.weekly_objectives:
			weekly.append(_instance(definition, "weekly", weekly_start, WEEK))

func _instance(definition: Definition, kind: String, start: int, duration: int) -> Instance:
	var quest := Instance.new()
	quest.instance_id = "preview-quest-" + Crypto.new().generate_random_bytes(16).hex_encode()
	quest.owner_id = owner_id
	quest.definition = definition
	quest.period_kind = kind
	quest.period_start = start
	quest.expires_at = start + duration
	quest.activated_at = clock.now_unix()
	quest.activated_after_event = event_sequence
	return quest

func _assign_daily() -> void:
	if catalogue.daily_cycle.is_empty():
		return
	var definition := catalogue.daily_cycle[daily_index % catalogue.daily_cycle.size()]
	daily_index += 1
	current_daily = _instance(definition, "daily", daily_start, DAY)
	daily_history.append(current_daily)

func active_instance_ids() -> Array[String]:
	refresh_periods()
	var ids: Array[String] = []
	for quest in daily_history + weekly:
		if quest.completed_at < 0 and not quest.expired:
			ids.append(quest.instance_id)
	return ids

func consume(event_id: String, actor: Dictionary, outcome: String, active_at_play: Array) -> void:
	refresh_periods()
	event_sequence += 1
	# Capture before advancing: the finishing event never reaches a new daily.
	var active: Array[Instance] = []
	if current_daily != null:
		active.append(current_daily)
	active.append_array(weekly)
	for quest in active:
		if quest.instance_id in active_at_play:
			quest.advance(event_id, event_sequence, actor, outcome, clock.now_unix())
	if current_daily != null and current_daily.completed_at >= 0:
		_assign_daily()

func settle_menu_entry() -> Array[Dictionary]:
	refresh_periods()
	var grants: Array[Dictionary] = []
	for quest in daily_history + weekly:
		if quest.completed_at >= 0 and quest.paid_at < 0 and not quest.expired:
			quest.paid_at = clock.now_unix()
			grants.append({"questInstanceId": quest.instance_id, "points": quest.definition.reward_points})
	return grants

func snapshot() -> Dictionary:
	refresh_periods()
	var daily: Dictionary = {}
	if current_daily != null:
		daily = current_daily.snapshot()
	var history: Array[Dictionary] = []
	var objectives: Array[Dictionary] = []
	for quest in daily_history:
		history.append(quest.snapshot())
	for quest in weekly:
		objectives.append(quest.snapshot())
	return {"dailyQuest": daily, "dailyHistory": history, "weeklyQuests": objectives, "serverTime": clock.now_unix(), "periods": {"daily": daily_start, "weekly": weekly_start}, "rulesRevision": catalogue.revision, "developmentOnly": true, "timeAuthority": "development preview"}
