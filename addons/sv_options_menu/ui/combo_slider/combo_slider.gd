extends Control
## General-purpose combo [HSlider]/[MenuButton]/[LineEdit] control.
##
## This control combines an [HSlider], a [MenuButton], and, optionally, a
## [LineEdit] to modify the same float value. It is effectively similar to a
## slider, but with a few different options for entering values. This is useful
## for cases where a slider makes sense, but where it is still desired to
## suggest values, and (optionally) you want to make the fine-grained control of
## custom text input available.
##
## By setting [member allow_custom_value] to [code]true[/code] and [member hide_slider]
## to [code]false[/code], you can use this purely as a
## [url=https://en.wikipedia.org/wiki/Combo_box]combo box[/url] instead and
## completely ignore the slider functionality.
##
## Note that although this is included in the SV Options Menu addon, this
## specific scene has no specific interoperability with, or dependency on, any
## other part of the addon. It is a general purpose control that you can put
## anywhere you would put Godot's own HSlider.

## Minimum value
@export var min_value: float = 0.0:
	set(value):
		min_value = value
		self.value = minf(self.value, min_value)
		_update_slider_min_value()
	get:
		return min_value
## Max value
@export var max_value: float = 1.0:
	set(value):
		max_value = value
		self.value = maxf(self.value, max_value)
		_update_slider_max_value()
		_populate_menu_button()
	get:
		return max_value
## Snap increment for slider and custom input.
@export var snap: float = 0.05:
	set(value):
		snap = value
		self.value = clampf(snappedf(self.value, snap), min_value, max_value)
		_update_snap()
	get:
		return snap
## Allows the player will be able to type in custom values. Set this to
## [code]true[/code] to enable [url=https://en.wikipedia.org/wiki/Combo_box]combo box[/url]
## functionality.
@export var allow_custom_value := false:
	set(value):
		allow_custom_value = value
		_update_line_edit_visibility()
		_update_value_label_visibility()
	get:
		return allow_custom_value
## Hides the slider, leaving only the dropdown menu. Set this to [code]true[/code]
## and [member allow_custom_value] to [code]true[/code] to turn this scene into
## a pure [url=https://en.wikipedia.org/wiki/Combo_box]combo box[/url] with no
## slider.
@export var hide_slider := false:
	set(value):
		hide_slider = value
		_update_slider_visibility()
	get:
		return hide_slider
## Increments to include in the dropdown. For example, if this is 0.5 and [member min_value] is 1.0, the dropdown
## will include values of 1.0, 1.5, 2.0, 2.5, and so on up to the max value. Set
## to [code]0.0[/code] if you don't want to auto-generate values. In this case,
## you should set at least one value for [member dropdown_custom_values].
@export var dropdown_increments: float = 1.0
## Extra values to include in the dropdown that don't fit the increment.
@export var dropdown_custom_values: Array[float] = []
## When [code]true[/code], the value will be displayed as an integer. If you set
## this you should probably set [member slider_snap] to an integer value.
@export var display_as_integer := false
## Value this control is set to. Can be modified by the user interacting with
## the control, or be setting manually.
##
## Note that snapping only works at runtime, not in the editor (this is not a tool script). So make sure you
## enter a valid value according to your [member snap], [member min_value], and
## [max_value], otherwise you might get some funky results at runtime.
@export var value: float = 1.0:
	set(to):
		_internal_value = clampf(snappedf(to, snap), min_value, max_value)
		_on_value_changed()
		value_changed.emit(value)
	get:
		return _internal_value

## Emitted when the [member value] is changed, either by user input or setting
## it directly.
signal value_changed(to: float)

@onready var _slider: Slider = $HSlider
@onready var _menu_button: MenuButton = $Control/MenuButton
@onready var _line_edit: LineEdit = $Control/LineEdit
@onready var _value_label: Label = $Control/ValueLabel

var _internal_value: float = 1.0

var _value_on_focus_enter: float = 1.0

# Override
func _ready() -> void:
	_menu_button.get_popup().id_pressed.connect(_on_popup_menu_id_pressed)
	
	update_arrow_icon()
	_update_line_edit_visibility()
	_update_value_label_visibility()
	_update_slider_visibility()
	
	_update_slider()
	_populate_menu_button()


