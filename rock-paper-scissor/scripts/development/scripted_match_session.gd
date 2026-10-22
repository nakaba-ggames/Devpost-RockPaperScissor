extends MatchSession
## Explicit M02–M08 development adapter; never calls GD-Sync queue/account APIs.
enum Scenario { OPPONENT_FOUND, NORMAL_TIMEOUT, FAILURE }
@export var settings: MatchmakingSettings
@export var fixture: SearchFixture
@export var scenario: Scenario = Scenario.OPPONENT_FOUND
var fallback_wait_seconds: float = 0.0
var search_started_msec: int = 0

func begin(player: MatchParticipant) -> int:
	var token := super.begin(player)
	if token == 0:
		return 0
	if settings == null or fixture == null:
		report_failure(token, "Development search configuration is missing.")
		return token
	if settings.fallback_min_seconds < 30.0 or settings.fallback_max_seconds > 45.0 or settings.fallback_min_seconds > settings.fallback_max_seconds:
		report_failure(token, "Fallback must stay within 30–45 seconds.")
		return token
	search_started_msec = Time.get_ticks_msec()
	fallback_wait_seconds = randf_range(settings.fallback_min_seconds, settings.fallback_max_seconds)
	print("M02 search began: generation=%d scenario=%d fallback=%.3fs" % [token, scenario, fallback_wait_seconds])
	_run_script(token, scenario)
	return token

func _run_script(token: int, selected: Scenario) -> void:
	var delay := fixture.found_seconds
	if selected == Scenario.NORMAL_TIMEOUT:
		delay = fallback_wait_seconds
	elif selected == Scenario.FAILURE:
		delay = fixture.failure_seconds
	await get_tree().create_timer(delay).timeout
	if not is_current(token):
		return
	if selected == Scenario.FAILURE:
		report_failure(token, "Search could not complete. Please return and try again.")
		return
	# There is no live queue to cancel here. M09 must await queue/leave ACK
	# before invoking commit_found for a bot; a tween is never that ACK.
	var opponent := MatchParticipant.new()
	opponent.player_id = fixture.opponent_id
	opponent.display_name = fixture.opponent_name
	opponent.overall_points = fixture.overall_points
	opponent.control_kind = "scripted_opponent"
	if selected == Scenario.NORMAL_TIMEOUT:
		opponent.player_id = fixture.fallback_id
		opponent.display_name = fixture.fallback_name
		opponent.control_kind = "development_bot"
	var context := MatchContext.new()
	context.match_id = "dev-" + Crypto.new().generate_random_bytes(16).hex_encode()
	context.search_generation = token
	context.local_player = local_player
	context.opponent = opponent
	commit_found(token, context)
	print("M02 match reserved: generation=%d kind=%s elapsed=%.3fs" % [token, opponent.control_kind, (Time.get_ticks_msec() - search_started_msec) / 1000.0])
