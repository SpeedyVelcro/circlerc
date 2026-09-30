extends PanelContainer

@export var window_settings_ui: Control
@export var fullscreen_toggle_container: Control
@export var tab_container: TabContainer

signal back


# Override
func _ready() -> void:
	window_settings_ui.visible = not OS.has_feature("web")
	fullscreen_toggle_container.visible = OS.has_feature("web")


# Signal connection
func _on_back_button_pressed() -> void:
	OptionsSaver.save()
	back.emit()


# Signal connection
func _on_fullscreen_toggle_button_pressed() -> void:
	var window_mode := DisplayServer.window_get_mode()
	match window_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


# Signal connection
func _on_visibility_changed() -> void:
	if visible:
		tab_container.current_tab = 0
