extends MatchSession
## Emulates real search duration before pairing with bot without exposing bot identity.
@export var motion: SearchMotion = preload("res://resources/presentation/search_motion.tres")
@export var first_play: Resource = preload("res://resources/presentation/offline_first_play.tres")
var first_match: bool = false
var api: Node
var deployment_revision: String = "presentation-only"
var arena_condition: int = 0
var scenario: int = 0
var active_token: int = 0

func begin(player: MatchParticipant) -> int:
	var token := super.begin(player)
	if token == 0:
		return 0
	active_token = token
	player.backend_verified = false
	player.rating_source = "development_preview"
	player.control_kind = "local_preview"
	var bot := MatchParticipant.new()
	bot.player_id = "presentation-ember"
	bot.display_name = "Ember"
	bot.control_kind = "development_bot"
	# Explicit presentation examples, never fetched/saved player statistics.
	bot.public_profile = {"initialCardPercentages": {"Rock": 70.0, "Paper": 20.0, "Scissor": 10.0}, "liePercentage": 60.0, "switchPercentage": 50.0}
	bot.switch_percentage = 50.0
	var context := MatchContext.new()
	context.match_id = "presentation-" + Crypto.new().generate_random_bytes(16).hex_encode()
	context.search_generation = token
	context.local_player = player
	context.opponent = bot
	context.round_log = RoundLog.new()
	context.round_log.arena_condition = clampi(arena_condition, 0, 2)

	_schedule_bot_pair(token, context)
	return token

func _schedule_bot_pair(token: int, context: MatchContext) -> void:
	var seconds := motion.preview_search_seconds
	if first_match and first_play.enabled:
		seconds = first_play.search_seconds
	print("Presentation search: %.1fs; first_match=%s; simulated bot only" % [seconds, first_match])
	await get_tree().create_timer(seconds).timeout
	if is_current(token):
		commit_found(token, context)

func cancel() -> void:
	active_token = 0
	super.cancel()
