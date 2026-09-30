class_name InputMapOptionsTranslator
extends Object
## Translates between input map and [Dictionary] for SV Options Menu
##
## Translator class that translates from input map to [Dictionary]s that can
## be inserted into a [GameOptions] and vice-versa. Can also translate
## individual actions.


## Translate the entire [InputMap] to a JSON-serializable form for options
## files. Pass in an action-keyed dictionary of [InputEventLocks] to exclude
## certain input events for serialization of certain actions.
static func translate_input_map_to_options(locks: Dictionary[String, InputEventLocks] = {}) -> Dictionary:
	return translate_input_map_actions_to_options(InputMap.get_actions().map(func (x: StringName) -> String: return String(x)), locks)


## Translate the given actions from the InputMap[] to a single JSON-serializable
## dictionary. Pass in an action-keyed dictionary of [InputEventLocks] to exclude
## certain input events for serialization of certain actions.
static func translate_input_map_actions_to_options(actions: Array[String], locks: Dictionary[String, InputEventLocks] = {}) -> Dictionary:
	var dict := {}
	
	for action in actions:
		var event_locks := locks[action] if locks.has(action) else InputEventLocks.new()
		dict[action] = translate_action_to_options(action, event_locks)
	
	return dict


## Translates the given action from the [InputMap] to a JSON-serializable [Array] of
## configured input events. Pass in an [InputEventLocks] to exclude certain input
## events for serialization.
static func translate_action_to_options(action: String, locks: InputEventLocks = InputEventLocks.new()) -> Array:
	if not InputMap.has_action(action):
		push_error("Tried to translate InputMap action \"%s\" to options, but InputMap does not have that action. Translaitng to empty array." % action)
		return []
	
	var options := OptionsProvider.get_bindings()
	
	var event_dictionaries: Array = []
	var input_map_events := InputMap.action_get_events(action)
	for input_map_event: InputEvent in input_map_events:
		if locks.locked_events.any(func (e): return _input_events_match(input_map_event, e)):
			continue # Locked input events are always the same so don't need to be saved
		
		var dict = translate_input_event_to_options(input_map_event)
		event_dictionaries.append(dict)
	return event_dictionaries


static func translate_input_event_to_options(input_event: InputEvent) -> Dictionary:
	var dict := {}
	var type: int = -1
	if input_event is InputEventKey:
		dict["type"] = OptionsConstants.InputEventType.KEY
		dict["keycode"] = input_event.keycode
		dict["location"] = input_event.location
	if input_event is InputEventMouseButton:
		dict["type"] = OptionsConstants.InputEventType.MOUSE
		dict["button_index"] = input_event.button_index
	if input_event is InputEventJoypadButton:
		dict["type"] = OptionsConstants.InputEventType.JOYPAD_BUTTON
		dict["button_index"] = input_event.button_index
	if input_event is InputEventJoypadMotion:
		dict["type"] = OptionsConstants.InputEventType.JOYPAD_MOTION
		dict["axis"] = input_event.axis
		dict["axis_value"] = input_event.axis_value
	if input_event is InputEventWithModifiers:
		dict["alt_pressed"] = input_event.alt_pressed
		dict["ctrl_pressed"] = input_event.ctrl_pressed
		dict["meta_pressed"] = input_event.meta_pressed
		dict["shift_pressed"] = input_event.shift_pressed
	return dict


## Translate an options-form input map dictionary to the real [InputMap]. Clears
## and reconfigures ALL input events, except those specified in [param locks].
## Inverse of [method translate_input_map_to_options]
static func translate_options_to_input_map(options: Dictionary, locks: Dictionary[String, InputEventLocks] = {}):
	translate_options_to_input_map_actions(options, InputMap.get_actions().map(func (x: StringName) -> String: return String(x)), locks)


## Translate an options-form dictionary of input map actions to the actions on
## the real [InputMap]. Only affects those actions specified by [param actions],
## and [locks] specifies input events to ignore and leave untouched. Reverse of
## [method translate_input_map_actions_to_options].
static func translate_options_to_input_map_actions(options: Dictionary, actions: Array[String], locks: Dictionary[String, InputEventLocks] = {}) -> void:
	for key in options:
		if key is not String:
			push_error("Key %s in options input map dictionary is not a string" % key)
			continue
		if actions.has(key):
			var action_locks := locks[key] if locks.has(key) else InputEventLocks.new()
			translate_options_to_action(options[key], key, action_locks)


## Use an array of input events in options-form to reconfigure the [InputEvent]s
## of the given action in the [InputMap]. Pass in locks to ignore the given
## input events and also leave them untouched on the InputMap. Reverse of
## [method translate_action_to_options].
static func translate_options_to_action(options: Array, action: String, locks: InputEventLocks = InputEventLocks.new()) -> void:
	if not InputMap.has_action(action):
		push_error("Tried to translate options with action name \"%s\" to input map, but input map did not have an action with that name. Skipping translation of this action." % action)
		return
	
	# Clear existing events
	var existing_events := InputMap.action_get_events(action)
	for existing_event in existing_events:
		if not locks.locked_events.any(func (e): return _input_events_match(existing_event, e)):
			InputMap.action_erase_event(action, existing_event)
	
	# Populate with new configurations
	for event_dict in options:
		if event_dict is not Dictionary:
			push_error("One of the serialized input events for action \"%s\" was not a dictionary. Skipping that event." % action)
			continue
		var input_event = translate_options_to_input_event(event_dict)
		if input_event == null:
			push_error("Failed to deserialize an input event for action \"%s\"." % action)
			continue
		if locks.locked_events.any(func (e): return _input_events_match(input_event, e)):
			push_error("Options for action \"%s\" contains a locked input event. Skipping adding this to the input map." % action)
			continue
		InputMap.action_add_event(action, input_event)


