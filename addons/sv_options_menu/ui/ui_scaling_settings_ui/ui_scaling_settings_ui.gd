extends Control
## SV Options Menu UI element for adjusting UI Scaling.
##
## UI for editing UI scaling, provided that it is managed by SV Options Menu as
## set with [member OptionsConfig.manage_ui_scaling].
# TODO: Refactor to use combo_slider.tscn, as this scene currently duplicates a lot of its' functionality.
# TODO: Disconnect signal on destruction
# TODO: Allow enforcing cap and minimum on custom scale

## Use custom min and max values by setting [member min_value] and [member max_value].
## If this is false, the min and max values are derived from current resolution
## and [OptionsConfig] settings.
@export var custom_min_and_max: bool = false
## Minimum value, requires [member custom_min_and_max] to be true.
@export var min_value: float = 1.0:
	set(value):
		min_value = value
		_update_slider_min_value()
	get:
		return min_value
## Max value, requires [member custom_min_and_max] to be true.
@export var max_value: float = 2.0:
	set(value):
		max_value = value
		_update_slider_max_value()
		_populate_menu_button()
	get:
		return max_value
## Snap increment for slider.
@export var slider_snap: float = 0.05:
	set(value):
		slider_snap = value
		_update_slider_snap()
	get:
		return slider_snap
## If true, the player will be able to type in custom values for UI scale.
@export var allow_custom_value: bool = false:
	set(value):
		allow_custom_value = value
		_update_line_edit_visibility()
		_update_value_label_visibility()
	get:
		return allow_custom_value
## Increments to include in the dropdown. For example, if this is 0.5, the dropdown
## will include UI scales of 1.0, 1.5, 2.0, 2.5, and so on up to the max value.
@export var dropdown_increments: float = 1.0
## Extra UI Scales to include in the dropdown. If you want to include any UI
## scales below 1.0, you will have to include them here.
@export var dropdown_custom_ui_scales: Array[float] = []

var _internal_ui_scale: float = 1.0:
	set(value):
		_internal_ui_scale = value
		_on_internal_ui_scale_changed()
	get:
		return _internal_ui_scale

var _options: GameOptions
var _options_config: OptionsConfig

var _value_on_focus_enter: float = 1.0

@onready var _slider: Slider = $HSlider
@onready var _menu_button: MenuButton = $Control/MenuButton
@onready var _line_edit: LineEdit = $Control/LineEdit
@onready var _value_label: Label = $Control/ValueLabel


# Override
func _ready() -> void:
	_options = OptionsProvider.get_local_options()
	_options_config = OptionsConfigProvider.get_config()
	
	_menu_button.get_popup().id_pressed.connect(_on_popup_menu_id_pressed)
	
	update_arrow_icon()
	_update_line_edit_visibility()
	_update_value_label_visibility()
	
	_update_slider()
	_populate_menu_button()
	
	if not custom_min_and_max:
		_slider.min_value = _options_config.ui_minimum_scale
		_calculate_auto_max_value()
		get_window().size_changed.connect(_on_window_size_changed) # In case we are not managing resolution
	
	if _options_config.manage_ui_scaling:
		_set_internal_ui_scale_from_variant(_options.get_option(_options_config.ui_scale_option_path))
	
	if _options_config.manage_ui_scaling or not custom_min_and_max:
		# Need to listen to UI scaling or resolution
		_options.option_modified.connect(_on_options_option_modified)


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


func _on_internal_ui_scale_changed() -> void:
	_slider.set_value_no_signal(_internal_ui_scale) # Slider node auto-clamps value
	_line_edit.text = _format_float(_internal_ui_scale)
	_value_label.text = _format_float(_internal_ui_scale)


func _format_float(value: float) -> String:
	if value == 0.0:
		return "0"
	
	var text_value = str(value)
	
	while text_value.ends_with("0"):
		text_value = text_value.trim_suffix("0")
	
	if text_value.ends_with("."):
		text_value = text_value.trim_suffix(".")
	
	return text_value


func _update_options() -> void:
	_options.set_option(_options_config.ui_scale_option_path, _internal_ui_scale)


