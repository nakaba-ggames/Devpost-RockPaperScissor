extends MatchSession
## Real service queue; permanent API participant binding before arena play.
const Request = preload("res://addons/GD-Sync/Scripts/Types/MatchmakingRequest.gd")
const Wire = preload("res://scripts/networking/match_wire.gd")
signal packet_received(kind: String, envelope: Dictionary, sender: int)
signal peer_departed(peer: int)
signal authority_changed
@export var settings: MatchmakingSettings
@export var rules: ArenaRules
@export var bot_personality: Resource
var api: Node
var deployment_revision: String = ""
var registration_body: Dictionary = {}
var binding_confirming: bool = false
var offer_observation: String = ""
var sdk: Node
var scenario: int = 0 # Old game-facing start signature; never selects a fake human.
var arena_condition: int = 0
## Refreshed from the authenticated menu profile before every live search.
var completed_matches: int = -1
var first_play: bool = false
## Frozen by backend registration, never inferred from a local preview flag.
var intro_bot_match: bool = false
var fallback_wait_seconds: float = 0.0
var search_started_msec: int = 0
var pending_lobby: String = ""
var closing: bool = false
var cancel_confirmed: bool = false
var pending_context: MatchContext
var offer_sent: bool = false
var offer_payload: Dictionary = {}
var offer_retry_msec: int = 0
var coordinator: Node
var sent_bytes: int = 0
var received_bytes: int = 0
var sent_messages: int = 0
var received_messages: int = 0
var wire_sequence: int = 0
var received_sequences: Dictionary = {}
var handshake_started_msec: int = 0
var pairing_observation: String = ""
var profile_observation: String = ""

func _ready() -> void:
	sdk = get_node_or_null("/root/GDSync")
	if sdk == null:
		return
	sdk.expose_func(_receive)
	sdk.matchmaking_match_found.connect(_queue_found)
	sdk.matchmaking_cancelled.connect(_queue_cancelled)
	sdk.matchmaking_failed.connect(_queue_failed)
	sdk.lobby_joined.connect(_joined)
	sdk.client_left.connect(_client_left)
	sdk.host_changed.connect(_host_changed)
	sdk.disconnected.connect(_disconnected)

func begin(player: MatchParticipant) -> int:
	if closing or pending_context != null:
		return 0
	intro_bot_match = false
	var token := super.begin(player)
	if token == 0:
		return 0
	if sdk == null or sdk.get_client_id() < 0 or not sdk.is_active():
		report_failure(token, "GD-Sync is not connected. Return and retry the connection.")
		return token
	if not settings.rating_policy_configured or not settings.bot_selection_configured:
		report_failure(token, "Matchmaking configuration needs creator agreement.")
		return token
	if completed_matches < 0:
		report_failure(token, "Your match history is unavailable. Return to menu and retry.")
		return token
	if settings.first_bot_seconds <= 0.0 or settings.fallback_min_seconds <= 0.0 or settings.fallback_min_seconds > settings.fallback_max_seconds:
		report_failure(token, "Matchmaking delay configuration is invalid.")
		return token
	if not sdk.lobby_get_name().is_empty():
		report_failure(token, "Previous lobby has not been released.")
		return token
	_reset_wire()
	local_player.peer_id = sdk.get_client_id()
	local_player.control_kind = "human_peer"
	search_started_msec = Time.get_ticks_msec()
	first_play = completed_matches == 0
	fallback_wait_seconds = settings.first_bot_seconds if first_play else randf_range(settings.fallback_min_seconds, settings.fallback_max_seconds)
	if first_play:
		# No human queue is started for a player without a completed match.
		print("Live search generation=%d completedMatches=%d botOnly=true delay=%.3fs" % [token, completed_matches, fallback_wait_seconds])
		_fallback_after(token)
		return token
	var request := Request.new(2)
	request.set_min_players(2)
	request.set_search_mode(Request.SearchMode.MATCHMAKE_ONLY)
	request.set_required_tags({"Game": settings.queue_tag, "Rules": rules.revision})
	request.set_timeout(0.0) # Own fallback cancels and awaits SDK ACK.
	request.set_skill_rating(player.overall_points)
	if settings.restrict_rating_gap:
		if settings.allowed_rating_gap < 0 or settings.maximum_rating_gap < settings.allowed_rating_gap or settings.widening_points_per_second < 0:
			report_failure(token, "Rating policy is invalid.")
			return token
		request.set_skill_range(settings.allowed_rating_gap, settings.maximum_rating_gap, settings.widening_points_per_second)
	else:
		request.clear_skill_matching() # Creator: no rating restriction for this jam.
	print("Live search generation=%d completedMatches=%d botOnly=false delay=%.3fs rating=%d unrestricted=%s" % [token, completed_matches, fallback_wait_seconds, player.overall_points, not settings.restrict_rating_gap])
	sdk.matchmaking_start(request)
	_fallback_after(token)
	return token

