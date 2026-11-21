extends Node
## Provider for input binding glyphs.
##
## Part of SV Options. Use this to get the glyph that visually represents a
## particular input. Automatically adjusts glyph based on the current device.

var _joy_device_override := ""
var _current_joy_device_name := ""
var _current_joy_device_id := -1
var _joypad_axis_threshold := 0.5

var _using_keyboard_and_mouse := true
var _mouse_speed_threshold := 16.0

var _generic_glyphs: GlyphSet = GlyphSet.new()
var _unique_glyphs: Dictionary[String, GlyphSet] = {}

## Emitted whenever the provider detects a joy device change OR the override has
## changed. You should connect to this so you know when to get new glyphs.
##
## Note that some glyphs may not change between devices due to generic
## glyph fallbacks, or because they're not for a joypad device (e.g. mouse).
signal joy_glyphs_changed

## Emitted when the glyphs for input actions have changed e.g. by changing
## controller or changing to keyboard and mouse.
signal action_glyphs_changed


# Override
func _ready() -> void:
	OptionsConfigProvider.config_changed.connect(_on_options_config_provider_config_changed)
	Input.joy_connection_changed.connect(_on_input_joy_connection_changed)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var connected_devices := Input.get_connected_joypads()
	if connected_devices.size() > 0:
		_current_joy_device_name = Input.get_joy_name(connected_devices[0])
		_current_joy_device_id = connected_devices[0]
		action_glyphs_changed.emit()
		joy_glyphs_changed.emit()
	
	var config := OptionsConfigProvider.get_config()
	if config:
		_update_config(config)


