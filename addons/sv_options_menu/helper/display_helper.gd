class_name OptionsDisplayHelper
extends Object
## Service for SV Options Menu management of display settings.
##
## Provides methods for changing resolution, fullscreen status etc.


## Applies the resolution and window mode according to configuration in [OptionsConfig]. Discards
## resolution and/or window mode respectively if they aren't managed by SV Options Menu.
static func apply_window_settings(window_mode: DisplayServer.WindowMode, resolution: Vector2i, options_config: OptionsConfig) -> void:
	if options_config.manage_window_mode:
		_apply_window_mode(window_mode)
	
	if not options_config.manage_resolution:
		return
	
	var actual_window_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	
	var affects_window_size := false
	var affects_content_size := false
	
	match actual_window_mode:
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED, DisplayServer.WindowMode.WINDOW_MODE_MINIMIZED, DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
			affects_window_size = options_config.resolution_affects_windowed_window_size
			affects_content_size = options_config.resolution_affects_windowed_content_size
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN, DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			affects_window_size = options_config.resolution_affects_fullscreen_window_size
			affects_content_size = options_config.resolution_affects_fullscreen_content_size
		_:
			push_error("Unknown window mode; not setting window size.")
	
	if affects_window_size:
		_get_window().size = resolution
		_get_window().move_to_center()
	
	if affects_content_size:
		_get_window().content_scale_size = resolution
	else:
		_get_window().content_scale_size = Vector2i(0, 0)


## Infers the current resolution from the properties of the main window. This is
## usually [member Window.size], unless [member Window.content_scale_size] has
## been set.
static func get_current_resolution() -> Vector2i:
	var window := _get_window()
	var using_content_size := (window.content_scale_size.x > 0 or window.content_scale_size.y > 0) \
		and window.content_scale_mode != Window.CONTENT_SCALE_MODE_DISABLED
	
	if using_content_size:
		return window.content_scale_size
	
	return window.size


## Applies screen
static func apply_screen(screen: int) -> void:
	DisplayServer.window_set_current_screen(screen)


## Applies the given vsync mode to the main window.
static func apply_vsync(vsync: int) -> void:
	if not _is_vsync_mode(vsync):
		push_error("SV Options Menu Cannot apply vsync mode %d as it is not a valid vsync mode." % vsync)
	
	DisplayServer.window_set_vsync_mode(vsync)


static func _is_vsync_mode(value: int) -> bool:
	# There's not really a more robust way of doing this afaik as built-in enums
	# are not dictionaries like GDScript ones are.
	match value:
		DisplayServer.VSyncMode.VSYNC_DISABLED, \
		DisplayServer.VSyncMode.VSYNC_ENABLED, \
		DisplayServer.VSyncMode.VSYNC_ADAPTIVE, \
		DisplayServer.VSyncMode.VSYNC_MAILBOX:
			return true
		_:
			return false


static func _get_window() -> Window:
	return (Engine.get_main_loop() as SceneTree).root.get_window()


static func _apply_window_mode(window_mode: DisplayServer.WindowMode) -> void:
	DisplayServer.window_set_mode(window_mode)
