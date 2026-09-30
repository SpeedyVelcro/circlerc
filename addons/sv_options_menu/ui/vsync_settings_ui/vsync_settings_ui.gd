extends OptionButton
## SV Options Menu UI element for adjusting VSync mode.
##
## An [OptionButton] that sets the [enum DisplayServer.VsyncMode]. Requires
## [member OptionsConfig.manage_vsync] to be [code]true[/code]

## Mapping of [enum DisplayServer.VSyncMode]s and whether they should be included
## as selectable options in the dropdown.
@export var allowed_modes: Dictionary[DisplayServer.VSyncMode, bool] = {
	DisplayServer.VSyncMode.VSYNC_DISABLED: true,
	DisplayServer.VSyncMode.VSYNC_ENABLED: true,
	DisplayServer.VSyncMode.VSYNC_ADAPTIVE: true,
	DisplayServer.VSyncMode.VSYNC_MAILBOX: false
}:
	set(value):
		allowed_modes = value
		_populate_items() # NB: won't fire if you modify dictionary (I don't think); only if you set a new one
	get:
		return allowed_modes

## User-readable string to be displayed in the dropdown menu for each
## [enum DisplayServer.VSyncMode].
@export var mode_strings: Dictionary[DisplayServer.VSyncMode, String] = {
	DisplayServer.VSyncMode.VSYNC_DISABLED: "Disabled",
	DisplayServer.VSyncMode.VSYNC_ENABLED: "Enabled",
	DisplayServer.VSyncMode.VSYNC_ADAPTIVE: "Adaptive",
	DisplayServer.VSyncMode.VSYNC_MAILBOX: "Mailbox"
}:
	set(value):
		mode_strings = value
		_populate_items() # NB: won't fire if you modify dictionary (I don't think); only if you set a new one
	get:
		return mode_strings

## The tooltip displayed for each [enum DisplayServer.VSyncMode] in the
## dropdown.
@export var mode_tooltips: Dictionary[DisplayServer.VSyncMode, String] = {
	DisplayServer.VSyncMode.VSYNC_DISABLED: "VSync will be disabled.",
	DisplayServer.VSyncMode.VSYNC_ENABLED: "VSync will be enabled.",
	DisplayServer.VSyncMode.VSYNC_ADAPTIVE: "VSync will only be enabled when framerate reaches the monitor's refresh rate.",
	DisplayServer.VSyncMode.VSYNC_MAILBOX: "Alternative VSync method that may reduce input lag, especially when framerate is twice as high as the monitor's refresh rate."
}:
	set(value):
		mode_tooltips = value
		_populate_items() # NB: won't fire if you modify dictionary (I don't think); only if you set a new one
	get:
		return mode_tooltips

## Automatically restricts the [member allowed_modes] based on the rendering
## method (see [method DisplayServer.get_current_rendering_method]). When using
## compatibility rendering, this will remove adaptive and mailbox modes from the
## dropdown.
@export var auto_restrict_allowed_modes := true:
	set(value):
		auto_restrict_allowed_modes = value
		_populate_items()
	get:
		return auto_restrict_allowed_modes


var _readied := false
var _item_modes: Array[DisplayServer.VSyncMode] = []


# Override
func _ready() -> void:
	_readied = true
	_populate_items()
	
	_select_current_mode()


func _populate_items() -> void:
	if not _readied:
		return
	
	clear()
	_item_modes = []
	
	var modes := _get_allowed_modes()
	
	for mode in modes:
		_add_mode_item(mode)


func _add_mode_item(mode: DisplayServer.VSyncMode) -> void:
	var label := mode_strings[mode] if mode_strings.has(mode) else str(mode)
	add_item(label)
	_item_modes.append(mode)
	if mode_tooltips.has(mode):
		set_item_tooltip(_item_modes.size() - 1, mode_tooltips[mode])


func _select_current_mode() -> void:
	var mode := DisplayServer.window_get_vsync_mode()
	var index := _item_modes.find(mode)
	
	if index == -1:
		_add_mode_item(mode)
		_select_current_mode() # Next recursive call is garuanteed to succeed
		return
	
	select(index)


func _is_mode_allowed(mode: DisplayServer.VSyncMode) -> bool:
	if not allowed_modes.has(mode):
		return false
	
	# Sadly it doesn't seem there is a constant for gl_compatibility.
	if auto_restrict_allowed_modes \
			and RenderingServer.get_current_rendering_method() == "gl_compatibility" \
			and (mode == DisplayServer.VSyncMode.VSYNC_ADAPTIVE \
			or mode == DisplayServer.VSyncMode.VSYNC_MAILBOX):
		return false
	
	return allowed_modes[mode]


func _get_allowed_modes() -> Array[DisplayServer.VSyncMode]:
	var modes: Array[DisplayServer.VSyncMode] = []
	
	for mode in allowed_modes:
		if _is_mode_allowed(mode):
			modes.append(mode)
	
	return modes


# Signal connection
func _on_item_selected(index: int) -> void:
	if index >= _item_modes.size():
		push_error("Selected item does not have an associated VSync mode")
		return
	
	var mode := _item_modes[index]
	
	OptionsDisplayHelper.apply_vsync(mode)
	OptionsProvider.get_local_options().set_option(
			OptionsConfigProvider.get_config().vsync_option_path,
			mode
			)


func _on_option_modified(path: String, new_value: Variant) -> void:
	if path == OptionsConfigProvider.get_config().vsync_option_path:
		_select_current_mode()


func _connect_signals() -> void:
	var options := OptionsProvider.get_local_options()
	if not options.option_modified.is_connected(_on_option_modified):
		options.option_modified.connect(_on_option_modified)


func _disconnect_signals() -> void:
	# Robust against options provided by OptionsProvider being switched
	for connection in get_incoming_connections():
		connection["signal"].disconnect(connection["callable"])
