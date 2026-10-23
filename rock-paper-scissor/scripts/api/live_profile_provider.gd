extends ProfileProvider
const HttpApi = preload("res://scripts/api/http_api.gd")
const SAVE_PATH: String = "user://devils_rps_account_v1.cfg"
@export var api: Node
var profile: PlayerProfile
var deployment_revision: String = ""
var menu_request_id: String = ""
var menu_pending: bool = false
var cursor_positions: Dictionary = {}

func begin_session() -> void:
	if api.credential.is_empty():
		var saved := ConfigFile.new()
		var error := saved.load(SAVE_PATH)
		if error == OK:
			api.credential = str(saved.get_value("account", "credential", ""))
			if api.credential.is_empty():
				request_failed.emit("account", "Remembered account is invalid. Sign up again to create a new account.")
				return
		elif error != ERR_FILE_NOT_FOUND:
			request_failed.emit("server", "Account storage is unavailable. Wait and retry.")
			return
	var mode := "resume"
	if api.credential.is_empty():
		mode = "create"
	var response: Dictionary = await api.send("anonymous", HTTPClient.METHOD_POST, {"mode": mode}, mode == "resume")
	if response.has("error"):
		_failure(response)
		return
	if response.has("credential"):
		api.credential = response.credential
	if not _remember():
		return
	deployment_revision = response.rulesRevision
	_install_profile(response.profile)
	identity_ready.emit(profile)

func _remember() -> bool:
	var saved := ConfigFile.new()
	saved.set_value("account", "credential", api.credential)
	if saved.save(SAVE_PATH) != OK:
		request_failed.emit("server", "Could not remember this account. Keep this page open and retry.")
		return false
	return true

func save_display_name(display_name: String) -> void:
	var response: Dictionary = await api.send("profile", HTTPClient.METHOD_PATCH, {"displayName": display_name})
	if response.has("error"):
		_failure(response, "name")
		return
	_install_profile(response.profile)
	identity_ready.emit(profile)

func enter_menu() -> void:
	if not menu_pending:
		menu_request_id = HttpApi.uuid()
		menu_pending = true
	var response: Dictionary = await api.send("menu", HTTPClient.METHOD_POST, {"requestId": menu_request_id})
	if response.has("error"):
		_failure(response)
		return
	menu_pending = false
	_install_profile(response.profile)
	var snapshot := _quests(response)
	var daily: Dictionary = snapshot.dailyQuest
	profile.daily_quest_text = "Daily • unavailable"
	if not daily.is_empty():
		profile.daily_quest_text = "Daily • %s  %d/%d • +%d" % [daily.title, daily.progress, daily.target, daily.rewardPoints]
	menu_snapshot_updated.emit(snapshot)
	menu_ready.emit(profile)

func clear_local_data() -> void:
	api.cancel_all()
	for path in [SAVE_PATH, "user://devils_rps_preview_v1.cfg"]:
		if FileAccess.file_exists(path) and DirAccess.remove_absolute(path) != OK:
			request_failed.emit("storage", "Could not clear this game's account storage. Retry.")
			return
	api.credential = ""
	profile = null
	deployment_revision = ""
	menu_pending = false
	cursor_positions.clear()
	local_data_cleared.emit()

func _failure(response: Dictionary, ordinary_kind: String = "server") -> void:
	var kind := ordinary_kind
	if response.error.code in ["CREDENTIAL_INVALID", "CREDENTIAL_MISSING"]:
		kind = "account"
	request_failed.emit(kind, str(response.error.message))

func _install_profile(data: Dictionary) -> void:
	profile = PlayerProfile.new()
	profile.player_id = data.playerId
	if data.displayName != null:
		profile.display_name = data.displayName
	for pair in [["overall_points", "overallPoints"], ["games_played", "completedMatches"], ["wins", "wins"], ["losses", "losses"], ["draws", "draws"], ["win_streak", "winStreak"], ["honest_wins", "honestWins"], ["lying_wins", "lyingWins"], ["lie_count", "lieCount"], ["honest_count", "honestCount"], ["switch_count", "switchCount"], ["initial_cards", "initialCardCounts"], ["final_cards", "finalCardCounts"], ["winning_cards", "winningFinalCardCounts"]]:
		profile.set(pair[0], data[pair[1]])