func _populate_menu_button() -> void:
	var _popup_menu := _menu_button.get_popup()
	_popup_menu.clear()
	
	var current_cap := max_value
	
	var values: Array[float] = []
	values.append_array(dropdown_custom_ui_scales)
	var value: float = 1.0
	while value <= current_cap:
		if not values.has(value):
			values.append(value)
		value = value + dropdown_increments
	values.sort()
	var values_text := values.map(func (v: float) -> String: return _format_float(v))
	
	for value_text in values_text:
		_popup_menu.add_item(value_text)


func _update_slider() -> void:
	_update_slider_min_value()
	_update_slider_max_value()
	_update_slider_snap()


func _update_slider_min_value() -> void:
	if _slider == null:
		return # Not ready yet
	
	_slider.min_value = min_value


func _update_slider_max_value() -> void:
	if _slider == null:
		return # Not ready yet
	
	_slider.max_value = max_value


func _update_slider_snap() -> void:
	if _slider == null:
		return # Not ready yet
	
	_slider.step = slider_snap


func _update_line_edit_visibility() -> void:
	if _line_edit == null:
		return # Not ready yet
	
	_line_edit.visible = allow_custom_value


func _update_value_label_visibility() -> void:
	if _value_label == null:
		return # Not ready yet
	
	_value_label.visible = not allow_custom_value


func _set_internal_ui_scale_from_variant(value: Variant) -> void:
	if not (value is int or value is float):
		push_error("UI Scale setting was wrong type. Cannot update settings UI.")
		return
	
	_internal_ui_scale = float(value)


func _calculate_auto_max_value() -> void:
	if not custom_min_and_max:
		max_value = OptionsUIScaleHelper.calculate_ui_scale_cap(_options_config)


# Override
func _exit_tree() -> void:
	_menu_button.get_popup().id_pressed.disconnect(_on_popup_menu_id_pressed)
	
	if _options != null and _options.option_modified.is_connected(_on_options_option_modified):
		_options.option_modified.disconnect(_on_options_option_modified)
	
	if get_window().size_changed.is_connected(_on_window_size_changed):
		get_window().size_changed.disconnect(_on_window_size_changed)


# Signal connection
func _on_options_option_modified(path: String, new_value: Variant) -> void:
	if path == _options_config.ui_scale_option_path:
		_set_internal_ui_scale_from_variant(new_value)
	
	if path.begins_with(_options_config.resolution_option_path):
		_calculate_auto_max_value()


# Signal connection
func _on_window_size_changed() -> void:
	_calculate_auto_max_value()


# Signal connection
func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on: # Leaving edit mode
		var regex = RegEx.create_from_string("^(0|([1-9]\\d*))(\\.\\d+)?$")
		var result = regex.search(_line_edit.text)
		if not result:
			return
		
		var new_scale := float(_line_edit.text)
		_internal_ui_scale = new_scale
		
		_update_options()


# Signal connection
func _on_popup_menu_id_pressed(id: int) -> void:
	var _popup_menu := _menu_button.get_popup()
	var new_scale_text := _popup_menu.get_item_text(id)
	var new_scale := float(new_scale_text) # Safe because we populated the text ourselves
	_internal_ui_scale = new_scale
	_update_options()


# Signal connection
func _on_h_slider_value_changed(value: float) -> void:
	_line_edit.text = str(_format_float(value))
	_value_label.text = str(_format_float(value))


# Signal connection
func _on_h_slider_drag_started() -> void:
	# Line edit text may have been messed up by user action, but we need it to
	# show the value while dragging.
	_line_edit.text = str(_format_float(_internal_ui_scale))


# Signal connection
func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
	
	_internal_ui_scale = _slider.value
	_update_options()


# Signal connection
func _on_h_slider_focus_entered() -> void:
	_value_on_focus_enter = _internal_ui_scale


# Signal connection
func _on_h_slider_focus_exited() -> void:
	if _slider.value == _value_on_focus_enter:
		return
	
	_internal_ui_scale = _slider.value
	_update_options()
