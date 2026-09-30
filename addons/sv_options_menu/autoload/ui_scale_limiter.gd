extends Node
## Autoload that clamps UI scaling if the cap changes
##
## If you have an auto cap configured in [OptionsConfig], the UI scale cap may
## change any time the resolution changes. This autoloaded node listens for
## a resolution change, and if that happens, reduces the UI scale so that it
## falls within the new cap.

var _options: GameOptions
var _options_config: OptionsConfig

var _started := false

# Override
func _ready() -> void:
	if OptionsConfigProvider.get_config().auto_start:
		start()


func start() -> void:
	if _started:
		push_error("Attempted to start UI Scale Limiter twice.")
	
	_configure()
	
	OptionsProvider.local_options_changed.connect(_on_options_provider_local_options_changed)
	OptionsConfigProvider.config_changed.connect(_on_options_config_provider_config_changed)
	
	_started = true


## Updates the UI scale, clamping it under the cap if it is now out of bounds.
## Call this if the game doesn't detect a resolution change for some reason. 
func update_ui_scale() -> void:
	if not _options_config.manage_ui_scaling:
		return
	
	var current_ui_scale = _options.get_option(_options_config.ui_scale_option_path)
	
	if not (current_ui_scale is int or current_ui_scale is float):
		push_error("UI scale is not currently a number. Using default UI scale instead.")
		var default_ui_scale := OptionsUIScaleHelper.calculate_default_ui_scale(_options_config)
		_options.set_option(_options_config.ui_scale_option_path, default_ui_scale)
		return
	
	current_ui_scale = float(current_ui_scale)
	
	if OptionsUIScaleHelper.is_ui_scale_in_bounds(current_ui_scale, _options_config):
		return
	
	var new_ui_scale := OptionsUIScaleHelper.snap_to_valid_ui_scale(current_ui_scale, _options_config)
	_options.set_option(_options_config.ui_scale_option_path, new_ui_scale)


func _configure() -> void:
	_disconnect_option_modified_signal()
	_disconnect_window_signal()
	
	_options = OptionsProvider.get_local_options()
	_options_config = OptionsConfigProvider.get_config()
	
	if not _options_config.manage_ui_scaling:
		return
	
	if _options_config.manage_resolution:
		_options.option_modified.connect(_on_options_option_modified)
	else:
		get_window().size_changed.connect(_on_window_size_changed)


func _disconnect_option_modified_signal() -> void:
	if _options != null and _options.option_modified.is_connected(_on_options_option_modified):
		_options.option_modified.disconnect(_on_options_option_modified)

func _disconnect_window_signal() -> void:
	if get_window().size_changed.is_connected(_on_window_size_changed):
		get_window().size_changed.disconnect(_on_window_size_changed)


# Signal connection
func _on_options_provider_local_options_changed(new_value: GameOptions) -> void:
	_configure()


# Signal connection
func _on_options_config_provider_config_changed(new_value: OptionsConfig) -> void:
	_configure()


# Signal connection
func _on_options_option_modified(path: String, new_value: Variant) -> void:
	if path.begins_with(_options_config.resolution_option_path):
		update_ui_scale()


# Signal connection
func _on_window_size_changed() -> void:
	update_ui_scale()
