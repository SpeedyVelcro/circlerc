extends Node
## Provides options
##
## Provides the player-configured [GameOptions]. Local and cloud options are
## stored separately and, unless directly set on each GameOptions (which is not
## recommended, you should just let OptionsProvider handle it), local and cloud
## options each use the default options as a fallback.

var _default_options: GameOptions = GameOptions.new()
var _local_options: GameOptions = GameOptions.new()
var _cloud_options: GameOptions = GameOptions.new()
# TODO: Support for multiple bindings profiles?
var _bindings: GameOptions = GameOptions.new() # Stored separately for shareability of hotkey bindings
var _bindings_cloud_backup: = GameOptions.new() # Will be used for "sync to cloud" button on controls settings


signal default_options_changed(new_value: GameOptions)
signal local_options_changed(new_value: GameOptions)
signal cloud_options_changed(new_value: GameOptions)
signal bindings_changed(new_value: GameOptions)
signal bindings_cloud_backup_changed(new_value: GameOptions)


# Override
func _ready():
	_local_options.set_fallback(_default_options)
	_cloud_options.set_fallback(_default_options)


## Sets the default [GameOptions]. Calling this method causes the other options
## configured by this class to fall back on this one.
func set_default_options(options: GameOptions) -> void:
	_local_options.set_fallback(options)
	_cloud_options.set_fallback(options)
	_bindings.set_fallback(options)
	_bindings_cloud_backup.set_fallback(options)
	_default_options = options
	default_options_changed.emit(options)


## Gets a deep duplicate of the default [GameOptions]. This is a duplicate
## because the default options should not be changed at runtime.
func get_default_options(options: GameOptions) -> void:
	return _default_options.duplicate_deep(Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL)


## Sets the local [GameOptions]. All further calls to [method get_local_options]
## will return this options object. Using this method will also update the
## fallback to the default options.
func set_local_options(options: GameOptions) -> void:
	options.set_fallback(_default_options)
	_local_options = options
	local_options_changed.emit(options)


## Returns the local [GameOptions]. This either returns the options set using
## [method set_local_options], or a default GameOptions if nothing has been set.
func get_local_options() -> GameOptions:
	return _local_options


## This sets the cloud options to the given [GameOptions]. The cloud options
## should be the object that contains options safe for cloud synchronization.
## Using this method will set the fallback of the options to default options.
func set_cloud_options(options: GameOptions) -> void:
	options.set_fallback(_default_options)
	_cloud_options = options
	cloud_options_changed.emit(options)


## Returns the cloud options, which is the [GameOptions] object that contains
## options that are safe for cloud synchronization.
func get_cloud_options() -> GameOptions:
	return _cloud_options


## Sets the bindings to the given [GameOptions]. This should be a GameOptions
## with only the options path for storing the input map settings (see
## [member OptionsConfig.input_map_option_path]), which is stored separately in
## this case so as to save to a separate file (useful for players who want to
## share hotkey bindings, as is common in e.g. RTS games).
##
## Using this method will set the fallback of the options to default options.
func set_bindings(bindings: GameOptions) -> void:
	bindings.set_fallback(_default_options)
	_bindings = bindings
	bindings_changed.emit(bindings)


## Returns the bindings, which is the [GameOptions] with only the options path for
## storing the input map settings (see [member OptionsConfig.input_map_option_path]),
## which is stored separately in this case so as to save to a separate file (useful
## for players who want to share hotkey bindings, as is common in e.g. RTS games).
func get_bindings() -> GameOptions:
	return _bindings


## Sets the cloud backup of bindings (see [method set_bindings]) to the given
## [GameOptions]. These bindings are not to be used directly, but can be restored
## by the player in the options menu.
func set_bindings_cloud_backup(bindings: GameOptions) -> void:
	_bindings_cloud_backup = bindings
	bindings_cloud_backup_changed.emit(bindings)


## Gets the cloud backup of bindings that was set with [method set_bindings_cloud_backup].
## These are not to be used directly, but the getter is provided so they can be saved to
## disk.
func get_bindings_cloud_backup() -> GameOptions:
	return _bindings_cloud_backup


## Replaces the bindings served by [method get_bindings] with a copy of the
## bindings set by [method set_bindings_cloud_backup].
func restore_bindings_cloud_backup() -> void:
	_bindings = _bindings_cloud_backup.duplicate_deep(Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL)
	bindings_changed.emit(_bindings)
