extends ProfileProvider
const QuestConfig = preload("res://scripts/quests/quest_catalogue.gd")
const QuestClock = preload("res://scripts/quests/preview_clock.gd")
const QuestCoordinator = preload("res://scripts/quests/preview_quest_coordinator.gd")
## DEVELOPMENT ONLY: local preview identity, zero-history profile, no backend.
## Exactly one owned file; no origin-wide storage/cache deletion APIs.

const SAVE_PATH: String = "user://devils_rps_preview_v1.cfg"
@export var motion: MenuMotion
@export var quest_catalogue: QuestConfig
var quest_clock := QuestClock.new()
var quests: QuestCoordinator
var quest_matches: Dictionary = {}
var menu_snapshot: Dictionary = {}
var profile: PlayerProfile
var credited_results: Dictionary = {}
var records: Array[Dictionary] = []
@export var roster: Resource
const METRICS: Array[String] = ["overallPoints", "winRate", "lieCount", "honestCount"]
const MAX_PAGE_SIZE: int = 20

func begin_session() -> void:
	await get_tree().create_timer(motion.entry_delay).timeout
	var config := ConfigFile.new()
	var result := config.load(SAVE_PATH)
	profile = PlayerProfile.new()
	credited_results.clear()
	records.clear()
	_reset_quests()
	if result == OK:
		profile.player_id = str(config.get_value("preview", "player_id", ""))
		profile.display_name = str(config.get_value("preview", "display_name", ""))
		if profile.player_id.is_empty():
			request_failed.emit("account", "Local preview identity could not be read.")
			return
	elif result == ERR_FILE_NOT_FOUND:
		profile.player_id = "preview-" + Crypto.new().generate_random_bytes(16).hex_encode()
	else:
		request_failed.emit("server", "Local preview storage is unavailable. Please wait and retry.")
		return
	identity_ready.emit(profile)

func save_display_name(display_name: String) -> void:
	var trimmed := display_name.strip_edges()
	if trimmed.is_empty():
		request_failed.emit("name", "Please enter a display name.")
		return
	var config := ConfigFile.new()
	config.set_value("preview", "player_id", profile.player_id)
	config.set_value("preview", "display_name", trimmed)
	var result := config.save(SAVE_PATH)
	if result != OK:
		request_failed.emit("server", "Could not remember this preview. Please retry.")
		return
	profile.display_name = trimmed
	identity_ready.emit(profile)
	print("M01 preview: named local identity saved (no backend)")

func enter_menu() -> void:
	if profile == null:
		return
	var grants: Array[Dictionary] = []
	if _ensure_quests():
		grants = quests.settle_menu_entry()
		for grant in grants:
			profile.overall_points += int(grant.points)
	_refresh_menu_snapshot(grants)
	menu_ready.emit(profile)

func clear_local_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var result := DirAccess.remove_absolute(SAVE_PATH)
		if result != OK:
			request_failed.emit("storage", "Could not clear local preview data. Please retry.")
			return
	profile = null
	credited_results.clear()
	records.clear()
	_reset_quests()
	print("M01 preview: owned local file cleared; no backend request")
	local_data_cleared.emit()

func apply_acknowledged_result(submission: Dictionary, receipt: Dictionary) -> bool:
	# Session-only simulation. Never writes match data to disk or uploads history.
	if profile == null or not submission.get("developmentOnly", false):
		return false
	if submission.get("persistentCreditAllowed", true) or not receipt.get("simulated", false):
		return false
	if receipt.get("persisted", true) or receipt.get("serverAcknowledged", true) or receipt.get("persistentCreditAllowed", true):
		return false
	if not preload("res://scripts/development/presentation_receipt.gd").matches(submission, receipt):
		return false
	if credited_results.has(submission.resultId):
		return false
	var eligible := false
	for recipient in submission.recipients:
		if recipient.actorId == profile.player_id:
			eligible = recipient.eventualEligible and not recipient.departedBeforeCommit and not recipient.takeoverSide
	if not eligible:
		return false
	for result in submission.result.actors:
		if result.actorId != profile.player_id:
			continue
		credited_results[submission.resultId] = true
		profile.overall_points += int(result.points)
		profile.games_played += 1
		profile.initial_cards[result.initialCard] += 1
		profile.final_cards[result.finalCard] += 1
		profile.lie_count += int(result.lyingMatchCount)
		profile.honest_count += int(result.honestMatchCount)
		profile.switch_count += int(result.actualSwitch)
		_retain_record(submission, result)
		if result.outcome == "win":
			profile.wins += 1
			profile.winning_cards[result.finalCard] += 1
			profile.win_streak += 1
			if result.classification == "honest":
				profile.honest_wins += 1
			else:
				profile.lying_wins += 1
		elif result.outcome == "loss":
			profile.losses += 1
			profile.win_streak = 0
		else:
			profile.draws += 1
		if _ensure_quests():
			for actor in submission.history.actors:
				if actor.actorId == profile.player_id:
					quests.consume(submission.resultId, actor, result.outcome, quest_matches.get(submission.matchId, []))
			quest_matches.erase(submission.matchId)
		_refresh_menu_snapshot([])
		print("M06 preview applied once: outcome=%s points=%d session-only; no persistence" % [result.outcome, result.points])
		return true
	return false

func _retain_record(submission: Dictionary, own_result: Dictionary) -> void:
	var actors: Array[Dictionary] = []
	for actor in submission.history.actors:
		var display_name := ""
		for recipient in submission.recipients:
			if recipient.actorId == actor.actorId:
				display_name = recipient.displayName
		var outcome := "draw"
		for result in submission.result.actors:
			if result.actorId == actor.actorId:
				outcome = result.outcome
		actors.append({"actorId": actor.actorId, "displayName": display_name, "initialCard": actor.initialCard, "finalCard": actor.finalCard, "outcome": outcome})
	records.push_front({"ownerId": profile.player_id, "resultId": submission.resultId, "matchId": submission.matchId, "actors": actors, "outcome": own_result.outcome, "points": own_result.points})

