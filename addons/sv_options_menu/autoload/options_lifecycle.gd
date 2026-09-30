extends Node
## Orchestrates startup and shutdown operations for SV Options Menu
##
## This node should be autoloaded after all other SV Options Menu autoloads. It
## will then perform the setup steps - namely loading files - and exit steps -
## namely saving options.
##
## This does not handle saving on exit when you use [code]get_tree().quit()[/code]. If you
## do this (e.g. for a quit button in your main menu), you should be sure to
## call the OptionsSaver autoload. Alternatively, you can inform this node (and
## others) by sending [code]NOTIFICATION_WM_CLOSE_REQUEST[/code] beforehand
## by calling [code]get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)[/code]

var _started := false


## Emitted when startup is complete.
signal started


# Override
func _ready():
	var options_config = _load_options_config()
	OptionsConfigProvider.set_config(options_config)
	
	if options_config.auto_start:
		start_up()


# TODO: doc comment
func start_up() -> void:
	if _started:
		push_error("Cannot call start_up twice.")
		return
	
	var options_config := OptionsConfigProvider.get_config()
	
	OptionsProvider.set_default_options(options_config.get_default_options())
	OptionsProvider.set_local_options(OptionsRepository.new(options_config.local_options_file_path).load_options())
	OptionsProvider.set_cloud_options(OptionsRepository.new(options_config.cloud_options_file_path).load_options())
	OptionsProvider.set_bindings(OptionsRepository.new(options_config.bindings_file_path).load_options())
	OptionsProvider.set_bindings_cloud_backup(OptionsRepository.new(options_config.bindings_cloud_backup_file_path).load_options())
	
	UIScaleLimiter.start()
	
	ManagedOptionsSynchronizer.apply()
	
	_started = true
	started.emit()


## Returns [code]true[/code] if startup has completed
func has_started() -> bool:
	return _started


# Override
func _notification(what: int) -> void:
	# We can't detect calls to get_tree().quit(), but we can at least handle all ways of quitting
	# through the OS here.
	# See https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html
	
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_CRASH:
			OptionsSaver.save()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if ProjectSettings.get_setting_with_override("application/config/quit_on_go_back"):
				OptionsSaver.save()


func _load_options_config() -> OptionsConfig:
		var options_config = load(OptionsConstants.OPTIONS_CONFIG_PATH)
		assert(options_config is OptionsConfig, "Tried to load OptionsConfig from %s but did not get an OptionsConfig. Maybe it is missing or corrupted?" % OptionsConstants.OPTIONS_CONFIG_PATH)
		return options_config
