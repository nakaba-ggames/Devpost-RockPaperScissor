class_name ProfileProvider
extends Node
## Small asynchronous seam for the M10/M12 API provider.
## No credentials are sent to GD-Sync and no account API exists in M01.

signal identity_ready(profile: PreviewProfile)
signal menu_ready(profile: PreviewProfile)
signal menu_snapshot_updated(snapshot: Dictionary)
signal request_failed(kind: String, detail: String)
signal local_data_cleared

func begin_session() -> void:
	pass

func save_display_name(_display_name: String) -> void:
	pass

func enter_menu() -> void:
	pass

func apply_acknowledged_result(_submission: Dictionary, _receipt: Dictionary) -> bool:
	return false

func clear_local_data() -> void:
	pass

# Read-only API-shaped queries. Error: {error: {code, message, retryable}}.
# Cursor is opaque to views; pages are bounded by the provider.
func request_stats() -> Dictionary:
	return {"error": {"code": "unavailable", "message": "Statistics unavailable.", "retryable": true}}

func request_records(_cursor: String = "", _limit: int = 3) -> Dictionary:
	return {"error": {"code": "unavailable", "message": "Records unavailable.", "retryable": true}}

func request_leaderboard(_metric: String, _cursor: String = "", _limit: int = 3) -> Dictionary:
	return {"error": {"code": "unavailable", "message": "Leaderboard unavailable.", "retryable": true}}

func request_quests() -> Dictionary:
	return {"error": {"code": "unavailable", "message": "Quests unavailable.", "retryable": true}}

func begin_preview_match(_match_id: String) -> void:
	pass

func development_advance_quest_clock(_period: String) -> void:
	pass
