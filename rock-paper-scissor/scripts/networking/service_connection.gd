extends Node
## Connection evidence comes exclusively from real SDK lifecycle signals.
## No lobbies, matchmaking, GD-Sync accounts or cloud saves in M01.

signal status_changed(text: String)
var status_text: String = "GD-Sync • connecting…"
var connected_signal_count: int = 0
var connection_ready: bool = false
var sdk: Node

func _ready() -> void:
	sdk = get_node_or_null("/root/GDSync")
	if sdk == null:
		_set_status("GD-Sync • SDK unavailable")
		return
	sdk.connected.connect(_on_connected)
	sdk.connection_failed.connect(_on_connection_failed)
	sdk.disconnected.connect(_on_disconnected)

func start() -> void:
	if sdk == null:
		return
	sdk.start_multiplayer()

func _on_connected() -> void:
	connection_ready = true
	connected_signal_count += 1
	_set_status("GD-Sync • connected")
	print("M01 GD-Sync: actual SDK connected signal received")

func _on_connection_failed(error: int) -> void:
	connection_ready = false
	if error == 0:
		_set_status("GD-Sync • connection failed (configuration)")
	else:
		_set_status("GD-Sync • connection failed (%d)" % error)
	print("M01 GD-Sync: actual SDK connection_failed signal (%d)" % error)

func _on_disconnected() -> void:
	connection_ready = false
	_set_status("GD-Sync • disconnected")
	print("M01 GD-Sync: actual SDK disconnected signal received")

func retry() -> void:
	# Retry only on an explicit user action; never simulate a connected state.
	connection_ready = false
	_set_status("GD-Sync • connecting…")
	start()

func _set_status(value: String) -> void:
	status_text = value
	status_changed.emit(value)
