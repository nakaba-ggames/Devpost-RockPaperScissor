class_name MatchChatSession
extends Node
## Replaceable match-only send/receive seam. Never included in RoundLog.
signal message_received(message: Dictionary)
var match_id: String = ""
var local_actor_id: String = ""
var messages: Array[Dictionary] = []
var sequence: int = 0

func begin(context: MatchContext) -> void:
	dispose()
	match_id = context.match_id
	local_actor_id = context.local_player.player_id

func send_text(_text: String) -> bool:
	# Transport providers implement this; success must describe actual delivery.
	return false

func receive_message(message: Dictionary) -> bool:
	if match_id.is_empty() or message.get("matchId", "") != match_id:
		return false
	messages.append(message.duplicate(true))
	message_received.emit(messages.back())
	return true

func dispose() -> void:
	messages.clear()
	sequence = 0
	match_id = ""
	local_actor_id = ""
