class_name MatchSession
extends Node
## Game-facing lifecycle. M09 replaces the adapter, preserving this boundary.
signal began(generation: int)
signal cancelled(generation: int)
signal found(context: MatchContext)
signal failed(generation: int, detail: String)

var generation: int = 0
var searching: bool = false
var reservation: MatchContext
var local_player: MatchParticipant

func begin(player: MatchParticipant) -> int:
	if searching or reservation != null:
		return 0
	generation += 1
	local_player = player
	searching = true
	began.emit(generation)
	return generation

func cancel() -> void:
	if not searching:
		return
	var cancelled_generation := generation
	# Invalidate callbacks before notifying consumers or beginning any motion.
	generation += 1
	searching = false
	local_player = null
	cancelled.emit(cancelled_generation)

func is_current(token: int) -> bool:
	return searching and token == generation and reservation == null

func commit_found(token: int, context: MatchContext) -> void:
	if not is_current(token):
		return
	if context == null or context.search_generation != token:
		return
	# Reserve synchronously, before emitting. A second outcome cannot commit.
	reservation = context
	searching = false
	found.emit(reservation)

func report_failure(token: int, detail: String) -> void:
	if not is_current(token):
		return
	searching = false
	local_player = null
	generation += 1
	failed.emit(token, detail)

func release_match(match_id: String) -> void:
	# Only the owner of the committed context can release the destination.
	if reservation == null or reservation.match_id != match_id:
		return
	reservation = null
	local_player = null
	generation += 1
