extends HBoxContainer
## Editor UI for a single input event
##
## Modifies or deletes a single input event for use by an action of the input
## map.

## Current [InputEvent] that is set. Null if no input event is currently set
## (generally only the case when listening for an input event as typically
## deleting is the only way to unset the event)
# TODO: modify input map on update (or should this be done further up the node tree?)

## Action (see [InputMap]) which the [member input_event] is for.
@export var action: String = ""
## [InputEvent] to edit. This should reference the same InputEvent object that
## is in the [InputMap], as it will be editing it.
@export var input_event: InputEvent = null:
	set(value):
		input_event = value
		if not _listening:
			_update_text_to_input_event()
	get:
		return input_event
## True if the input event is locked and uneditable.
@export var locked: bool = false:
	set(value):
		locked = value
		if locked:
			_listening = false
		if _binding_button != null:
			_binding_button.disabled = locked if not _listening else _listening
		if _delete_button != null:
			_delete_button.visible = not locked
	get:
		return locked
@export var delete_icon: Texture2D:
	set(value):
		delete_icon = value
		_update_delete_button_icon()
	get:
		return delete_icon

@onready var _binding_button: Button = $BindingButton
@onready var _delete_button: Button = $DeleteButton
@onready var _listening_visual_timer: Timer = $ListeningVisualTimer

## True if the input event editor is listening for input to change the input
## event.
var _listening: bool = false:
	set(value):
		if not locked:
			if _binding_button != null:
				_binding_button.disabled = value
				_binding_button.toggle_mode = value
		if value and not _listening: # Don't want to interrupt existing listening animation
			_listening_visual_timer.start(0.5)
			_update_listening_text()
		elif (not value) and _listening:
			_listening_visual_timer.stop()
			_update_text_to_input_event()
		_listening = value
	get:
		return _listening


## Start listening for input
func listen() -> void:
	_listening = true

# Override
func _ready() -> void:
	# Because export setters were called before ready, they couldn't affect child nodes yet:
	locked = locked
	input_event = input_event
	delete_icon = delete_icon
	
	_listening_visual_timer.timeout.connect(_update_listening_text)


# Override
func _exit_tree() -> void:
	_listening_visual_timer.timeout.disconnect(_update_listening_text)


func _input(event: InputEvent) -> void:
	# TODO: Break up method
	const JOYPAD_AXIS_THRESHOLD = 0.5
	
	if not _listening:
		return
	
	# Guard against event types that should not be bindable
	if event is InputEventKey:
		match event.keycode:
			Key.KEY_SHIFT, Key.KEY_CTRL, Key.KEY_ALT, Key.KEY_META:
				if event.is_pressed():
					# Need to wait in-case it is being used as a modifier for
					# another key. If the player is actually trying to bind a modifier
					# key on its own, we can take it when it's released
					return
			_:
				if event.is_released():
					return
	elif event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_released():
			return
	elif event is InputEventJoypadMotion:
		if event.axis_value < JOYPAD_AXIS_THRESHOLD:
			# Must meet minimum threshold, otherwise the slightest accidental
			# nudge of the thumbstick would bind it
			return
	elif event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_GUIDE:
			# Usually the guide button functions as the power button, or has
			# some meta function in the OS, so we shouldn't allow it to be
			# bindable to avoid confusion.
			return
		if event.button_index == JOY_BUTTON_MISC1:
			# Usually this has some meta function e.g. Xbox share, Switch capture
			return
	else:
		return
	
	var saved_event: InputEvent = event.duplicate_deep() # Avoid interfering with anything else that intercepts this input (although unlikely since we mark it as handled)
	
	# Although not clearly documented, -1 seems to mean "any device".
	saved_event.device = -1
	
	if saved_event is InputEventJoypadMotion:
		# axis_value doesn't seem to mean anything once it's in the input map
		# (deadzone is controlled at the axis level). By my experimentation, it
		# seems axis_value is set to 1.0 by default when entered into the input
		# map via the editor, so it seems safe to do the same here.
		saved_event.axis_value = 1.0
	
	if saved_event is InputEventFromWindow:
		saved_event.window_id = 0 # Irrelevant info, just set to the default window
	
	if saved_event is InputEventKey:
		# If this event is a modifier on its own, we would only get to this point
		# on release (see above guards). So change the binding to pressed.
		saved_event.pressed = true
		# Event mappings should only have one of keycode, physical_keycode, or
		# unicode set according to Godot InputEventKey docs. We settle on keycode
		# here, so set the others to none.
		saved_event.physical_keycode = KEY_NONE
		saved_event.unicode = KEY_NONE
		# We do not set saved_event.command_or_control_autoremap to true because
		# keys are rebindable anyway if mac users get annoyed.
		# TODO: Maybe command_or_control_autoremap support should be an option in
		# OptionsConfig though? So we can leave the decision to the developer
	
	if saved_event is InputEventMouseButton:
		saved_event.factor = 0
		saved_event.double_click = false
		# Don't record positions, we are just binding mouse buttons.
		saved_event.position = Vector2(0, 0)
		saved_event.global_position = Vector2(0, 0)
	
	var previous_event := input_event
	input_event = saved_event
	
	# Update the input map
	if previous_event == null:
		# This editor must have just been created, in which case we should already
		# be at the end of the list of bindings under this action, and we're just
		# creating a new binding.
		InputMap.action_add_event(action, input_event)
	else:
		# Ideally we want to keep the same order so as to not confuse the player
		# when they return to the options menu. InputMap does not provide a way
		# to manipulate the array directly, so we remove all events that come
		# after, replace the old input event, and put them back again one by one.
		var keep_input_event_stack: Array[InputEvent] = []
		var input_events := InputMap.action_get_events(action)
		for current_event: InputEvent in input_events:
			if current_event == previous_event: # This comp by reference is fine because the InputEventEditor was set up with the actual InputEvent from the InputMap
				InputMap.action_erase_event(action, current_event)
				InputMap.action_add_event(action, input_event)
				break
			# TODO: ignore locked events, because those may not be at the beginning of the input map
			keep_input_event_stack.push_back(current_event)
			InputMap.action_erase_event(action, current_event)
		for current_event: InputEvent in keep_input_event_stack:
			InputMap.action_add_event(action, current_event)
	
	_update_options()
	
	_listening = false
	
	get_viewport().set_input_as_handled()


func _update_options():
	var options_config := OptionsConfigProvider.get_config()
	var options := OptionsProvider.get_bindings()
	var locks := options_config.locked_input_events[action] if options_config.locked_input_events.has(action) else InputEventLocks.new()
	var options_action := InputMapOptionsTranslator.translate_action_to_options(action, locks)
	options.set_option(options_config.get_input_map_action_path(action), options_action)


func _update_text_to_input_event() -> void:
	if input_event == null:
		return
	
	if _binding_button == null:
		return
	
	_binding_button.text = InputEventTextBuilder.build_text(input_event)


func _update_listening_text() -> void:
	if _binding_button == null:
		return
	
	match _binding_button.text:
		".":
			_binding_button.text = ".."
		"..":
			_binding_button.text = "..."
		"...", _:
			_binding_button.text = "."


func _update_delete_button_icon() -> void:
	if _delete_button == null:
		return
	
	_delete_button.icon = delete_icon


# Signal connection
func _on_binding_button_pressed() -> void:
	_listening = true


# Signal connection
func _on_delete_button_pressed() -> void:
	if input_event == null:
		queue_free()
		return # Nothing to delete from input map or options as it is not set yet
	
	InputMap.action_erase_event(action, input_event)
	
	_update_options()
	
	queue_free()
