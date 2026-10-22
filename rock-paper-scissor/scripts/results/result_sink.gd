class_name ResultSink
extends Node
## M06 consumes these signals; a real provider must establish server commitment.
signal acknowledged(result_id: String, receipt: Dictionary)
signal failed(result_id: String, detail: String, retryable: bool)

func submit(submission: Dictionary) -> void:
	failed.emit(str(submission.get("resultId", "")), "Result provider is not configured.", false)

func receipt_for(_result_id: String) -> Dictionary:
	return {}

func retry(submission: Dictionary) -> void:
	# A live provider can query uncertain commitment before retrying this identity.
	submit(submission)