# Override
func _input(event: InputEvent) -> void:
	# TODO: need threshold on joypad motion
	if (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		if event is InputEventJoypadMotion:
			match event.axis:
				JOY_AXIS_LEFT_X, \
						JOY_AXIS_LEFT_Y, \
						JOY_AXIS_RIGHT_X, \
						JOY_AXIS_RIGHT_Y:
					if event.axis_value < _joypad_axis_threshold:
						# Could be unintentional or random noise or something.
						# No need to switch glyphs.
						return
				_:
					# On some controllers (e.g. my XBOX Elite Series 2), some of
					# these undefined axes appear to track gyro/motion sensors.
					# These should not be used for controller usage detection,
					# as they may be accidental.
					return
		
		var emit_action_glyphs_changed := false
		
		if _using_keyboard_and_mouse:
			_using_keyboard_and_mouse = false
			emit_action_glyphs_changed = true
			
		
		if event.device != _current_joy_device_id:
			_current_joy_device_name = Input.get_joy_name(event.device)
			_current_joy_device_id = event.device
			if _joy_device_override.is_empty():
				joy_glyphs_changed.emit()
				emit_action_glyphs_changed = true
		
		if emit_action_glyphs_changed:
			action_glyphs_changed.emit()
		
		return
	
	var mouse_or_keyboard_used := false
	
	if event is InputEventKey:
		mouse_or_keyboard_used = true
	
	if event is InputEventMouseButton:
		mouse_or_keyboard_used = true
	
	if event is InputEventMouseMotion:
		if event.screen_velocity.length() >= _mouse_speed_threshold:
			mouse_or_keyboard_used = true
	
	if mouse_or_keyboard_used:
		if not _using_keyboard_and_mouse:
			_using_keyboard_and_mouse = true
			action_glyphs_changed.emit()
	
	# Do not set as handled. We are only listening to see what controller is
	# currently being used, but the player is likely doing something else with
	# their inputs.


# Override
func _exit_tree() -> void:
	if OptionsConfigProvider.config_changed.is_connected(_on_options_config_provider_config_changed):
		OptionsConfigProvider.config_changed.disconnect(_on_options_config_provider_config_changed)
	
	if Input.joy_connection_changed.is_connected(_on_input_joy_connection_changed):
		Input.joy_connection_changed.disconnect(_on_input_joy_connection_changed)


## Gets the glyph for the given input. Returns null if there is no glyph.
func get_glyph(event: InputEvent) -> Texture2D:
	var device_name := get_current_joy_device_name()
	
	if _unique_glyphs.keys().has(device_name):
		var glyph = _unique_glyphs[device_name].get_glyph(event)
		if glyph != null:
			return glyph
	
	return _generic_glyphs.get_glyph(event)


## Gets bbcode to display a particular glyph, returning a text fallback if there
## is no glyph.
##
## If a glyph is found, this will be returned in the form of an \[img\] tag.
## Use [param options] to pass in BBCode options.
func get_glyph_bbcode(event: InputEvent, options := "width=1em height=1em") -> String:
	var glyph := get_glyph(event)
	if glyph == null:
		return InputEventTextBuilder.build_text(event)
	
	if options.is_empty():
		return "[img]%s[/img]" % glyph.resource_path
	else:
		return "[img %s]%s[/img]" % [options, glyph.resource_path]


## Gets the appropriate glyph for the given input action. Unlike [method get_glyph],
## which only changes when the controller changes, this also changes when
## you switch between mouse/keyboard and controller. It returns the glyph for
## the first input event bound to the action for mouse/keyboard or controller,
## whichever is currently being used.
##
## Connect to [signal action_glyphs_changed] to be informed when this method
## may return a different value
func get_action_glyph(action: String) -> Texture2D:
	return get_glyph(_get_action_event(action))


## As [method get_action_glyph], but returns bbcode in a similar fashion to
## [method get_glyph_bbcode].
func get_action_glyph_bbcode(action: String, options := "width=1em height=1em") -> String:
	return get_glyph_bbcode(_get_action_event(action), options)


## Overrides joy device tracking so this service returns glyphs for the given
## device instead.
##
## Usually you should do this on platforms where only one type of controller is
## ever expected. e.g. you might leave the override clear on PC to support a
## range of controllers, but set the override on steam deck so you always
## show glyphs that meet steam deck verified requirements.
func set_joy_device_override(device_name: String) -> void:
	_joy_device_override = device_name
	if _current_joy_device_name != _joy_device_override:
		joy_glyphs_changed.emit()
		action_glyphs_changed.emit()


## Clears override set by [method set_joy_device_override]. Returns to displaying
## glyphs appropriate for the most recent joy device.
func clear_joy_device_override() -> void:
	var override_before_clear = _joy_device_override
	_joy_device_override = ""
	if _current_joy_device_name != override_before_clear:
		joy_glyphs_changed.emit()
		action_glyphs_changed.emit()


## Get the device name of the joypad currently being used for glyphs.
func get_current_joy_device_name() -> String:
	return _current_joy_device_name if _joy_device_override.is_empty() else _joy_device_override


func _get_action_event(action: String) -> InputEvent:
	var events := InputMap.action_get_events(action)
	var event: InputEvent = null
	
	if events.is_empty():
		return null
	
	if _using_keyboard_and_mouse:
		var index: int = events.find_custom(func(e: InputEvent) -> bool: \
				return e is InputEventMouseButton \
						or e is InputEventMouseMotion \
						or e is InputEventKey)
		if index > -1:
			event = events[index]
	else:
		var index: int = events.find_custom(func(e: InputEvent) -> bool: \
				return e is InputEventJoypadButton \
						or e is InputEventJoypadMotion)
		if index > -1:
			event = events[index]
	
	if event == null:
		event = events[0] # Fall back on the first input event.
	
	return event


func _update_config(config: OptionsConfig) -> void:
	_generic_glyphs = config.generic_glyphs
	_unique_glyphs = config.unique_glyphs
	joy_glyphs_changed.emit()
	action_glyphs_changed.emit()


# Signal connection
func _on_options_config_provider_config_changed(new_value: OptionsConfig) -> void:
	_update_config(new_value)


# Signal connection
func _on_input_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		if not _current_joy_device_name.is_empty():
			return
		var new_name := Input.get_joy_name(device)
		if new_name != _current_joy_device_name:
			_current_joy_device_name = new_name
			_current_joy_device_id = device
			if _joy_device_override.is_empty():
				joy_glyphs_changed.emit()
				action_glyphs_changed.emit()
	else:
		for id in Input.get_connected_joypads():
			if Input.get_joy_name(id) == _current_joy_device_name:
				# Current joy device was not disconnected. Ignore.
				return
		_current_joy_device_name = ""
		_current_joy_device_id = -1
		if _joy_device_override.is_empty():
			joy_glyphs_changed.emit()
			action_glyphs_changed.emit()
	
