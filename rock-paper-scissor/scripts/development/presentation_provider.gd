extends "res://scripts/api/local_preview_provider.gd"
## Synchronous memory-only session. No prompts, files or live credentials.
const TEST_NAME: String = "Test-Human"
var deployment_revision: String = "presentation-only"

func begin_session() -> void:
	if profile == null:
		profile = PlayerProfile.new()
		profile.player_id = "presentation-local"
		_reset_quests()
	profile.display_name = TEST_NAME
	identity_ready.emit(profile)

func save_display_name(_display_name: String) -> void:
	# There is no naming UI in this session; its identity is deliberately fixed.
	profile.display_name = TEST_NAME
	identity_ready.emit(profile)

func clear_local_data() -> void:
	profile = null
	credited_results.clear()
	records.clear()
	_reset_quests()
	local_data_cleared.emit()
