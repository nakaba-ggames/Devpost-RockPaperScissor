extends MatchChatSession
## Local echo only: no peer send, backend writes, archive or generated replies.
func send_text(text: String) -> bool:
	var plain := text.strip_edges()
	if match_id.is_empty() or plain.is_empty():
		return false
	sequence += 1
	return receive_message({"matchId": match_id, "actorId": local_actor_id, "sequence": sequence, "text": plain, "delivery": "local_preview"})
