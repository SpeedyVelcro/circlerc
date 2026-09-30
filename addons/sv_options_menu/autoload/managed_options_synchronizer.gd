extends Node
## Autoloaded service to synchronize managed game options and engine singletons.
##
## This service enforces consistency of engine singleton settings and their
## corresponding settings on [GameOptions] for all those options marked as
## "managed" in [OptionsConfig].


## Updates engine singletons to reflect options configured in [GameOptions] and
## managed by SV Options Loader according to [OptionsConfig]. This is usually
## something done by the options_startup.gd singleton after loading options.
func apply() -> void:
	var config := OptionsConfigProvider.get_config()
	var local_options := OptionsProvider.get_local_options()
	var cloud_options := OptionsProvider.get_cloud_options()
	var bindings := OptionsProvider.get_bindings()
	
	var options_with_volume := cloud_options if config.volume_cloud_sync else local_options
	var options_with_output_device := cloud_options if config.output_device_cloud_sync else local_options
	var options_with_input_device := cloud_options if config.input_device_cloud_sync else local_options
	var options_with_resolution := local_options
	var options_with_window_mode := local_options
	var options_with_screen := local_options
	var options_with_vsync := local_options
	
	if config.manage_volume:
		var volume_settings = options_with_volume.get_option(config.volume_option_path)
		if volume_settings is Dictionary:
			_apply_volume_settings(volume_settings)
		else:
			push_error("Volume settings configured in options were missing or not a dictionary. Volume settings will not be applied.")
	
	if config.manage_output_device:
		var output_device = options_with_output_device.get_option(config.output_device_option_path)
		if output_device is String and AudioServer.get_output_device_list().has(output_device):
			AudioServer.output_device = output_device
		else:
			push_error("Output device configured in options was missing or not a string or not a valid output device. Output device setting will not be applied.")
	
	if config.manage_input_device:
		var input_device = options_with_input_device.get_option(config.input_device_option_path)
		if input_device is String and AudioServer.get_input_device_list().has(input_device):
			AudioServer.input_device = input_device
		else:
			push_error("Input device configured in options was missing or not a string or not a valid output device. Input device setting will not be applied.")
	
	if config.manage_resolution or config.manage_window_mode:
		var resolution_x = options_with_resolution.get_option(config.get_resolution_x_path()) if config.manage_resolution else 0
		var resolution_y = options_with_resolution.get_option(config.get_resolution_y_path()) if config.manage_resolution else 0
		var window_mode = options_with_window_mode.get_option(config.window_mode_option_path) if config.manage_window_mode else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
		
		if resolution_x is float:
			resolution_x = int(resolution_x)
		if resolution_y is float:
			resolution_y = int(resolution_y)
		if window_mode is float:
			window_mode = int(window_mode)
		
		if resolution_x is not int or resolution_y is not int:
			push_error("Resolution configured in options was missing or malformed. Skipping applying window settings.")
		elif window_mode is not DisplayServer.WindowMode:
			push_error("Window mode configured in options was missing or malformed. Skipping applying window settings.")
		else:
			var resolution = Vector2i(resolution_x, resolution_y)
			OptionsDisplayHelper.apply_window_settings(window_mode, resolution, config)
	
	if config.manage_screen:
		var screen = options_with_screen.get_option(config.screen_option_path)
		
		if screen is float:
			screen = int(screen)
		
		if screen is int:
			OptionsDisplayHelper.apply_screen(screen)
		else:
			push_error("Screen configured in options was missing or incorrect. Skipping applying screen.")
	
	if config.manage_vsync:
		var vsync = options_with_vsync.get_option(config.vsync_option_path)
		
		if vsync is float:
			vsync = int(vsync)
		
		if vsync is int:
			OptionsDisplayHelper.apply_vsync(vsync)
		else:
			push_error("Vsync mode in options was missing or incorrect. Skipping applying VSync.")
	
	if config.manage_input_map:
		var options_input_map = bindings.get_option(config.input_map_option_path)
		if options_input_map == null or options_input_map is not Dictionary:
			push_error("Bindings configured in options were missing or malformed. Skipping applying bindings.")
		else:
			InputMapOptionsTranslator.translate_options_to_input_map_actions(options_input_map, config.editable_input_actions, config.locked_input_events)


func _apply_volume_settings(volume_settings: Dictionary) -> void:
	# TODO: move to an OptionsAudioService
	for bus_key in volume_settings.keys():
		var bus_ref: AudioBusReference
		if bus_key is int:
			bus_ref = AudioBusId.new(bus_key)
		elif bus_key is String:
			bus_ref = AudioBusName.new(bus_key)
		else:
			push_error("Volume settings contained an audio bus that wasn't an int or string. Skipping.")
			continue
		
		var bus_settings = volume_settings[bus_key]
		if bus_settings is not Dictionary:
			push_error("Settings for volume bus %s was not a dictionary. Skipping." % bus_key)
			continue
		
		# TODO: Error handling for buses that don't exist. As it stands, I can't see any way in
		# AudioServer of testing that a bus exists.
		
		if bus_settings.has("level") and bus_settings["level"] is float:
			AudioServer.set_bus_volume_linear(bus_ref.get_id(), bus_settings["level"])
		else:
			push_error("Audio bus %s volume level setting was missing or wrong type. Volume level will not be applied for this bus." % bus_key)
		
		if bus_settings.has("mute") and bus_settings["mute"] is bool:
			AudioServer.set_bus_mute(bus_ref.get_id(), bus_settings["mute"])
		else:
			push_error("Audio bus %s mute setting was missing or wrong type. Mute will not be applied for this bus." % bus_key)
