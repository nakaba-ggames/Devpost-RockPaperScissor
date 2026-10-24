extends Node
## Live-only account, naming and multiplayer gate. Never instanced by preview.
@onready var provider: ProfileProvider = $ProfileProvider
@onready var service: Node = $ServiceConnection
var ui: GameUI
var profile: PlayerProfile
var opening_ready: bool = false
var naming: bool = false
var menu_pending: bool = false
var entry_error: String = ""

func start(view: GameUI) -> void:
	ui = view
	ui.continue_requested.connect(_continue)
	ui.name_requested.connect(provider.save_display_name)
	ui.retry_entry_requested.connect(_restart)
	ui.recreate_requested.connect(provider.clear_local_data)
	ui.retry_connection_requested.connect(service.retry)
	provider.identity_ready.connect(_identity_ready)
	provider.menu_ready.connect(_menu_ready)
	provider.request_failed.connect(_failed)
	provider.local_data_cleared.connect(_cleared)
	service.status_changed.connect(_connection_changed)
	$OpeningSequence.finished.connect(_opening_finished)
	ui.connection_status(service.status_text)
	_restart()
	service.start()

func stop() -> void:
	if service.sdk != null:
		service.sdk.stop_multiplayer()

func _restart() -> void:
	profile = null
	naming = false
	menu_pending = false
	entry_error = ""
	ui.get_node("%RetryEntry").hide()
	ui.get_node("%NewPreview").hide()
	ui.menu.hide()
	ui.entry.show()
	ui.entry.modulate.a = 1.0
	ui.show_pending("Connecting to server…")
	provider.begin_session()

func _identity_ready(value: PlayerProfile) -> void:
	profile = value
	entry_error = ""
	ui.get_node("%RetryEntry").hide()
	ui.get_node("%NewPreview").hide()
	if naming and not profile.display_name.is_empty():
		naming = false
		_enter_menu()
	else:
		_refresh()

func _opening_finished() -> void:
	opening_ready = true
	ui._fade_in(ui.get_node("Margin/Stack/Brand"))
	ui._fade_in(ui.get_node("Margin/Stack/Subtitle"))
	_refresh()

func _refresh() -> void:
	if not ui.entry.visible or ui.changing_screen:
		return
	if not entry_error.is_empty():
		ui.show_pending(entry_error)
	elif not opening_ready:
		ui.show_pending("")
	elif profile == null:
		ui.show_pending("Connecting to server…")
	elif not service.connection_ready:
		var text := "Connecting to multiplayer server…"
		if service.status_text.contains("failed") or service.status_text.contains("disconnected") or service.status_text.contains("unavailable"):
			text = service.status_text
		ui.show_pending(text)
	elif menu_pending:
		ui.show_pending("Opening menu…")
	elif naming:
		ui.show_name_prompt()
	else:
		ui.show_continue(profile.display_name)

func _continue() -> void:
	if not ui.can_continue or ui.changing_screen:
		return
	if profile.display_name.is_empty():
		naming = true
		ui.show_name_prompt()
	else:
		_enter_menu()

func _enter_menu() -> void:
	if menu_pending:
		return
	if profile == null or not service.connection_ready:
		_refresh()
		return
	menu_pending = true
	ui.show_pending("Opening menu…")
	ui.get_node("%Play").disabled = true
	provider.enter_menu()

func _menu_ready(_profile: PlayerProfile) -> void:
	menu_pending = false

func _failed(kind: String, detail: String) -> void:
	menu_pending = false
	ui._show_feedback(detail)
	if kind in ["account", "server"]:
		entry_error = detail
		ui.show_pending(detail)
		if kind == "account":
			ui.get_node("%NewPreview").show()
		else:
			ui.get_node("%RetryEntry").show()

func _cleared() -> void:
	ui.reset_data_views()
	_restart()
	ui._show_feedback("Local account data cleared. The previous backend account remains; creating a new account.")

func _connection_changed(text: String) -> void:
	ui.connection_status(text)
	_refresh()