func _percentage(numerator: int, denominator: int) -> Variant:
	if denominator == 0:
		return null
	return 100.0 * numerator / denominator

func _card_percentages(counters: Dictionary, denominator: int) -> Dictionary:
	var values := {}
	for card in counters:
		values[card] = _percentage(counters[card], denominator)
	return values

func _snapshot() -> Dictionary:
	var allegiance := "Human"
	if profile.lying_wins > profile.honest_wins:
		allegiance = "Devil"
	elif profile.honest_wins > profile.lying_wins:
		allegiance = "Angel"
	elif profile.wins > 0:
		allegiance = "Angel / Devil"
	return {"playerId": profile.player_id, "displayName": profile.display_name, "overallPoints": profile.overall_points, "matches": profile.games_played, "wins": profile.wins, "losses": profile.losses, "draws": profile.draws, "winStreak": profile.win_streak, "winRate": _percentage(profile.wins, profile.games_played), "lieCount": profile.lie_count, "honestCount": profile.honest_count, "winningCards": _card_percentages(profile.winning_cards, profile.wins), "lyingWinPercent": _percentage(profile.lying_wins, profile.wins), "honestWinPercent": _percentage(profile.honest_wins, profile.wins), "initialCards": _card_percentages(profile.initial_cards, profile.games_played), "liePercent": _percentage(profile.lie_count, profile.games_played), "switchPercent": _percentage(profile.switch_count, profile.games_played), "allegiance": allegiance}

func request_stats() -> Dictionary:
	await get_tree().create_timer(motion.entry_delay).timeout
	if profile == null:
		return _no_session()
	return _snapshot()

func request_records(cursor: String = "", limit: int = 3) -> Dictionary:
	await get_tree().create_timer(motion.entry_delay).timeout
	if profile == null:
		return _no_session()
	var owned: Array[Dictionary] = []
	for record in records:
		if record.ownerId == profile.player_id:
			owned.append(record)
	return _page(owned, "records", cursor, limit)

func request_leaderboard(metric: String, cursor: String = "", limit: int = 3) -> Dictionary:
	await get_tree().create_timer(motion.entry_delay).timeout
	if profile == null:
		return _no_session()
	if not metric in METRICS:
		return {"error": {"code": "metric", "message": "Category unavailable.", "retryable": false}}
	var entries: Array[Dictionary] = []
	if roster != null:
		entries.assign(roster.entries.duplicate(true))
	entries.append(_snapshot())
	# Null win rate follows measured rates; deterministic ties use player ID.
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a[metric] == b[metric]:
			return str(a.playerId) < str(b.playerId)
		if a[metric] == null:
			return false
		if b[metric] == null:
			return true
		return a[metric] > b[metric])
	for index in range(entries.size()):
		entries[index]["position"] = index + 1
	return _page(entries, "entries", cursor, limit)

func _page(values: Array[Dictionary], key: String, cursor: String, limit: int) -> Dictionary:
	var start := maxi(0, cursor.to_int())
	var end := mini(values.size(), start + clampi(limit, 1, MAX_PAGE_SIZE))
	var next_cursor := ""
	if end < values.size():
		next_cursor = str(end)
	return {key: values.slice(start, end).duplicate(true), "nextCursor": next_cursor}

func _no_session() -> Dictionary:
	return {"error": {"code": "session", "message": "Open a local preview first.", "retryable": true}}

func _reset_quests() -> void:
	quests = null
	quest_clock.reset()
	quest_matches.clear()
	menu_snapshot.clear()

func _ensure_quests() -> bool:
	if profile == null or quest_catalogue == null or not quest_catalogue.development_only:
		return false
	if quests == null:
		quests = QuestCoordinator.new(quest_catalogue, quest_clock, profile.player_id)
	quests.refresh_periods()
	return true

func begin_preview_match(match_id: String) -> void:
	if _ensure_quests():
		quest_matches[match_id] = quests.active_instance_ids()

func _refresh_menu_snapshot(grants: Array[Dictionary]) -> void:
	menu_snapshot = {"dailyQuest": {}, "dailyHistory": [], "weeklyQuests": [], "grants": grants, "profile": _snapshot(), "stats": _snapshot(), "developmentOnly": true}
	if _ensure_quests():
		menu_snapshot.merge(quests.snapshot(), true)
	var daily: Dictionary = menu_snapshot.dailyQuest
	profile.daily_quest_text = "Daily • no preview catalogue"
	if not daily.is_empty():
		profile.daily_quest_text = "Daily • %s  %d/%d • +%d" % [daily.title, daily.progress, daily.target, daily.rewardPoints]
	menu_snapshot_updated.emit(menu_snapshot.duplicate(true))

func request_quests(_cursor: String = "") -> Dictionary:
	await get_tree().create_timer(motion.entry_delay).timeout
	if profile == null:
		return _no_session()
	_refresh_menu_snapshot([])
	return menu_snapshot.duplicate(true)

func development_advance_quest_clock(period: String) -> void:
	# Explicit preview controls only; no OS clock change, payment or backend call.
	if not _ensure_quests():
		return
	var bounds := QuestCoordinator.periods(quest_clock.now_unix())
	var next := int(bounds.daily) + QuestCoordinator.DAY
	if period == "weekly":
		next = int(bounds.weekly) + QuestCoordinator.WEEK
	quest_clock.set_development_time(next)
	_refresh_menu_snapshot([])
