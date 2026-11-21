class_name GlyphSet
extends Resource
## Set of glyphs representing input events.
##
## Contains [Texture2D] glyphs for input events to be rendered instead of their
## names. Useful particularly for controller buttons, but in some games you may
## wish to splurge out and add glyphs for all the keys on your keyboard.
# The original plan was for this to be a dictionary, but that turns out to be
# really difficult to edit in the inspector.

@export_group("Controller Glyphs")
@export var joy_button_a_glyph: Texture2D
@export var joy_button_b_glyph: Texture2D
@export var joy_button_x_glyph: Texture2D
@export var joy_button_y_glyph: Texture2D
@export var joy_button_back_glyph: Texture2D
@export var joy_button_guide_glyph: Texture2D
@export var joy_button_start_glyph: Texture2D
@export var joy_button_left_stick_glyph: Texture2D
@export var joy_button_right_stick_glyph: Texture2D
@export var joy_button_left_shoulder_glyph: Texture2D
@export var joy_button_right_shoulder_glyph: Texture2D
@export var joy_button_dpad_up_glyph: Texture2D
@export var joy_button_dpad_down_glyph: Texture2D
@export var joy_button_dpad_left_glyph: Texture2D
@export var joy_button_dpad_right_glyph: Texture2D
@export var joy_button_misc1_glyph: Texture2D
@export var joy_button_paddle1_glyph: Texture2D
@export var joy_button_paddle2_glyph: Texture2D
@export var joy_button_paddle3_glyph: Texture2D
@export var joy_button_paddle4_glyph: Texture2D
@export var joy_button_touchpad_glyph: Texture2D
# TODO: Remaining misc buttons, see @GlobalScope.JoyButton
@export var joy_left_axis_up_glyph: Texture2D
@export var joy_left_axis_down_glyph: Texture2D
@export var joy_left_axis_left_glyph: Texture2D
@export var joy_left_axis_right_glyph: Texture2D
@export var joy_right_axis_up_glyph: Texture2D
@export var joy_right_axis_down_glyph: Texture2D
@export var joy_right_axis_left_glyph: Texture2D
@export var joy_right_axis_right_glyph: Texture2D
@export var joy_left_trigger_glyph: Texture2D
@export var joy_right_trigger_glyph: Texture2D

@export_group("Mouse Glyphs")
@export var mouse_button_left_glyph: Texture2D
@export var mouse_button_right_glyph: Texture2D
@export var mouse_button_middle_glyph: Texture2D
@export var mouse_wheel_up_glyph: Texture2D
@export var mouse_wheel_down_glyph: Texture2D
@export var mouse_wheel_left_glyph: Texture2D
@export var mouse_wheel_right_glyph: Texture2D
@export var mouse_button_extra1_glyph: Texture2D
@export var mouse_button_extra2_glyph: Texture2D

@export_group("Custom Glyphs")
## For input events that don't have an exported property, you can use this
## dictionary to set their glyphs. Prefer setting the dedicated exported
## properties instead, as typed dictionaries are fiddly to edit in the inspector.
##
## This will be ignored for any input event that has a dedicated exported property,
## even if that property is unset.
@export var custom_glyphs: Dictionary[InputEvent, Texture2D]


## Get the glyph for the given [InputEvent]. If there is no glyph, returns
## [code]null[/code].
func get_glyph(event: InputEvent) -> Texture2D:
	# TODO
	
	return _get_custom_glyph(event)


func _get_custom_glyph(event: InputEvent) -> Texture2D:
	if event is InputEventJoypadButton:
		match event.button_index:
			JOY_BUTTON_A:
				return joy_button_a_glyph
			JOY_BUTTON_B:
				return joy_button_b_glyph
			JOY_BUTTON_X:
				return joy_button_x_glyph
			JOY_BUTTON_Y:
				return joy_button_y_glyph
			JOY_BUTTON_BACK:
				return joy_button_back_glyph
			JOY_BUTTON_GUIDE:
				return joy_button_guide_glyph
			JOY_BUTTON_START:
				return joy_button_start_glyph
			JOY_BUTTON_LEFT_STICK:
				return joy_button_left_stick_glyph
			JOY_BUTTON_RIGHT_STICK:
				return joy_button_right_stick_glyph
			JOY_BUTTON_LEFT_SHOULDER:
				return joy_button_left_shoulder_glyph
			JOY_BUTTON_RIGHT_SHOULDER:
				return joy_button_right_shoulder_glyph
			JOY_BUTTON_DPAD_UP:
				return joy_button_dpad_up_glyph
			JOY_BUTTON_DPAD_DOWN:
				return joy_button_dpad_down_glyph
			JOY_BUTTON_DPAD_LEFT:
				return joy_button_dpad_left_glyph
			JOY_BUTTON_DPAD_RIGHT:
				return joy_button_dpad_right_glyph
			JOY_BUTTON_MISC1:
				return joy_button_misc1_glyph
			JOY_BUTTON_PADDLE1:
				return joy_button_paddle1_glyph
			JOY_BUTTON_PADDLE2:
				return joy_button_paddle2_glyph
			JOY_BUTTON_PADDLE3:
				return joy_button_paddle3_glyph
			JOY_BUTTON_PADDLE4:
				return joy_button_paddle4_glyph
	
	if event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_LEFT_X:
				if event.axis_value < 0.0:
					return joy_left_axis_left_glyph
				else:
					return joy_right_axis_right_glyph
			JOY_AXIS_LEFT_Y:
				if event.axis_value < 0.0:
					return joy_left_axis_up_glyph
				else:
					return joy_left_axis_down_glyph
			JOY_AXIS_RIGHT_X:
				if event.axis_value < 0.0:
					return joy_right_axis_left_glyph
				else:
					return joy_right_axis_right_glyph
			JOY_AXIS_RIGHT_Y:
				if event.axis_value < 0.0:
					return joy_right_axis_up_glyph
				else:
					return joy_right_axis_down_glyph
			JOY_AXIS_TRIGGER_LEFT:
				return joy_left_trigger_glyph
			JOY_AXIS_TRIGGER_RIGHT:
				return joy_right_trigger_glyph
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				return mouse_button_left_glyph
			MOUSE_BUTTON_RIGHT:
				return mouse_button_right_glyph
			MOUSE_BUTTON_MIDDLE:
				return mouse_button_middle_glyph
			MOUSE_BUTTON_WHEEL_UP:
				return mouse_wheel_up_glyph
			MOUSE_BUTTON_WHEEL_DOWN:
				return mouse_wheel_down_glyph
			MOUSE_BUTTON_WHEEL_LEFT:
				return mouse_wheel_left_glyph
			MOUSE_BUTTON_WHEEL_RIGHT:
				return mouse_wheel_right_glyph
	
	for key in custom_glyphs.keys():
		if not InputEventHelper.is_same_binding(key, event):
			continue
		return custom_glyphs[key]
	return null
