extends CanvasLayer
## Live connection recovery only; no match, timer or persistence authority.
@export var tuning: Resource
var ui_theme: Theme
var panel: Control
var message: Label
var column: VBoxContainer
var retry_button: Button
var recovery_active: bool = false
var previous_focus: Control

func _ready() -> void:
	layer = tuning.connection_overlay_layer
	panel = Control.new()
	panel.name = "ConnectionBlocker"
	panel.theme = ui_theme
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dimmer := ColorRect.new()
	dimmer.color = tuning.connection_overlay_color
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(dimmer)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column = VBoxContainer.new()
	column.custom_minimum_size.x = tuning.connection_content_width
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", tuning.connection_content_gap)
	center.add_child(column)
	message = Label.new()
	message.text = tuning.disconnected_copy
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message.add_theme_font_override("font", preload("res://Fonts/BoldPixels.ttf"))
	message.add_theme_font_size_override("font_size", tuning.connection_message_font_size)
	column.add_child(message)
	hide()
	set_process_input(false)

func install_retry(button: Button) -> void:
	retry_button = button
	button.reparent(column)
	button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	button.custom_minimum_size = tuning.retry_button_size
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.z_index = 0
	button.scale = Vector2.ONE
	button.text = tuning.retry_connection_copy
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_ALL
	button.show()

func connection_state(ready: bool, failed: bool) -> void:
	if ready:
		recovery_active = false
		hide()
		set_process_input(false)
		if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree() and not previous_focus.is_queued_for_deletion():
			previous_focus.grab_focus()
		previous_focus = null
		return
	if not failed and not recovery_active:
		return # Ordinary initial connection keeps the title's existing presentation.
	if not recovery_active:
		previous_focus = get_viewport().gui_get_focus_owner()
	recovery_active = true
	show()
	set_process_input(true)
	message.text = tuning.disconnected_copy if failed else tuning.reconnecting_copy
	retry_button.disabled = not failed
	retry_button.show()
	retry_button.grab_focus()

func _input(event: InputEvent) -> void:
	if not recovery_active:
		return
	# Consume raw input before the arena/reveal _input handlers, not only GUI clicks.
	var retry_pressed := false
	if not retry_button.disabled:
		if event is InputEventScreenTouch:
			retry_pressed = event.pressed and retry_button.get_global_rect().has_point(event.position)
		elif event is InputEventMouseButton:
			retry_pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT and retry_button.get_global_rect().has_point(event.position)
		elif event is InputEventKey:
			retry_pressed = not event.echo and event.is_action_pressed("ui_accept")
		elif event is InputEventAction or event is InputEventJoypadButton:
			retry_pressed = event.is_action_pressed("ui_accept")
	get_viewport().set_input_as_handled()
	if retry_pressed:
		retry_button.pressed.emit()
