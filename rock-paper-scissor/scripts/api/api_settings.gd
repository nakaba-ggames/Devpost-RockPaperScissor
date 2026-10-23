extends Resource
@export var native_api_origin: String = "http://127.0.0.1:3101"
@export var request_timeout_seconds: float = 20.0
@export var result_poll_seconds: float = 2.0
@export_range(1, 256) var history_events_per_chunk: int = 128