func _process(_delta: float) -> void:
	if searching and not first_play and not closing and not sdk.lobby_get_name().is_empty():
		_try_pair()
		if pending_context != null and sdk.is_host() and Time.get_ticks_msec() >= offer_retry_msec:
			offer_retry_msec = Time.get_ticks_msec() + int(settings.handshake_retry_seconds * 1000.0)
			send_to(pending_context.opponent.peer_id, "offer", offer_payload, pending_context)
		if handshake_started_msec > 0 and Time.get_ticks_msec() - handshake_started_msec > settings.handshake_timeout_seconds * 1000.0:
			_fail_search("Peer setup timed out. Return and try again.")

func _fallback_after(token: int) -> void:
	await get_tree().create_timer(fallback_wait_seconds).timeout
	if not is_current(token) or pending_context != null or not pending_lobby.is_empty():
		return
	print("Live bot deadline firstPlay=%s elapsedMs=%d" % [first_play, Time.get_ticks_msec() - search_started_msec])
	# The generation becomes unusable before any asynchronous cancellation.
	searching = false
	generation += 1
	closing = true
	var cleared: bool = await _clear_service_search()
	closing = false
	if not cleared:
		local_player = null
		failed.emit(token, "Search cancellation was not confirmed. No fallback was started.")
		return
	var fallback_generation := generation
	var registration: Dictionary = await api.send("matches/register", HTTPClient.METHOD_POST, {"matchNonce": _nonce(), "fallbackRequested": true, "rulesRevision": deployment_revision})
	if generation != fallback_generation:
		return
	if registration.has("error"):
		local_player = null
		failed.emit(token, str(registration.error.message))
		return
	if local_player == null or reservation != null:
		return
	var bot := _participant(registration.opponentPublicProfile)
	bot.control_kind = "fallback_bot"
	if bot_personality == null or registration.get("botPersonalityId") != bot_personality.profile_id:
		failed.emit(token, "The assigned opponent policy is unavailable.")
		return
	intro_bot_match = registration.get("botBehavior", "standard") == "intro_loss"
	var context := _new_context(local_player, bot, token, registration.matchId)
	context.transport = "gdsync_fallback"
	reservation = context
	found.emit(context)

func cancel() -> void:
	if closing:
		return
	if not searching:
		var token := generation
		generation += 1
		local_player = null
		cancelled.emit(token)
		return
	var token := generation
	searching = false
	generation += 1
	closing = true
	pending_context = null
	var cleared: bool = await _clear_service_search()
	closing = false
	local_player = null
	if cleared:
		cancelled.emit(token)
	else:
		failed.emit(token, "GD-Sync cancellation is unconfirmed. Retry connection before searching.")

func _clear_service_search() -> bool:
	cancel_confirmed = not sdk.matchmaking_is_active()
	if sdk.matchmaking_is_active():
		sdk.matchmaking_cancel()
	var until := Time.get_ticks_msec() + int(settings.cancellation_timeout_seconds * 1000.0)
	while not cancel_confirmed and Time.get_ticks_msec() < until:
		await get_tree().process_frame
	if not cancel_confirmed:
		return false
	# 1.0.2 has no leave ACK signal. Its documented lobby_leave() clears
	# local membership synchronously; inspect that state before any reservation.
	# The relay can still hold membership when the local lobby name is empty
	# (observed ALREADY_IN_LOBBY after returning). Always send the leave request
	# after cancellation, rather than using the local cache to suppress it.
	sdk.lobby_leave()
	pending_lobby = ""
	return sdk.lobby_get_name().is_empty() and not sdk.matchmaking_is_active()

func _queue_cancelled() -> void:
	cancel_confirmed = true

func _queue_found(lobby: String) -> void:
	if first_play or not searching or closing:
		return
	pending_lobby = lobby
	print("M09 SDK queue found; awaiting lobby_joined")

