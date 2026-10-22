class_name ProfileProvider
extends Node
## Small asynchronous seam for the M10/M12 API provider.
## No credentials are sent to GD-Sync and no account API exists in M01.

signal identity_ready(profile: PreviewProfile)
signal menu_ready(profile: PreviewProfile)
signal request_failed(kind: String, detail: String)
signal local_data_cleared

func begin_session() -> void:
	pass

func save_display_name(_display_name: String) -> void:
	pass

func enter_menu() -> void:
	pass

func clear_local_data() -> void:
	pass
