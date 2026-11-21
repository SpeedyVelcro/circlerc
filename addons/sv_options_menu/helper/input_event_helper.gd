class_name InputEventHelper
extends Object
## Helper for dealing with input events.
##
## Class with static methods for doing common tasks on [InputEvent]s in SV
## Options.


## Returns [code]true[/code] if the [InputEvent]s refer to the same "binding", i.e. are they
## the same key, button, motion etc. regardless of extra data like strength or
## which device they are from.
static func is_same_binding(event_a: InputEvent, event_b: InputEvent) -> bool:
	# TODO: Now that I look at it this might already be implemented by
	# Input.is_match(). I should check the exact details including whether it
	# ignores axis strength, to see if I can replace this method.
	if event_a is InputEventKey:
		if event_b is not InputEventKey:
			return false
		if event_a.get_keycode_with_modifiers() != event_b.get_keycode_with_modifiers():
			return false
		if event_a.location != event_b.location:
			return false
		return true
	
	if event_a is InputEventMouseButton:
		if event_b is not InputEventMouseButton:
			return false
		if event_a.button_index != event_b.button_index:
			return false
		return true
	
	if event_a is InputEventJoypadButton:
		if event_b is not InputEventJoypadButton:
			return false
		if event_a.button_index != event_b.button_index:
			return false
		return true
	
	if event_a is InputEventJoypadMotion:
		if event_b is not InputEventJoypadMotion:
			return false
		if event_a.axis != event_b.axis:
			return false
		return true
	
	return false
