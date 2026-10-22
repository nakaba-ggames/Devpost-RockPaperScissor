extends ProfileProvider
## DEVELOPMENT ONLY: local preview identity, zero-history profile, no backend.
## Exactly one owned file; no origin-wide storage/cache deletion APIs.

const SAVE_PATH: String = "user://devils_rps_preview_v1.cfg"
@export var motion: MenuMotion
var profile: PreviewProfile
var credited_results: Dictionary = {}

func begin_session() -> void:
	await get_tree().create_timer(motion.entry_delay).timeout
	var config := ConfigFile.new()
	var result := config.load(SAVE_PATH)
	profile = PreviewProfile.new()
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
	menu_ready.emit(profile)

func clear_local_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var result := DirAccess.remove_absolute(SAVE_PATH)
		if result != OK:
			request_failed.emit("storage", "Could not clear local preview data. Please retry.")
			return
	profile = null
	credited_results.clear()
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
	if not preload("res://scripts/results/receipt_gate.gd").matches(submission, receipt):
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
		if result.outcome == "win":
			profile.wins += 1
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
		print("M06 preview applied once: outcome=%s points=%d session-only; no persistence" % [result.outcome, result.points])
		return true
	return false
