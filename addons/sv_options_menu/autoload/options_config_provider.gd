extends Node
## Provides [OptionsConfig]
##
## Provides the [OptionsConfig] that was configured by the developer

var _options_config: OptionsConfig

signal config_changed(new_value: OptionsConfig)


## Sets the [OptionsConfig]. All further calls to [method get_config] will
## return this config.
func set_config(options_config : OptionsConfig) -> void:
	_options_config = options_config
	config_changed.emit(options_config)


## Gets the [OptionsConfig]
func get_config() -> OptionsConfig:
	return _options_config
