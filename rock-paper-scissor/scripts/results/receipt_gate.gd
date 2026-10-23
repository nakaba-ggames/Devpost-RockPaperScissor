extends Node
## Delivery only: never recalculates history, eligibility or awards.
signal accepted(submission: Dictionary, receipt: Dictionary)
signal state_changed(state: String, detail: String, retryable: bool)
@export var sink: Node
@export var tuning: Resource
var context: MatchContext
var state: String = "idle"
var elapsed: float = 0.0
var retry_elapsed: float = 0.0
var errors: Dictionary = {}
var can_retry: bool = false
var observed_receipts: Dictionary = {}

func _ready() -> void:
	if sink != null:
		sink.acknowledged.connect(_acknowledged)
		sink.failed.connect(_failed)

func begin(value: MatchContext) -> void:
	context = value
	state = "pending"
	can_retry = false
	elapsed = 0.0
	retry_elapsed = tuning.retry_seconds
	state_changed.emit(state, tuning.pending_copy, false)
	# The local sink normally acknowledged during final lock, before begin().
	if _query():
		return
	if sink == null:
		_set_error("Result provider unavailable.", false)
	elif errors.has(context.result_id):
		var error: Dictionary = errors[context.result_id]
		_set_error(error.detail, error.retryable)

func _process(delta: float) -> void:
	retry_elapsed += delta
	if state == "pending":
		elapsed += delta
		if elapsed >= tuning.receipt_timeout_seconds:
			_set_error(tuning.uncertain_copy, true)

func _query() -> bool:
	if sink == null or context == null:
		return false
	var receipt: Dictionary = sink.receipt_for(context.result_id)
	if receipt.is_empty():
		receipt = observed_receipts.get(context.result_id, {})
	if matches(context.result_submission, receipt):
		_acknowledged(context.result_id, receipt)
		return true
	return false

static func matches(submission: Dictionary, receipt: Dictionary) -> bool:
	if submission.is_empty():
		return false
	if not receipt.get("persisted", false) or not receipt.get("serverAcknowledged", false) or receipt.get("simulated", true) or receipt.get("historyDigest") != submission.get("historyDigest") or str(receipt.get("committedAt", "")).is_empty():
		return false
	return not submission.is_empty() and not str(receipt.get("receiptId", "")).is_empty() and receipt.get("resultId") == submission.get("resultId") and receipt.get("matchId") == submission.get("matchId") and receipt.get("rulesRevision") == submission.get("rulesRevision")

func retry() -> void:
	if state != "error" or not can_retry or context == null or sink == null or retry_elapsed < tuning.retry_seconds:
		return
	if _query():
		return
	state = "pending"
	can_retry = false
	elapsed = 0.0
	retry_elapsed = 0.0
	state_changed.emit(state, tuning.pending_copy, false)
	# Same frozen envelope and result ID, including after an uncertain response.
	sink.retry(context.result_submission)

func _acknowledged(result_id: String, receipt: Dictionary) -> void:
	# This listener exists before final lock; retain early sink acknowledgements.
	observed_receipts[result_id] = receipt.duplicate(true)
	if context == null or state == "accepted" or result_id != context.result_id:
		return
	if not matches(context.result_submission, receipt):
		return
	context.result_receipt = receipt.duplicate(true)
	state = "accepted"
	accepted.emit(context.result_submission, receipt.duplicate(true))

func _failed(result_id: String, detail: String, retryable: bool) -> void:
	errors[result_id] = {"detail": detail, "retryable": retryable}
	if context != null and result_id == context.result_id and state != "accepted":
		_set_error(detail, retryable)

func _set_error(detail: String, retryable: bool) -> void:
	state = "error"
	can_retry = retryable
	state_changed.emit(state, detail, retryable)

func dispose() -> void:
	context = null
	state = "idle"
	errors.clear()
	observed_receipts.clear()
