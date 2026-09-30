class_name InputEventTextBuilder
extends Object
## Class for building human-readable strings from [InputEvent]s.
##
## This class has the [method build_text] method allowing you to convert
## [InputEvent]s to human-readable strings. In future may handle translations.
# TODO: BiDi handling for modifiers (e.g. CTRL + Z would translate to Z + CTRL) if this isn't already done by as_text()

# TODO: Use this to translate the literal strings
## Translation context. See Godot docs on translations.
const TR_CONTEXT = "SVOptionsInputEvent"


## Build a human-readable string from the given [InputEvent]. In future,
## may handle translations using [TranslationServer].
static func build_text(input_event: InputEvent) -> String:
	if input_event is InputEventJoypadButton:
		return _build_joypad_button_text(input_event)
	
	if input_event is InputEventJoypadMotion:
		return _build_joypad_motion_text(input_event)
	
	# Remaining input event types we haven't covered have sufficiently concise InputEvent.as_text()
	# representations
	return input_event.as_text() # TODO: does this need to be translated? Not sure if Godot already localises this


static func _build_joypad_button_text(input_event: InputEventJoypadButton) -> String:
	# TODO: Change depending on plugged in controller
	match input_event.button_index:
		# Using SDL button names by default, as this is a ubiquitous enough layout that anyone
		# with a different layout is likely used to translating this to their layout.
		JOY_BUTTON_A: return "Controller A"
		JOY_BUTTON_B: return "Controller B"
		JOY_BUTTON_X: return "Controller X"
		JOY_BUTTON_Y: return "Controller Y"
		JOY_BUTTON_BACK: return "Controller Back"
		JOY_BUTTON_GUIDE: return "Controller Guide"
		JOY_BUTTON_START: return "Controller Start"
		JOY_BUTTON_LEFT_STICK: return "Controller Left Stick Press"
		JOY_BUTTON_RIGHT_STICK: return "Controller Left Stick Press"
		JOY_BUTTON_LEFT_SHOULDER: return "Controller Left Shoulder"
		JOY_BUTTON_RIGHT_SHOULDER: return "Controller Right Shoulder"
		JOY_BUTTON_DPAD_UP: return "Controller D-Pad Up"
		JOY_BUTTON_DPAD_DOWN: return "Controller D-Pad Down"
		JOY_BUTTON_DPAD_LEFT: return "Controller D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT: return "Controller D-Pad Right"
		JOY_BUTTON_MISC1: return "Controller Misc"
		JOY_BUTTON_PADDLE1: return "Controller Paddle 1"
		JOY_BUTTON_PADDLE2: return "Controller Paddle 2"
		JOY_BUTTON_PADDLE3: return "Controller Paddle 3"
		JOY_BUTTON_PADDLE4: return "Controller Paddle 4"
		JOY_BUTTON_TOUCHPAD: return "Controller Touchpad"
	
	return "Controller Button %d" % input_event.button_index # Fallback, just prints the button number

static func _build_joypad_motion_text(input_event: InputEventJoypadMotion) -> String:
	# TODO: Change depending on plugged in controller
	match input_event.axis:
		JOY_AXIS_LEFT_X:
			if input_event.axis_value < 0.0:
				return "Controller Left Stick Left"
			else:
				return "Controller Left Stick Right"
		JOY_AXIS_LEFT_Y:
			if input_event.axis_value < 0.0:
				return "Controller Left Stick Down"
			else:
				return "Controller Left Stick Up"
		JOY_AXIS_RIGHT_X:
			if input_event.axis_value < 0.0:
				return "Controller Right Stick Left"
			else:
				return "Controller Right Stick Right"
		JOY_AXIS_RIGHT_Y:
			if input_event.axis_value < 0.0:
				return "Controller Right Stick Down"
			else:
				return "Controller Right Stick Up"
		JOY_AXIS_TRIGGER_LEFT: return "Controller Left Trigger"
		JOY_AXIS_TRIGGER_RIGHT: return "Controller Right Trigger"
	
	# Fallback, just use the axis number and whether it's positive/negative
	if input_event.axis_value < 0.0:
		return "Controller Axis %d Negative" % input_event.axis
	else:
		return "Controller Axis %d Positive" % input_event.axis