func _queue_failed(error: int) -> void:
	if closing:
		cancel_confirmed = true # SDK failed() resets the same request.
	elif searching and not first_play:
		print("M09 SDK queue error=%d localLobbyEmpty=%s" % [error, sdk.lobby_get_name().is_empty()])
		_fail_search(_queue_error_message(error))

func _queue_error_message(error: int) -> String:
	if error == ENUMS.MATCHMAKING_ERROR.ALREADY_IN_LOBBY:
		return "Still in the previous lobby (1). Return to menu and retry Play. Reload if it repeats."
	if error == ENUMS.MATCHMAKING_ERROR.INVALID_REQUEST:
		return "Matchmaking settings were rejected (0). Return to menu."
	if error == ENUMS.MATCHMAKING_ERROR.NO_MATCH:
		return "No live match was available (2). Return to menu and retry Play."
	if error == ENUMS.MATCHMAKING_ERROR.TIMEOUT:
		return "The live search timed out (3). Return to menu and retry Play."
	if error == ENUMS.MATCHMAKING_ERROR.UNSUPPORTED_LOCAL:
		return "Live matchmaking needs an online GD-Sync connection (4)."
	if error == ENUMS.MATCHMAKING_ERROR.JOIN_FAILED:
		return "Couldn't join the live match (5). Return to menu and retry Play."
	return "Live matchmaking failed (%d). Return to menu and retry Play." % error

func _fail_search(detail: String) -> void:
	print("M09 search stopped: " + detail)
	var token := generation
	searching = false
	generation += 1
	pending_context = null
	closing = true
	await _clear_service_search()
	closing = false
	local_player = null
	failed.emit(token, detail)

func _joined(lobby: String) -> void:
	if first_play or closing or not searching or lobby != pending_lobby:
		sdk.lobby_leave()
		return
	handshake_started_msec = Time.get_ticks_msec()
	# Matchmaking may move to another relay and assign a new client ID.
	local_player.peer_id = sdk.get_client_id()
	sdk.player_set_data("m12Profile", Wire.participant(local_player))
	print("M09 lobby joined ownPeer=%d host=%d" % [sdk.get_client_id(), sdk.get_host()])
	_try_pair()

func _try_pair() -> void:
	if first_play or not sdk.is_host() or offer_sent or pending_lobby.is_empty():
		return
	var peers: Array = sdk.lobby_get_all_clients()
	var observation := str(peers)
	if observation != pairing_observation:
		pairing_observation = observation
		print("M09 pairing currentPeers=" + observation)
	if peers.size() != 2:
		return
	for peer in peers:
		if peer == sdk.get_client_id():
			continue
		var data: Dictionary = sdk.player_get_data(peer, "m12Profile", {})
		if data.is_empty():
			return
		if data.get("peerId", -1) != peer or data.get("actorId", "").is_empty():
			if profile_observation != str(data.get("peerId", -1)):
				profile_observation = str(data.get("peerId", -1))
				print("M09 awaiting current peer profile bound=%s actual=%s" % [data.get("peerId", -1), peer])
			return # Wait for the profile from this relay's current peer identity.
		if data.actorId == local_player.player_id:
			_fail_search("Independent accounts are required. Use a distinct browser profile.")
			return
		offer_sent = true
		var token := generation
		registration_body = {"matchNonce": _nonce(), "lobbyId": pending_lobby, "peerPlayerId": data.actorId, "fallbackRequested": false, "rulesRevision": deployment_revision}
		var registration: Dictionary = await api.send("matches/register", HTTPClient.METHOD_POST, registration_body)
		if not is_current(token):
			return
		if registration.has("error"):
			_fail_search(str(registration.error.message))
			return
		pending_context = _new_context(local_player, Wire.read_participant(data), generation, registration.matchId)
		pending_context.match_nonce = registration_body.matchNonce
		sdk.lobby_close()
		offer_payload = {"deploymentRevision": deployment_revision, "matchNonce": pending_context.match_nonce, "lobbyName": pending_lobby, "actors": [Wire.participant(local_player), data], "history": pending_context.round_log.debug_snapshot()}
		offer_retry_msec = 0

