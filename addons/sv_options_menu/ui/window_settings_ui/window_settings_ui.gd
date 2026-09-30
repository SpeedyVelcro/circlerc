extends HBoxContainer
## UI for modifying resolution and window mode settings.
##
## This scene contains settings for modifying the resolution (both custom and
## from a list) and the window mode. It comes with its own apply button, and
## changes are not applied or even saved until that button is pressed. This is
## so that the player can comfortably adjust the settings without the UI
## jumping all over the place.
##
## At least one of [member OptionsConfig.manage_resolution],
## [member OptionsConfig.manage_window_mode], or [member OptionsConfig.manage_screen]
## must be enabled, otherwise this scene will hide itself.


## Whether to display a "custom resolution" checkbox that, when checked, allows
## the player to manually type in a resolution instead of selecting the presets
## from a dropdown.
@export var allow_custom_resolution: bool = true:
	get:
		return allow_custom_resolution
	set(value):
		allow_custom_resolution = value
		_custom_resolution_check_box.visible = value
## Window modes that will be selectable in the window mode dropdown (provided
## SV Options Menu is enabled to manage window modes)
@export var selectable_window_modes: Array[DisplayServer.WindowMode] = [
	DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
	DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
	DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
]

@export_group("Selectable Resolutions")
## If true, the modern resolution standards defined in [ResolutionListModernStandards]
## will be selectable in the dropdown menu.
@export var modern_standards_selectable: bool = true
## If true, the modern resolution standards defined in [ResolutionListHistoricalStandards]
## will be selectable in the dropdown menu.
@export var historical_standards_selectable: bool = false
## If true, the modern resolution standards defined in [ResolutionListSteamHardwareSurvey]
## will be selectable in the dropdown menu.
@export var steam_hardware_survey_selectable: bool = false
## If true, the resolutions of all connected screens recognised by [DisplayServer]
## will be added to the dropdown menu.
@export var screen_resolutions_selectable: bool = true
## If true, the viewport size defined in the project settings will be selectable
## as a resolution in the dropdown menu.
@export var project_settings_viewport_selectable: bool = true
## If true, the window size override defined in the project settings will be
## selectable as a resolution in the dropdown menu (provided both dimensions
## are not zero).
@export var project_settings_window_size_override_selectable: bool = true
## Defines additional resolutions to add to the dropdown menu.
@export var selectable_custom_resolutions: Array[Vector2i] = []
## Resolutions below either of these dimensions will not be added to the
## dropdown.
@export var minimum_selectable_resolution: Vector2i = Vector2i(0, 0)
## Resolutions above either of these dimensions will not be added to the
## dropdown. If one of the dimensions is negative, it will be ignored.
@export var maximum_selectable_resolution: Vector2i = Vector2i(-1, -1)
## If true, resolutions will only be added to the dropdown if both of their
## dimensions are smaller or equal to those of at least one display.
@export var only_valid_resolutions_for_screen_selectable: bool = true
## Only resolutions that fit the given aspect ratio will be added to the
## dropdown. Ignored if either dimension is less than or equal to 0.
@export var only_aspect_ratio_selectable: Vector2i = Vector2i(0, 0)

@onready var _window_mode_option_button: OptionButton = $VBoxContainer/WindowModeOptionButton
@onready var _custom_resolution_check_box: CheckBox = $VBoxContainer/CustomResolutionCheckBox
@onready var _resolution_option_button: OptionButton = $VBoxContainer/ResolutionOptionButton
@onready var _custom_resolution_container: Control = $VBoxContainer/CustomResolutionHBoxContainer
@onready var _resolution_width_line_edit: LineEdit = $VBoxContainer/CustomResolutionHBoxContainer/WidthLineEdit
@onready var _resolution_height_line_edit: LineEdit = $VBoxContainer/CustomResolutionHBoxContainer/HeightLineEdit
@onready var _screen_container: Control = $VBoxContainer/ScreenHBoxContainer
@onready var _screen_option_button: OptionButton = $VBoxContainer/ScreenHBoxContainer/ScreenOptionButton
@onready var _apply_button: Button = $ApplyButton

var _selectable_resolutions: ResolutionList
var _using_custom_resolution: bool = false


# Override
func _ready() -> void:
	# TODO: Hide options that aren't managed
	var options_config = OptionsConfigProvider.get_config()
	if not (options_config.manage_resolution or options_config.manage_window_mode or options_config.manage_screen):
		visible = false
	
	if not options_config.manage_resolution:
		_resolution_option_button.visible = false
		_custom_resolution_check_box.visible = false
		_custom_resolution_container.visible = false
	
	if not options_config.manage_window_mode:
		_window_mode_option_button.visible = false
	
	if not options_config.manage_screen:
		_screen_container.visible = false
	
	if not allow_custom_resolution:
		_custom_resolution_check_box.visible = false
	
	_populate_resolutions()
	_populate_window_modes()
	_populate_screens()
	set_to_current_settings()


