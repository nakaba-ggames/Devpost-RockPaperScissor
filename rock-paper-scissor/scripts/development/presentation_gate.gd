extends "res://scripts/results/receipt_gate.gd"
const PreviewReceipt = preload("res://scripts/development/presentation_receipt.gd")
## Development-only gate. The production gate still requires durable commitment.
func _query() -> bool:
	if context == null or sink == null:
		return false
	var receipt: Dictionary = sink.receipt_for(context.result_id)
	if receipt.is_empty():
		receipt = observed_receipts.get(context.result_id, {})
	if not PreviewReceipt.matches(context.result_submission, receipt):
		return false
	_acknowledged(context.result_id, receipt)
	return state == "accepted"

func _acknowledged(result_id: String, receipt: Dictionary) -> void:
	observed_receipts[result_id] = receipt.duplicate(true)
	if context == null or state == "accepted" or result_id != context.result_id:
		return
	if not PreviewReceipt.matches(context.result_submission, receipt):
		return
	context.result_receipt = receipt.duplicate(true)
	state = "accepted"
	accepted.emit(context.result_submission, receipt.duplicate(true))