func _new_context(first: MatchParticipant, second: MatchParticipant, token: int, server_match_id: String) -> MatchContext:
	var context := MatchContext.new()
	context.match_id = server_match_id
	context.deployment_revision = deployment_revision
	context.development_only = false
	context.persistent_credit_allowed = true
	context.search_generation = token
	context.local_player = first
	context.opponent = second
	context.transport = "gdsync_peer"
	context.session = self
	context.canonical_actor_ids.assign([first.player_id, second.player_id])
	var history := RoundLog.new()
	history.match_id = context.match_id
	history.rules_revision = rules.revision
	history.arena_condition = _condition()
	for participant in [first, second]:
		var actor := InitialChoiceHistory.new()
		actor.actor_id = participant.player_id
		actor.starting_order.assign(["Rock", "Paper", "Scissor"])
		actor.starting_order.shuffle()
		history.initial_choices.append(actor)
	context.round_log = history
	return context

func authority() -> bool:
	if reservation != null and reservation.transport == "gdsync_fallback":
		return true
	return sdk != null and sdk.is_host()

func has_human_peer() -> bool:
	return reservation != null and reservation.opponent.control_kind == "human_peer" and not reservation.opponent.departed_before_commit

func send_to(peer: int, kind: String, payload: Dictionary, context: MatchContext = null, phase_name: String = "session", actor: String = "", revision: int = 0) -> void:
	if context == null:
		context = reservation
	if context == null or peer < 0:
		return
	wire_sequence += 1
	var envelope := {"matchId": context.match_id, "phase": phase_name, "actorId": actor, "sequence": wire_sequence, "revision": revision, "payload": payload}
	sent_messages += 1
	sent_bytes += var_to_bytes(envelope).size()
	sdk.call_func_on(peer, _receive, kind, envelope)

func send_peer(kind: String, payload: Dictionary, phase_name: String = "session", actor: String = "", revision: int = 0) -> void:
	if has_human_peer():
		send_to(reservation.opponent.peer_id, kind, payload, reservation, phase_name, actor, revision)

func _receive(kind: String, envelope: Dictionary) -> void:
	var sender: int = sdk.get_sender_id()
	if kind in ["offer", "offer_ack", "reserved"]:
		print("M09 handshake packet=%s sender=%d" % [kind, sender])
	if sender < 0 or closing or not sdk.lobby_get_all_clients().has(sender):
		if kind == "offer":
			_note_offer("membership sender=%d peers=%s closing=%s" % [sender, str(sdk.lobby_get_all_clients()), closing])
		return
	if kind == "offer":
		_receive_offer(envelope, sender)
		return
	var context := reservation
	if context == null:
		context = pending_context
	if context == null or envelope.get("matchId", "") != context.match_id or sender != context.opponent.peer_id:
		return
	if int(envelope.get("sequence", 0)) <= int(received_sequences.get(sender, 0)):
		return
	received_sequences[sender] = envelope.sequence
	received_messages += 1
	received_bytes += var_to_bytes(envelope).size()
	if kind == "offer_ack" and searching and pending_context != null and sdk.is_host() and not binding_confirming:
		binding_confirming = true
		var token := generation
		var registration: Dictionary = await api.send("matches/register", HTTPClient.METHOD_POST, registration_body)
		binding_confirming = false
		if not is_current(token) or pending_context == null:
			return
		if registration.has("error") or registration.get("status") != "ready":
			_fail_search("Participant binding could not be confirmed. Return and retry.")
			return
		_apply_public_profile(pending_context.opponent, registration.opponentPublicProfile)
		send_to(sender, "reserved", {}, pending_context)
		commit_found(generation, pending_context)
		pending_context = null
	elif kind == "reserved" and searching and pending_context != null and sender == sdk.get_host():
		commit_found(generation, pending_context)
		pending_context = null
		print("M09 human reserved client peer=%d match=%s" % [sender, reservation.match_id])
	elif reservation != null:
		packet_received.emit(kind, envelope, sender)