## Updates the window mode and resolution settings to reflect the current settings.
## You should call this when closing/reopening your options menu (assuming you
## don't just free the scene) so that non-applied settings are cleared when
## next entering the options menu.
##
## You do not need to call this on ready as that already happens automatically.
func set_to_current_settings() -> void:
	var options_config = OptionsConfigProvider.get_config()
	
	if options_config.manage_resolution:
		_select_current_resolution()
	
	if options_config.manage_window_mode:
		_select_current_window_mode()
	
	if options_config.manage_screen:
		_select_current_screen()
	
	_apply_button.disabled = not _validate()


## Applies the current settings
func apply() -> void:
	if not _validate():
		push_error("Attempted to apply invalid window settings")
		return
	
	var options_config = OptionsConfigProvider.get_config()
	
	var resolution: Vector2i
	if _using_custom_resolution:
		resolution = Vector2i(int(_resolution_width_line_edit.text), int(_resolution_height_line_edit.text))
	else:
		resolution = _selectable_resolutions.get_resolution(_resolution_option_button.selected)
	
	var window_mode: int = _window_mode_option_button.get_item_id(_window_mode_option_button.selected)
	
	var screen = _option_button_id_to_screen(_screen_option_button.get_item_id(_screen_option_button.selected))
	
	OptionsDisplayHelper.apply_window_settings(window_mode, resolution, options_config)
	
	if options_config.manage_screen:
		OptionsDisplayHelper.apply_screen(screen)
	
	# Now save to options
	var options := OptionsProvider.get_local_options()
	
	if options_config.manage_resolution:
		options.set_option(options_config.get_resolution_x_path(), resolution.x)
		options.set_option(options_config.get_resolution_y_path(), resolution.y)
	
	if options_config.manage_window_mode:
		options.set_option(options_config.window_mode_option_path, window_mode)
	
	if options_config.manage_screen:
		options.set_option(options_config.screen_option_path, screen)


func _select_current_resolution() -> void:
	_custom_resolution_check_box.set_pressed_no_signal(false)
	_set_using_custom_resolution(false)
	
	var res = OptionsDisplayHelper.get_current_resolution()
	
	_resolution_width_line_edit.text = str(res.x)
	_resolution_height_line_edit.text = str(res.y)
	
	if _selectable_resolutions.has_resolution(res):
		_resolution_option_button.select(_selectable_resolutions.get_resolution_index(res))
		return
	
	if _resolution_option_button.item_count >= 1:
		_resolution_option_button.select(0)
	else:
		_resolution_option_button.select(-1)
	
	if allow_custom_resolution:
		_custom_resolution_check_box.set_pressed_no_signal(true)
		_set_using_custom_resolution(true)


func _select_current_window_mode() -> void:
	var window_mode := DisplayServer.window_get_mode()
	
	if selectable_window_modes.has(window_mode):
		_window_mode_option_button.select(_window_mode_option_button.get_item_index(window_mode))
		return
	
	if _window_mode_option_button.item_count >= 1:
		_window_mode_option_button.select(0)
	else:
		_window_mode_option_button.select(-1)


func _select_current_screen() -> void:
	# Because screen setting (at least the way we handle it) is only meaningful on apply
	# (e.g. if you're on the primary screen, should the setting be primary or that
	# screen's number?) we use the current setting in the [GameOptions] instead of
	# trying to figure out what screen we're on.
	var options_config = OptionsConfigProvider.get_config()
	
	var current_screen = null
	if options_config.manage_screen:
		current_screen = OptionsProvider.get_local_options().get_option(options_config.screen_option_path)
	if current_screen == null:
		current_screen = DisplayServer.SCREEN_PRIMARY
	
	var id = _screen_to_option_button_id(current_screen)
	if _is_screen_option_button_id_valid(id):
		_screen_option_button.select(_screen_option_button.get_item_index(id))
		return
	
	_screen_option_button.select(_screen_option_button.get_item_index(_screen_to_option_button_id(DisplayServer.SCREEN_PRIMARY)))


