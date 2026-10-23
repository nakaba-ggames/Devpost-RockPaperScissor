extends "res://scripts/chat/match_chat_session.gd"
## Ephemeral plain text through the match host; bots never reply.
var transport: Node
var context: MatchContext
var allowed: bool = true
var sender_sequences: Dictionary = {}

func begin(value: MatchContext) -> void:
	super.begin(value)
	context = value
	transport = value.session
	allowed = true
	sender_sequences.clear()
	if not transport.packet_received.is_connected(_packet):
		transport.packet_received.connect(_packet)

func send_text(text: String) -> bool:
	var plain := text.strip_edges()
	if not allowed or match_id.is_empty() or plain.is_empty() or transport.coordinator == null or transport.coordinator.disconnected:
		return false
	sequence += 1
	var message := {"matchId": match_id, "actorId": local_actor_id, "sequence": sequence, "text": plain, "delivery": "peer_transport"}
	if transport.authority():
		_deliver(message)
		transport.send_peer("chat_accepted", message, transport.coordinator.phase, local_actor_id, sequence)
	else:
		transport.send_peer("chat_request", message, transport.coordinator.phase, local_actor_id, sequence)
	return true

func _packet(kind: String, envelope: Dictionary, sender: int) -> void:
	if not allowed or context == null or transport.coordinator == null or transport.coordinator.disconnected:
		return
	var message: Dictionary = envelope.payload
	if not kind in ["chat_request", "chat_accepted"] or envelope.phase != transport.coordinator.phase:
		return
	if message.get("matchId") != match_id or message.get("actorId") != envelope.actorId or int(message.get("sequence", 0)) != envelope.revision:
		return
	if kind == "chat_request" and transport.authority() and sender == context.opponent.peer_id and envelope.actorId == context.opponent.player_id and transport.has_human_peer():
		if _deliver(message):
			transport.send_peer("chat_accepted", message, envelope.phase, envelope.actorId, envelope.revision)
	elif kind == "chat_accepted" and sender == transport.sdk.get_host():
		if envelope.actorId in [local_actor_id, context.opponent.player_id]:
			_deliver(message)

func _deliver(message: Dictionary) -> bool:
	var actor: String = message.actorId
	if int(message.sequence) <= int(sender_sequences.get(actor, 0)):
		return false
	if str(message.get("text", "")).strip_edges().is_empty():
		return false
	sender_sequences[actor] = message.sequence
	return receive_message(message)

func dispose() -> void:
	if transport != null and transport.packet_received.is_connected(_packet):
		transport.packet_received.disconnect(_packet)
	context = null
	allowed = false
	sender_sequences.clear()
	super.dispose()