## Translate a dictionary in options-form into an [InputEvent]. Reverse of
## [method translate_input_event_to_otpions]. Returns null if the dictionary is
## malformed.
static func translate_options_to_input_event(options: Dictionary) -> InputEvent:
	if not options.has("type"):
		push_error("Missing type property when translating options to input event")
		return null
	if not (options["type"] is int or options["type"] is float):
		push_error("type property was not a number when translating options to input event")
		return null
	
	var input_event: InputEvent
	match int(options["type"]):
		OptionsConstants.InputEventType.KEY:
			input_event = InputEventKey.new()
		OptionsConstants.InputEventType.MOUSE:
			input_event = InputEventMouseButton.new()
		OptionsConstants.InputEventType.JOYPAD_BUTTON:
			input_event = InputEventJoypadButton.new()
		OptionsConstants.InputEventType.JOYPAD_MOTION:
			input_event = InputEventJoypadMotion.new()
		_:
			push_error("Invalid type property when translating options to input event")
			return null
	
	if input_event is InputEventKey:
		if options.has("keycode"):
			if not (options["keycode"] is int or options["keycode"] is float):
				push_error("keycode is not a number")
				return null
			if int(options["keycode"]) is not Key:
				push_error("Keycode is not a valid key")
				return null
			input_event.keycode = int(options["keycode"])
			
		if options.has("location"):
			if not (options["location"] is int or options["location"] is float):
				push_error("location is not a number")
				return null
			if int(options["location"]) is not KeyLocation:
				push_error("Location is not a valid key location")
				return null
			input_event.location = int(options["location"])
	
	if input_event is InputEventMouseButton:
		if options.has("button_index"):
			if not (options["button_index"] is int or options["button_index"] is float):
				push_error("button_index is not a number")
				return null
			if int(options["button_index"]) is not MouseButton:
				push_error("button_index is not a valid mouse button")
				return null
			input_event.button_index = int(options["button_index"])
	
	if input_event is InputEventJoypadButton:
		if options.has("button_index"):
			if not (options["button_index"] is int or options["button_index"] is float):
				push_error("button_index is not a number")
				return null
			if int(options["button_index"]) is not JoyButton:
				push_error("button_index is not a valid joy button")
				return null
			input_event.button_index = int(options["button_index"])
	
	if input_event is InputEventJoypadMotion:
		if options.has("axis"):
			if not (options["axis"] is int or options["axis"] is float):
				push_error("axis is not a number")
				return null
			if int(options["axis"]) is not JoyAxis:
				push_error("axis is not a valid joy axis")
				return null
			input_event.axis = int(options["axis"])
		
		if options.has("axis_value"):
			if not (options["axis_value"] is int or options["axis_value"] is float):
				push_error("axis_value is not a number")
				return null
			input_event.axis_value = float(options["axis_value"])
		else:
			input_event.axis_value = 0.5
	
	if input_event is InputEventWithModifiers:
		if options.has("alt_pressed"):
			if options["alt_pressed"] is not bool:
				push_error("alt_pressed is not a bool")
				return null
			input_event.alt_pressed = options["alt_pressed"]
		
		if options.has("ctrl_pressed"):
			if options["ctrl_pressed"] is not bool:
				push_error("ctrl_pressed is not a bool")
				return null
			input_event.ctrl_pressed = options["ctrl_pressed"]
		
		if options.has("meta_pressed"):
			if options["meta_pressed"] is not bool:
				push_error("meta_pressed is not a bool")
				return null
			input_event.meta_pressed = options["meta_pressed"]
		
		if options.has("shift_pressed"):
			if options["shift_pressed"] is not bool:
				push_error("shift_pressed is not a bool")
				return null
			input_event.shift_pressed = options["shift_pressed"]
	
	return input_event


## Compares two input events, returning true if they are the same according only to properties
## (and type) that are user-configurable.
static func _input_events_match(a: InputEvent, b: InputEvent):
	if a is InputEventKey:
		if b is not InputEventKey:
			return false
		if a.get_keycode_with_modifiers() != a.get_keycode_with_modifiers():
			return false
		if a.location != b.location:
			return false
		return true
	
	if a is InputEventMouseButton:
		if b is not InputEventMouseButton:
			return false
		if a.button_index != b.button_index:
			return false
		return true
	
	if a is InputEventJoypadButton:
		if b is not InputEventJoypadButton:
			return false
		if a.button_index != b.button_index:
			return false
		return true
	
	if a is InputEventJoypadMotion:
		if b is not InputEventJoypadMotion:
			return false
		if a.axis != b.axis:
			return false
		return true
	
	return false
