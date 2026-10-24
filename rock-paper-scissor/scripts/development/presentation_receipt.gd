extends RefCounted
## Only the offline presentation scene uses this contract. No real commitment.
static func matches(submission: Dictionary, receipt: Dictionary) -> bool:
	if not submission.get("developmentOnly", false) or submission.get("persistentCreditAllowed", true):
		return false
	if not receipt.get("simulated", false) or receipt.get("persisted", true) or receipt.get("serverAcknowledged", true) or receipt.get("persistentCreditAllowed", true):
		return false
	return str(receipt.get("receiptId", "")).begins_with("simulated:") and receipt.get("resultId") == submission.get("resultId") and receipt.get("matchId") == submission.get("matchId") and receipt.get("rulesRevision") == submission.get("rulesRevision")