func _receive_offer(envelope: Dictionary, sender: int) -> void:
	if first_play or not searching or sdk.get_host() != sender or pending_lobby.is_empty():
		_note_offer("authority sender=%d host=%d searching=%s lobbyEmpty=%s" % [sender, sdk.get_host(), searching, pending_lobby.is_empty()])
		return
	var data: Dictionary = envelope.get("payload", {})
	if data.get("deploymentRevision", "") != deployment_revision:
		_note_offer("configuration revision mismatch")
		return
	if data.get("lobbyName", "") != pending_lobby or pending_lobby != sdk.lobby_get_name():
		_note_offer("lobby binding mismatch")
		return
	if pending_context != null:
		if pending_context.match_id == envelope.get("matchId", "") and pending_context.opponent.peer_id == sender and pending_context.opponent.backend_verified:
			send_to(sender, "offer_ack", {}, pending_context)
		return
	var actors: Array = data.get("actors", [])
	if actors.size() != 2 or actors[0].peerId != sender or actors[1].peerId != sdk.get_client_id() or actors[1].actorId != local_player.player_id or data.history.rulesRevision != rules.revision:
		_note_offer("participant/rule binding mismatch")
		return
	var context := MatchContext.new()
	context.match_id = envelope.matchId
	context.deployment_revision = deployment_revision
	context.development_only = false
	context.persistent_credit_allowed = true
	context.match_nonce = data.get("matchNonce", "")
	context.search_generation = generation
	context.local_player = local_player
	context.opponent = Wire.read_participant(actors[0])
	context.opponent.backend_verified = false
	context.session = self
	context.transport = "gdsync_peer"
	context.canonical_actor_ids.assign([actors[0].actorId, actors[1].actorId])
	context.round_log = Wire.read_history(data.history)
	pending_context = context
	var token := generation
	var registration: Dictionary = await api.send("matches/join", HTTPClient.METHOD_POST, {"matchId": context.match_id, "matchNonce": context.match_nonce})
	if not is_current(token) or pending_context != context:
		return
	if registration.has("error") or registration.get("status") != "ready":
		_fail_search("Could not join the registered match. Return and retry.")
		return
	_apply_public_profile(context.opponent, registration.opponentPublicProfile)
	received_sequences[sender] = envelope.sequence
	send_to(sender, "offer_ack", {}, context)

func _client_left(peer: int) -> void:
	if reservation == null:
		if searching and not pending_lobby.is_empty():
			_fail_search("Peer left before the match was ready. Please search again.")
		return
	if peer == reservation.opponent.peer_id:
		peer_departed.emit(peer)

func _host_changed(_is_host: bool, _new_host: int) -> void:
	authority_changed.emit()

func _disconnected() -> void:
	# This client departed. It must not continue, credit itself, or resume.
	if reservation != null and coordinator != null:
		coordinator.transport_lost()
	elif searching:
		report_failure(generation, "GD-Sync disconnected. Return and retry.")

func release_match(match_id: String) -> void:
	if reservation == null or reservation.match_id != match_id:
		return
	print("M09 traffic app-envelope-only sent=%d/%dB received=%d/%dB (excludes SDK/relay overhead)" % [sent_messages, sent_bytes, received_messages, received_bytes])
	coordinator = null
	if sdk.get_client_id() >= 0:
		# Send the service leave even if local membership was already cleared.
		sdk.lobby_leave()
	super.release_match(match_id)
	_reset_wire()

func _reset_wire() -> void:
	pending_lobby = ""
	pending_context = null
	offer_sent = false
	offer_observation = ""
	offer_payload = {}
	offer_retry_msec = 0
	handshake_started_msec = 0
	pairing_observation = ""
	profile_observation = ""
	wire_sequence = 0
	received_sequences.clear()
	sent_bytes = 0
	received_bytes = 0
	sent_messages = 0
	received_messages = 0

func _nonce() -> String:
	return preload("res://scripts/api/http_api.gd").uuid()

func _participant(data: Dictionary) -> MatchParticipant:
	var player := MatchParticipant.new()
	player.player_id = data.playerId
	player.display_name = data.displayName
	player.overall_points = data.overallPoints
	player.public_profile = data.duplicate(true)
	player.switch_percentage = data.switchPercentage
	player.backend_verified = true
	player.rating_source = "backend"
	return player

func _condition() -> int:
	var total := rules.devil_weight + rules.angel_weight + rules.no_modifier_weight
	var draw := randf() * total
	if draw < rules.devil_weight:
		return 0
	if draw < rules.devil_weight + rules.angel_weight:
		return 1
	return 2

func _apply_public_profile(player: MatchParticipant, data: Dictionary) -> void:
	player.display_name = data.displayName
	player.overall_points = data.overallPoints
	player.public_profile = data.duplicate(true)
	player.switch_percentage = data.switchPercentage
	player.backend_verified = true
	player.rating_source = "backend"

func _note_offer(reason: String) -> void:
	if reason != offer_observation:
		offer_observation = reason
		print("M12 offer waiting: " + reason)