static func stats_view(data: Dictionary) -> Dictionary:
	var allegiance := "Human"
	if data.lyingWins > data.honestWins:
		allegiance = "Devil"
	elif data.honestWins > data.lyingWins:
		allegiance = "Angel"
	elif data.wins > 0:
		allegiance = "Angel / Devil"
	var view := data.duplicate(true)
	view.merge({"matches": data.completedMatches, "winningCards": data.winningCardPercentages, "initialCards": data.initialCardPercentages,
		"lyingWinPercent": data.lyingWinPercentage, "honestWinPercent": data.honestWinPercentage,
		"liePercent": data.liePercentage, "switchPercent": data.switchPercentage, "allegiance": allegiance})
	return view

func request_stats() -> Dictionary:
	var response: Dictionary = await api.send("player?playerId=" + profile.player_id.uri_encode(), HTTPClient.METHOD_GET, {}, false)
	if response.has("error"):
		return response
	return stats_view(response.profile)

func request_records(cursor: String = "", limit: int = 3) -> Dictionary:
	var path := "records?limit=%d" % limit
	if not cursor.is_empty():
		path += "&cursor=" + cursor.uri_encode()
	var response: Dictionary = await api.send(path)
	if response.has("error"):
		return response
	var records: Array = []
	for row in response.records:
		var own: Dictionary = row.self.duplicate(true)
		var opponent: Dictionary = row.opponent.duplicate(true)
		own.actorId = own.playerId
		opponent.actorId = opponent.playerId
		own.outcome = row.result
		opponent.outcome = "draw"
		if row.result == "win":
			opponent.outcome = "loss"
		elif row.result == "loss":
			opponent.outcome = "win"
		records.append({"ownerId": own.playerId, "matchId": row.matchId, "resultId": row.recordId, "actors": [own, opponent], "outcome": row.result, "points": row.get("points")})
	return {"records": records, "nextCursor": _cursor(response.nextCursor)}

static func _cursor(value: Variant) -> String:
	if value == null:
		return ""
	return str(value)

func request_leaderboard(metric: String, cursor: String = "", limit: int = 3) -> Dictionary:
	var path := "leaderboard?metric=%s&limit=%d" % [metric.uri_encode(), limit]
	if not cursor.is_empty():
		path += "&cursor=" + cursor.uri_encode()
	var response: Dictionary = await api.send(path)
	if response.has("error"):
		return response
	var position := 0
	if not cursor.is_empty():
		position = int(cursor_positions.get(metric + cursor, 0))
	for entry in response.entries:
		position += 1
		entry.position = position
	var next := _cursor(response.nextCursor)
	cursor_positions[metric + next] = position
	response.nextCursor = next
	return response

func request_quests(cursor: String = "") -> Dictionary:
	var path := "quests"
	if not cursor.is_empty():
		path += "?historyBefore=" + cursor.uri_encode()
	var response: Dictionary = await api.send(path)
	if response.has("error"):
		return response
	return _quests(response)

static func _quest(row: Variant) -> Dictionary:
	if not row is Dictionary:
		return {}
	return {"questInstanceId": row.questInstanceId, "title": row.definition.title, "progress": row.counter, "target": row.definition.target, "rewardPoints": row.definition.reward_points, "state": row.status}

static func _quests(data: Dictionary) -> Dictionary:
	var snapshot := data.duplicate(true)
	snapshot.profile = stats_view(data.profile)
	snapshot.stats = stats_view(data.stats)
	snapshot.dailyQuest = _quest(data.dailyQuest)
	snapshot.weeklyQuests = data.weeklyQuests.map(_quest)
	snapshot.dailyHistory = data.dailyHistory.map(_quest)
	snapshot.serverTime = Time.get_unix_time_from_datetime_string(str(data.serverTime).split(".")[0].trim_suffix("Z"))
	snapshot.nextCursor = ""
	if data.dailyHistoryNextBefore != null:
		snapshot.nextCursor = str(int(data.dailyHistoryNextBefore))
	return snapshot
