extends "res://scripts/results/result_sink.gd"
## One canonical preview receipt, replicated by the host before presentation.
var coordinator: Node
var receipts: Dictionary = {}

func bind_session(_session: Node, controller: Node) -> void:
	coordinator = controller
	receipts.clear()

func submit(submission: Dictionary) -> void:
	coordinator.propose_result(submission)

func install_receipt(result_id: String, receipt: Dictionary) -> void:
	receipts[result_id] = receipt.duplicate(true)
	acknowledged.emit(result_id, receipt.duplicate(true))

func receipt_for(result_id: String) -> Dictionary:
	return receipts.get(result_id, {}).duplicate(true)