## Update the arrow icon used for the underlying [MenuButton]. This grabs the
## arrow icon from the theme for the [OptionButton], in order to display it on
## the MenuButton (which isn't typically possible). Since there is no
## notification to hook into when the theme is changed, you have to call this
## yourself if you change the theme at runtime.
func update_arrow_icon() -> void:
	if not has_theme_icon("arrow", "OptionButton"):
		push_warning("Theme does not have arrow icon for OptionButton")
		return
	
	_menu_button.icon = get_theme_icon("arrow", "OptionButton")


## Set [member value] to the given value without emitting [signal value_changed].
func set_value_no_signal(to: float) -> void:
	_internal_value = to
	_on_value_changed()


# NOT a signal connection - rather called directly from the setter.
func _on_value_changed() -> void:
	_slider.set_value_no_signal(value) # Slider node auto-clamps value
	_line_edit.text = _format_float(value)
	_value_label.text = _format_float(value)


func _format_float(value: float) -> String:
	if value == 0.0:
		return "0"
	
	var text_value = str(value)
	
	if display_as_integer:
		return text_value.split(".")[0]
	
	while text_value.ends_with("0"):
		text_value = text_value.trim_suffix("0")
	
	if text_value.ends_with("."):
		text_value = text_value.trim_suffix(".")
	
	return text_value


func _populate_menu_button() -> void:
	var _popup_menu := _menu_button.get_popup()
	_popup_menu.clear()
	
	var current_cap := max_value
	
	var values: Array[float] = []
	values.append_array(dropdown_custom_values)
	var current_value: float = min_value
	while current_value <= current_cap:
		if not values.has(current_value):
			values.append(current_value)
		current_value = current_value + dropdown_increments
	values.sort()
	var values_text := values.map(func (v: float) -> String: return _format_float(v))
	
	for value_text in values_text:
		_popup_menu.add_item(value_text)


func _update_slider() -> void:
	_update_slider_min_value()
	_update_slider_max_value()
	_update_snap()


func _update_slider_min_value() -> void:
	if _slider == null:
		return # Not ready yet
	
	_slider.min_value = min_value


func _update_slider_max_value() -> void:
	if _slider == null:
		return # Not ready yet
	
	_slider.max_value = max_value


func _update_snap() -> void:
	if _slider == null:
		return # Not ready yet
	
	_slider.step = snap


func _update_line_edit_visibility() -> void:
	if _line_edit == null:
		return # Not ready yet
	
	_line_edit.visible = allow_custom_value


func _update_value_label_visibility() -> void:
	if _value_label == null:
		return # Not ready yet
	
	_value_label.visible = not allow_custom_value


func _update_slider_visibility() -> void:
	if _slider == null:
		return # Not ready yet
	
	_slider.visible = not hide_slider


# Override
func _exit_tree() -> void:
	_menu_button.get_popup().id_pressed.disconnect(_on_popup_menu_id_pressed)


# Signal connection
func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on: # Leaving edit mode
		var regex = RegEx.create_from_string("^(0|([1-9]\\d*))(\\.\\d+)?$")
		var result = regex.search(_line_edit.text)
		if not result:
			return
		
		self.value = float(_line_edit.text)


# Signal connection
func _on_popup_menu_id_pressed(id: int) -> void:
	var _popup_menu := _menu_button.get_popup()
	var new_scale_text := _popup_menu.get_item_text(id)
	value = float(new_scale_text)


# Signal connection
func _on_h_slider_value_changed(value: float) -> void:
	_line_edit.text = str(_format_float(value))
	_value_label.text = str(_format_float(value))


# Signal connection
func _on_h_slider_drag_started() -> void:
	# Line edit text may have been messed up by user action, but we need it to
	# show the value while dragging.
	_line_edit.text = str(_format_float(value))


# Signal connection
func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
	
	value = _slider.value


# Signal connection
func _on_h_slider_focus_entered() -> void:
	_value_on_focus_enter = value


# Signal connection
func _on_h_slider_focus_exited() -> void:
	if _slider.value == _value_on_focus_enter:
		return
	
	value = _slider.value
