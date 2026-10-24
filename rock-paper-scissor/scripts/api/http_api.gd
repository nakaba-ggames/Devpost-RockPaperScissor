extends Node
## One owned asynchronous queue. Credentials never enter transport/profile data.
class Ticket extends RefCounted:
	signal completed(response: Dictionary)
	var done: bool = false
	func finish(response: Dictionary) -> void:
		if not done:
			done = true
			completed.emit(response)

@export var settings: Resource
var credential: String = ""
var pending: Array[Dictionary] = []
var active: Dictionary = {}
var request_node: HTTPRequest
var timing_enabled: bool = OS.get_cmdline_user_args().has("--network-timing")

func _ready() -> void:
	if OS.has_feature("web"):
		timing_enabled = bool(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('network_timing') === '1'", true))

static func failure(code: String, message: String, retryable: bool = true) -> Dictionary:
	return {"error": {"code": code, "message": message, "retryable": retryable}}

static func uuid() -> String:
	var hex := Crypto.new().generate_random_bytes(16).hex_encode()
	return "%s-%s-%s-%s-%s" % [hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4), hex.substr(16, 4), hex.substr(20, 12)]

func send(path: String, method: int = HTTPClient.METHOD_GET, body: Dictionary = {}, private: bool = true) -> Dictionary:
	if private and credential.is_empty():
		return failure("CREDENTIAL_MISSING", "An anonymous account is required.", false)
	var ticket := Ticket.new()
	pending.append({"ticket": ticket, "path": path, "method": method, "body": body.duplicate(true), "private": private, "queued_msec": Time.get_ticks_msec()})
	_dispatch.call_deferred()
	return await ticket.completed

func _dispatch() -> void:
	if not active.is_empty() or pending.is_empty():
		return
	active = pending.pop_front()
	active.started_msec = Time.get_ticks_msec()
	request_node = HTTPRequest.new()
	request_node.use_threads = false
	request_node.timeout = settings.request_timeout_seconds
	add_child(request_node)
	request_node.request_completed.connect(_completed)
	var origin: String = settings.backend_api_origin.trim_suffix("/")
	var headers := PackedStringArray(["Content-Type: application/json", "Accept: application/json"])
	if active.private:
		headers.append("Authorization: Bearer " + credential)
	var encoded := ""
	if active.method != HTTPClient.METHOD_GET:
		encoded = JSON.stringify(active.body)
	var error := request_node.request(origin + "/api/" + active.path, headers, active.method, encoded)
	if error != OK:
		_finish(failure("REQUEST_UNAVAILABLE", "Saved data is unavailable. Wait and retry."))

func _completed(result: int, status: int, headers: PackedStringArray, bytes: PackedByteArray) -> void:
	if timing_enabled:
		var server_timing := "unavailable"
		for header in headers:
			if header.to_lower().begins_with("server-timing:"):
				server_timing = header.substr(14).strip_edges()
		print("NetworkTiming route=%s method=%d queue_ms=%d request_ms=%d status=%d server=%s" % [active.path.split("?")[0], active.method, active.started_msec - active.queued_msec, Time.get_ticks_msec() - int(active.started_msec), status, server_timing])
	if result != HTTPRequest.RESULT_SUCCESS:
		_finish(failure("CONNECTION_UNCERTAIN", "The request could not be confirmed. Wait and retry."))
		return
	var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
	if not parsed is Dictionary:
		_finish(failure("INVALID_RESPONSE", "The server response could not be read. Wait and retry."))
		return
	if status < 200 or status >= 300:
		var error: Dictionary = parsed.get("error", {})
		if error.is_empty():
			_finish(failure("SERVER_UNAVAILABLE", "Saved data is unavailable. Wait and retry."))
		else:
			_finish(failure(str(error.get("code", "SERVER_UNAVAILABLE")), str(error.get("message", "Saved data is unavailable.")), bool(error.get("retryable", status >= 500))))
		return
	_finish(parsed)

func _finish(response: Dictionary) -> void:
	var ticket: Ticket = active.ticket
	active = {}
	if request_node != null:
		request_node.queue_free()
		request_node = null
	ticket.finish(response)
	_dispatch.call_deferred()

func cancel_all() -> void:
	var cancelled := failure("CANCELLED", "Request cancelled.", false)
	if request_node != null:
		request_node.cancel_request()
		request_node.queue_free()
		request_node = null
	var tickets: Array = pending.duplicate()
	pending.clear()
	if not active.is_empty():
		tickets.append(active)
	active = {}
	for row in tickets:
		row.ticket.finish(cancelled)
