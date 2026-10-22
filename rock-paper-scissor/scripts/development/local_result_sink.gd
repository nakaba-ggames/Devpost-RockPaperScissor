extends "res://scripts/results/result_sink.gd"
## Explicit simulation only. Never writes a profile, service, file or match record.
var receipts: Dictionary = {}

func submit(submission: Dictionary) -> void:
	var result_id: String = submission.resultId
	if not receipts.has(result_id):
		receipts[result_id] = {"resultId": result_id, "matchId": submission.matchId, "rulesRevision": submission.rulesRevision, "receiptId": "simulated:" + result_id, "simulated": true, "serverAcknowledged": false, "persisted": false, "persistentCreditAllowed": false}
	acknowledged.emit(result_id, receipts[result_id].duplicate(true))