func _populate_resolutions() -> void:
	var resolutions_to_include: Array[ResolutionList] = []
	
	if modern_standards_selectable:
		resolutions_to_include.append(ResolutionListModernStandards.new())
	
	if historical_standards_selectable:
		resolutions_to_include.append(ResolutionListHistoricalStandards.new())
	
	if steam_hardware_survey_selectable:
		resolutions_to_include.append(ResolutionListSteamHardwareSurvey.new())
	
	if screen_resolutions_selectable:
		var screen_sizes: Array[Vector2i] = []
		for screen: int in range(DisplayServer.get_screen_count()):
			screen_sizes.append(DisplayServer.screen_get_size(screen))
		if screen_sizes.size() > 0:
			resolutions_to_include.append(ResolutionList.new(screen_sizes))
	
	if selectable_custom_resolutions.size() > 0:
		resolutions_to_include.append(ResolutionList.new(selectable_custom_resolutions))
	
	if project_settings_viewport_selectable:
		var res := Vector2i(
			ProjectSettings.get_setting_with_override("display/window/size/viewport_width"),
			ProjectSettings.get_setting_with_override("display/window/size/viewport_height")
			)
		if res.x > 0 and res.y > 0:
			resolutions_to_include.append(ResolutionList.new([res]))
	
	if project_settings_window_size_override_selectable:
		var res := Vector2i(
			ProjectSettings.get_setting_with_override("display/window/size/window_width_override"),
			ProjectSettings.get_setting_with_override("display/window/size/window_height_override")
			)
		if res.x > 0 and res.y > 0:
			resolutions_to_include.append(ResolutionList.new([res]))
	
	var combined := ResolutionList.combine(resolutions_to_include)
	_selectable_resolutions = ResolutionList.clamp_between(combined, minimum_selectable_resolution, maximum_selectable_resolution)
	
	if only_valid_resolutions_for_screen_selectable:
		_selectable_resolutions = _selectable_resolutions.filter(func(res: Vector2i):
			for screen: int in range(DisplayServer.get_screen_count()):
				var size := DisplayServer.screen_get_size(screen)
				if res.x <= size.x and res.y <= size.y:
					return true
			return false
			)
	
	if only_aspect_ratio_selectable.x > 0 and only_aspect_ratio_selectable.y > 0:
		_selectable_resolutions = _selectable_resolutions.filter(func(res: Vector2i): return AspectRatioHelper.is_aspect_ratio(res, only_aspect_ratio_selectable))
	
	_resolution_option_button.clear()
	for res in _selectable_resolutions:
		var resolution_name = "%dx%d" % [res.x, res.y]
		_resolution_option_button.add_item(resolution_name) # Index already matches resolution list due to earlier clear


func _populate_window_modes() -> void:
	_window_mode_option_button.clear()
	
	const TR_CONTEXT := "SVOptionsMenuWindowMode"
	for window_mode in selectable_window_modes:
		var text = tr("Unknown", TR_CONTEXT)
		match window_mode:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				text = tr("Windowed", TR_CONTEXT)
			DisplayServer.WindowMode.WINDOW_MODE_MINIMIZED:
				text = tr("Minimized", TR_CONTEXT)
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				text = tr("Maximized", TR_CONTEXT)
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				text = tr("Fullscreen", TR_CONTEXT)
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				text = tr("Exclusive Fullscreen", TR_CONTEXT)
		_window_mode_option_button.add_item(text, window_mode)


func _populate_screens() -> void:
	_screen_option_button.clear()
	
	_screen_option_button.add_item(tr("Primary", "SVOptionsMenuScreen"), _screen_to_option_button_id(DisplayServer.SCREEN_PRIMARY))
	
	for screen: int in range(DisplayServer.get_screen_count()):
		# Add 1 to text-representation of screen number, because Windows counts from 1 for displays,
		# and Linux and macOS just use screen names in settings anyway so the number here doesn't matter.
		_screen_option_button.add_item(str(screen + 1), _screen_to_option_button_id(screen))


func _screen_to_option_button_id(screen: int) -> int:
	if screen == DisplayServer.SCREEN_PRIMARY:
		return 0
	
	if screen >= 0:
		return screen + 1
	
	return screen


func _option_button_id_to_screen(id: int) -> int:
	if id == 0:
		return DisplayServer.SCREEN_PRIMARY
	
	if id >= 1:
		return id - 1
	
	return id


func _is_screen_option_button_id_valid(id: int) -> bool:
	return id >= 0 and id < DisplayServer.get_screen_count() + 1


func _set_using_custom_resolution(value: bool) -> void:
	_using_custom_resolution = value
	_custom_resolution_container.visible = value
	_resolution_option_button.visible = not value
	
	_apply_button.disabled = not _validate()


func _validate() -> bool:
	var options_config = OptionsConfigProvider.get_config()
	var resolution_dimension_regex = RegEx.create_from_string("^[1-9][0-9]*$")
	
	if options_config.manage_resolution:
		if _using_custom_resolution:
			if resolution_dimension_regex.search(_resolution_width_line_edit.text) == null:
				return false
			if resolution_dimension_regex.search(_resolution_height_line_edit.text) == null:
				return false
		else:
			if _resolution_option_button.selected == -1:
				return false
	
	if options_config.manage_window_mode:
		if _window_mode_option_button.selected == -1:
			return false
	
	if options_config.manage_screen:
		if _screen_option_button.selected == -1:
			return false
	
	return true


# Signal connection
func _on_custom_resolution_check_box_toggled(toggled_on: bool) -> void:
	_set_using_custom_resolution(toggled_on)


# Signal connection
func _on_width_line_edit_text_changed(new_text: String) -> void:
	_apply_button.disabled = not _validate()


# Signal connection
func _on_height_line_edit_text_changed(new_text: String) -> void:
	_apply_button.disabled = not _validate()


func _on_apply_button_pressed() -> void:
	apply()
