extends Resource
@export var backend_api_origin: String = "https://devpost-rockpaperscissor-backend.vercel.app"
@export var request_timeout_seconds: float = 20.0
@export var result_poll_seconds: float = 2.0
@export_range(1, 256) var history_events_per_chunk: int = 128
