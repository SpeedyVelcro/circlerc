@tool
extends EditorPlugin

## Name of the OptionsConfigProvider autoload
const OPTIONS_CONFIG_PROVIDER_AUTOLOAD_NAME = "OptionsConfigProvider"
## Name of the OptionsProvider autoload
const OPTIONS_PROVIDER_AUTOLOAD_NAME = "OptionsProvider"
## Name of the ManagedOptionsSynchronizer autoload
const MANAGED_OPTIONS_SYNCHRONIZER_AUTOLOAD_NAME = "ManagedOptionsSynchronizer"
## Name of the OptionsLifecycle autoload
const OPTIONS_LIFECYCLE_AUTOLOAD_NAME = "OptionsLifecycle"
## Name of the OptionsSaver autoload
const OPTIONS_SAVER_AUTOLOAD_NAME = "OptionsSaver"
## Name of the UIScaleLimiter autoload
const UI_SCALE_LIMITER_AUTOLOAD_NAME = "UIScaleLimiter"

# Override
func _enter_tree():
	# Order is consequential as these currently have interdependencies.
	add_autoload_singleton(OPTIONS_CONFIG_PROVIDER_AUTOLOAD_NAME, "res://addons/sv_options_menu/autoload/options_config_provider.gd")
	add_autoload_singleton(OPTIONS_PROVIDER_AUTOLOAD_NAME, "res://addons/sv_options_menu/autoload/options_provider.gd")
	add_autoload_singleton(MANAGED_OPTIONS_SYNCHRONIZER_AUTOLOAD_NAME, "res://addons/sv_options_menu/autoload/managed_options_synchronizer.gd")
	add_autoload_singleton(OPTIONS_LIFECYCLE_AUTOLOAD_NAME, "res://addons/sv_options_menu/autoload/options_lifecycle.gd")
	add_autoload_singleton(OPTIONS_SAVER_AUTOLOAD_NAME, "res://addons/sv_options_menu/autoload/options_saver.gd")
	add_autoload_singleton(UI_SCALE_LIMITER_AUTOLOAD_NAME, "res://addons/sv_options_menu/autoload/ui_scale_limiter.gd")
	
	if not FileAccess.file_exists(OptionsConstants.OPTIONS_CONFIG_PATH):
		var config := OptionsConfig.new()
		ResourceSaver.save(config, OptionsConstants.OPTIONS_CONFIG_PATH)


# Override
func _exit_tree():
	remove_autoload_singleton(OPTIONS_PROVIDER_AUTOLOAD_NAME)
	remove_autoload_singleton(OPTIONS_CONFIG_PROVIDER_AUTOLOAD_NAME)
	remove_autoload_singleton(MANAGED_OPTIONS_SYNCHRONIZER_AUTOLOAD_NAME)
	remove_autoload_singleton(OPTIONS_LIFECYCLE_AUTOLOAD_NAME)
	remove_autoload_singleton(OPTIONS_SAVER_AUTOLOAD_NAME)
	remove_autoload_singleton(UI_SCALE_LIMITER_AUTOLOAD_NAME)
	
	# We do not delete the OptionsConfig as that could lead to accidental data loss.
