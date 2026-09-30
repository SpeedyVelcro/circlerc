class_name OptionsConfig
extends Resource
## Configuration for SV Options Menu
##
## When a .tres of OptionsConfig is placed in the root of the project, its
## exported variables will be used to configure the functionality of SV
## Options Menu
# TODO: It's actually possible for plugins to add this kind of stuff to project settings.
# This setup works for now, but in the long run it's probably preferable to do that (will need a major version bump ofc).

## How to set the default resolution on startup. Used for [member default_resolution_handling]
enum DefaultResolutionHandling {
	## Use the default resolution set in [member default_resolution]
	STATIC,
	## Use the display size of the primary screen as the default resolution
	DISPLAY,
	## Use the display size clamped to the maximum resolution. Ignores aspect
	## ratio.
	CLAMPED,
	## Use the display size clamped to the maximum resolution, but also maintain
	## the aspect ratio of the screen. If the aspect ratio is not the same as
	## that of the maximum resolution, this may leave the resolution slightly
	## short of the max in either or both dimensions.
	MAINTAIN_ASPECT,
	## Use the display size clamped to the maximum resolution, but also maintain
	## the aspect ratio set by [member force_aspect_ratio]
	FORCE_ASPECT
}

## Player-configured options will be saved to and loaded from the json file at
## this file path. If the file and/or directory structure doesn't exist at
## runtime, they will be created.
##
## Example of a valid value: [code]user://profile/options.json[/code]
@export var local_options_file_path: String = "user://user-settings.json"

## Player-configured options that are marked safe for cloud synchronization will
## be saved and loaded here instead of [member local_options_file_path].
@export var cloud_options_file_path: String = "user://user-settings-cloud.json"

## Path to store the user's hotkeys/input bindings. This is stored separately to
## other settings, as it is common for players in some genres (e.g. RTS) to share
## hotkey bindings.
@export var bindings_file_path: String = "user://user-bindings.json"

## Path to store the user's hotkeys/input bindings cloud backup, if they back up
## their bindings to the cloud.
@export var bindings_cloud_backup_file_path: String = "user://user-bindings-cloud-backup.json"

## Default options for use as a fallback that aren't configured elsewhere on
## this class. If this is null, then no custom default options will be used
## (only default options configured elsewhere on this class will be used).
@export var custom_default_options: GameOptions

## When [code]true[/code], the SV Options Menu addon will automatically set up
## all its singletons from the [OptionsConfig] that was loaded.
##
## If you set this to [code]false[/code], can delay application of managed settings,
## and also give you a moment to modify OptionsConfig programmatically if you
## so wish. The OptionsConfig will be loaded into [OptionsConfigProvider] for
## you to modify or replace, but the rest of startup will be delayed. Call
## [method OptionsLifecycle.start_up] to finish start up when you are ready.
@export var auto_start := true

@export_group("Display")
## Master setting for whether SV Options Menu manages resolution. See the other
## "managed" variables for what exactly the configured resolution affects
@export var manage_resolution: bool

@export var resolution_option_path: String = "display/resolution"

## Resolution settings are used to change the window content size when in windowed mode.
## Only has an effect if [member manage_resolution] is [code]true[/code].
## By default, doesn't do anything unless ProjectSettings.display/window/stretch/mode
## is set to something other than "disabled" so that the main window's content size
## can be set separately.
@export var resolution_affects_windowed_content_size: bool = true

## Resolution settings are used to change the window content size when in fullscreen mode.
## Only has an effect if [member manage_resolution] is [code]true[/code].
## By default, doesn't do anything unless ProjectSettings.display/window/stretch/mode
## is set to something other than "disabled" so that the main window's content size
## can be set separately.
@export var resolution_affects_fullscreen_content_size: bool = true

## Resolution settings are used to change the window size when in windowed mode.
## Only has an effect if [member manage_resolution] is [code]true[/code].
@export var resolution_affects_windowed_window_size: bool = true

# TODO: remove this property as docs suggest entering fullscreen mode changes window size
## Resolution settings are used to change the window size when in fullscreen mode.
## Only has an effect if [member manage_resolution] is [code]true[/code].
@export var resolution_affects_fullscreen_window_size: bool = true

## Determines whether SV Options Menu manages window mode of the primary
## game window. The default value will be the one set in project settings.
@export var manage_window_mode: bool

## Path to store window mode in [GameOptions]. Used if [member manage_window_mode]
## is [code]true[/code].
@export var window_mode_option_path: String = "display/window_mode"

## Determines whether SV Options Menu manages the screen the game displays on.
## The default value will be the primary screen.
@export var manage_screen: bool = false

## Path to store the screen the game displays on in [GameOptions]. Used if
## [member manage_screen] is [code]true[/code].
@export var screen_option_path: String = "display/screen"

## Determines whether SV Options Menu will manage VSync mode of the main game
## window. The default value will be [member ProjectSettings.display/window/vsync/vsync_mode].
@export var manage_vsync: bool = true

## Path to store VSync mode. Used if [member manage_vsync] is [code]true[/code].
@export var vsync_option_path: String = "display/vsync"

## Determines how SV Options Menu determines default resolution on startup.
@export var default_resolution_handling: DefaultResolutionHandling = DefaultResolutionHandling.STATIC

## If true, SV Options Menu will automatically calculate the default resolution
## based on display size instead of using [member default_resolution]. It is
## recommended to only turn this on if you default to fullscreen mode, as
## otherwise the default resolution may shove the title bar off the screen.
@export var auto_default_resolution: bool

## Default resolution to use if [member auto_default_resolution] is not set
## to auto-configure default resolution. If this is set to (0, 0), the viewport
## size in project settings will be used.
@export var default_resolution: Vector2i = Vector2i(0, 0)

## If this is set to anything other than (0, 0), the aspect ratio will be forced
## to this ratio when determining default resolution.
@export var force_aspect_ratio: Vector2i = Vector2i(0, 0)

## Maximum resolution to be allowed when auto-configuring default resolution.
## If this is set to (0, 0), then there is no maximum.
@export var maximum_auto_resolution: Vector2i = Vector2i(0, 0)

@export_group("Audio")
## Use SV Options Menu to configure volume settings - including muting - for
## audio buses configured in [member editable_buses]
@export var manage_volume: bool = false

## Path to store volume settings in the [GameOptions]. Used if
## [member manage_volume] is set to [code]true[/code].
@export var volume_option_path: String = "audio/volume"

## True if volume settings should be synced to cloud instead of stored locally.
## Only has effect if [member manage_volume] is set to [code]true[/code]. It is
## not recommended to set this, as players are unlikely to want to use the same
## volume settings across different devices.
@export var volume_cloud_sync: bool = false

## Use SV Options Menu to configure the output device used by [AudioServer].
@export var manage_output_device: bool = false

## Path to store output device setting in [GameOptions]. Used if
## [member manage_output_device] is set to [code]true[/code].
@export var output_device_option_path: String = "audio/output_device"

# TODO: Remove, as setting this to true would be crazy
## True if output device setting should be synced to cloud instead of stored
## locally. Only has an effect if [member manage_output_device] is set to
## [code]true[/code]. It is not recommended to set this, as output device
## settings are only really meaningful locally.
@export var output_device_cloud_sync: bool = false

## Use SV Options Menu to configure the input device used by [AudioServer].
@export var manage_input_device: bool = false

## Path to store input device setting in [GameOptions]. Used if
## [member manage_input_device] is set to [code]true[/code].
@export var input_device_option_path: String = "audio/input_device"

# TODO: remove, as setting this to true would be crazy
## True if input device setting should be synced to cloud instead of stored
## locally. Only has an effect if [member manage_input_device] is set to
## [code]true[/code]. It is not recommended to set this, as output device
## settings are only really meaningful locally.
@export var input_device_cloud_sync: bool = false

## Array of player-editable audio bus configurations. Determines which audio
## buses are editable/managed by SV Options Loader and properties about
## editing them e.g. defaults.
##
## Only has an effect if [member manage_volume] is [code]true[/code].
@export var editable_buses: Array[EditableBusConfig] = [
	EditableBusConfig.new(AudioBusId.new(0), "Master")
]

@export_group("UI")
## Use SV Options Menu to manage UI scaling. In order for this to work, you
## must put all UI elements you want scaled inside a [UIScalingSubViewport].
## That subviewport should then be placed somewhere it will display at full-screen
## size without interfering with its size properties, such as a [SubViewportContainer]
## with Full Rect anchors, and stretch set to false.
@export var manage_ui_scaling: bool = false

## Path to store UI scale in the local options.
@export var ui_scale_option_path: String = "ui/scale"

## The default UI scale if [member manage_ui_scaling] is true. If this is less
## than or equal to 0.0, then it will automatically set to the ratio between
## the current viewport size (the resolution if [member manage_resolution] is
## true), and [member ui_scaling_reference_resolution]. This may be snapped
## to values set in [member ui_scaling_valid_scales], or clamped depending
## on the values of [member ui_scaling_auto_cap] and [member ui_minimum_scale].
@export var default_ui_scale: float = 0.0

## UI scale will snap to these values when being automatically set on startup
## or when resolution changes and the UI scale is outside the min or max
## calculated with [member ui_scaling_reference_resolution] and
## [member ui_scaling_minimum_reference_ratio]. If this array is empty, then the UI scale can be
## any arbitrary float.
##
## Note that this is only used when SV Options Menu makes a managed change for
## you. The UI Scale Settings UI has its own config for valid user inputs, for
## which you likely want to allow more granular settings to be set by the player
## manually.
@export var ui_scaling_snap_values: Array[float] = [0.25, 0.5, 1.0, 2.0, 4.0, 8.0]

## When using [member ui_scaling_snap_values], it is not necessarily ideal to snap
## exactly at the midpoint. e.g. you may only want to snap to a 2x scale if you are
## sure the player is using something close to a 4K resolution, due to the blurriness
## that comes with scaling the UI up.
##
## This setting determines whether the snapping biases towards rounding down (high values)
## and rounding up (low values). It should be a float between 0.0 and 1.0. You can think
## of it as the point between two values where the snapping switches from rounding
## down to rounding up. For example, if this is set to 0.75 and you have [member ui_scaling_snap_values]
## including 2.0 and 4.0 with nothing in-between, then values below 3.5 will snap to 2.0 and values above 3.5
## will snap to 4.0 (as 3.5 is 75% of the way between 2.0 and 4.0)
@export_range(0.0, 1.0, 0.05) var ui_scaling_snap_bias: float = 0.75

## UI Scaling will be capped by comparing the current viewport dimensions to
## [member ui_scaling_reference_resolution] in order to prevent UI scaling
## settings that make the UI too big to be usable at small resolutions. If
## the resolution changes, the cap changes, and if the UI scale now exceeds the
## cap, it will be automatically reduced.
##
## The cap is calculated by comparing the smallest dimension of the current
## viewport size to the same dimension of [member ui_scaling_reference_resolution].
## For example, if the reference resolution is set to 720 x 540 and the current
## resolution is 1920 x 1080, then the cap will be 2x. If you were to then
## reduce the resolution to 720 x 540, the cap will be 1x. The cap will never
## go below the minimum set in [member ui_minimum_scale].
@export var ui_scaling_auto_cap: bool = true

## Proportional leeway above the cap generated by [member ui_scaling_auto_cap]
## to give. For example, if the UI scale cap is calculated as 2.0 and this value
## is set to 0.2, then the actual UI scale cap will be 2.4 (because 2.0 + (0.2 * 2.0) = 2.4).
## You should set this if there is still some room to safely scale up the UI when
## at the reference resolution (see [member ui_scaling_reference_resolution])
##
## Should be at least 0, as this property is for raising the cap. Values
## below 0 won't do anything.
@export var ui_scaling_auto_cap_leeway: float = 0.0

## Set this to the resolution the UI is designed for. This will be used to set
## the default UI scale if [member default_ui_scale] is not set, or will be
## used to set the scaling cap if [member ui_scaling_auto_cap] is true.
##
## If either dimension is less than or equal to 0, the viewport size set in the
## project settings will be used as a default reference resolution instead.
@export var ui_scaling_reference_resolution: Vector2i = Vector2i(0, 0)

## The UI scale will not be set below this value by any managed change (you
## should still be able to force it). This should be reduced appropriately if
## you make a high-DPI UI so that you can support traditional resolutions in the
## 720p-1080p range.
@export_range(0.0, 1.0, 0.005) var ui_minimum_scale: float = 1.0

@export_group("Controls")
## Use SV Options Menu to configure input maps
@export var manage_input_map: bool = false

## Path to store input map settings in [GameOptions]. Used if
## [member manage_input_map] is set to [code]true[/code].
@export var input_map_option_path: String = "controls/bindings"

## Array of user-editable actions. Any action in this array will be configured
## by SV Options Menu.
##
## Only has an effect if [member manage_input_map] is [code]true[/code].
@export var editable_input_actions: Array[String]

## Dictionary of actions and input events to "lock" i.e. override the
## [member editable_input_actions] setting to prevent editing. This allows you
## to prevent unbinding of certain important [InputEvent]s to an action, while
## still allowing users to add extra bindings.
##
## The key is the action name, as defined in [InputMap] and
## [member editable_input_actions], and the value is an [InputEventLocks]
## containing all the [InputEvent]s you want to be un-editable for the given
## action.
@export var locked_input_events: Dictionary[String, InputEventLocks]


## Dictionary of human-readable labels for [InputMap] actions. If a label isn't
## included for a particular input action but it's marked editable in
## [member editable_input_actions], then the input map editor will display
## it using [method String.capitalize] instead.
@export var input_action_labels: Dictionary[String, String]


## Gets the default options, which include all configured defaults among the
## properties of this object, as well as any bespoke defaults configured in
## [member custom_default_options].
##
## Both local and cloud options will appear on the returned object, as both
## local and cloud options are meant to use the same defaults as a fallback.
func get_default_options() -> GameOptions:
	var default_options: GameOptions = custom_default_options.duplicate_deep(Resource.DEEP_DUPLICATE_ALL) if custom_default_options != null else GameOptions.new()
	
	if manage_volume:
		for bus: EditableBusConfig in editable_buses:
			default_options.set_option_by_keys(get_audio_bus_volume_path(bus.reference), bus.default_volume_linear)
			default_options.set_option_by_keys(get_audio_bus_mute_path(bus.reference), bus.default_mute)
	
	if manage_output_device:
		default_options.set_option(output_device_option_path, "Default") # See AudioServer.output_device
	
	if manage_input_device:
		default_options.set_option(input_device_option_path, "Default") # See AudioServer.input_device
	
	if manage_window_mode:
		default_options.set_option(window_mode_option_path, ProjectSettings.get_setting_with_override("display/window/size/mode"))
	
	if manage_screen:
		default_options.set_option(screen_option_path, DisplayServer.SCREEN_PRIMARY)
	
	if manage_resolution:
		var res := calculate_default_resolution()
		default_options.set_option(get_resolution_x_path(), res.x)
		default_options.set_option(get_resolution_y_path(), res.y)
	
	if manage_vsync:
		default_options.set_option(vsync_option_path, ProjectSettings.get_setting_with_override("display/window/vsync/vsync_mode"))
	
	if manage_ui_scaling:
		var scale := OptionsUIScaleHelper.calculate_default_ui_scale(self)
		default_options.set_option(ui_scale_option_path, scale)
	
	if manage_input_map:
		var input_map_actions := InputMapOptionsTranslator.translate_input_map_actions_to_options(editable_input_actions, locked_input_events)
		default_options.set_option(input_map_option_path, input_map_actions)
	
	return default_options


## Gets the options path as an [Array] to the volume setting for a particular
## audio bus. This is an array, [i]not[/i] a string, because the audio bus
## reference may be an integer if it's by id.
func get_audio_bus_volume_path(ref: AudioBusReference) -> Array:
	return _audio_bus_to_volume_base_path(ref) + ["level"]

## Gets the options path as an [Array] to the mute setting for a particular
## audio bus. This is an array, [i]not[/i] a string, because the audio bus
## reference may be an integer if it's by id.
func get_audio_bus_mute_path(ref: AudioBusReference) -> Array:
	return _audio_bus_to_volume_base_path(ref) + ["mute"]


## Gets the paths to the resolution's width dimension
func get_resolution_x_path() -> String:
	return resolution_option_path + "/x"


## Gets the paths to the resolution's height dimension
func get_resolution_y_path() -> String:
	return resolution_option_path + "/y"


## Gets the path to the given input map action's configured input events
func get_input_map_action_path(action: String) -> String:
	return input_map_option_path + "/" + action


func _audio_bus_to_volume_base_path(ref: AudioBusReference) -> Array:
	var bus_key = ref.to_variant()
	return GameOptions.path_to_keys(volume_option_path) + [bus_key]


## Calculates the default resolution if set to auto, otherwise returns the
## set default resolution.
func calculate_default_resolution(for_display: int = DisplayServer.SCREEN_PRIMARY) -> Vector2i:
	if default_resolution_handling == DefaultResolutionHandling.STATIC:
		if default_resolution.x > 0 and default_resolution.y > 0:
			return default_resolution
		else:
			return Vector2i(
				ProjectSettings.get_setting_with_override("display/window/size/viewport_width"),
				ProjectSettings.get_setting_with_override("display/window/size/viewport_height")
			)
	
	var display_size := DisplayServer.screen_get_size(for_display)
	if default_resolution_handling == DefaultResolutionHandling.DISPLAY:
		return display_size
	
	var clamped := Vector2i(min(display_size.x, maximum_auto_resolution.x), min(display_size.y, maximum_auto_resolution.y))
	if default_resolution_handling == DefaultResolutionHandling.CLAMPED:
		return clamped
	
	if default_resolution_handling == DefaultResolutionHandling.MAINTAIN_ASPECT:
		return AspectRatioHelper.fit_aspect_ratio_within(AspectRatioHelper.to_aspect_ratio(display_size), clamped)
	
	if default_resolution_handling == DefaultResolutionHandling.FORCE_ASPECT:
		return AspectRatioHelper.fit_aspect_ratio_within(AspectRatioHelper.to_aspect_ratio(force_aspect_ratio), clamped)
	
	push_error("Invalid default resolution handling. Using current window size as fallback.")
	return DisplayServer.window_get_size()


## Get the reference resolution. See [member ui_scaling_reference_resolution]
func get_reference_resolution() -> Vector2i:
	var reference_resolution := ui_scaling_reference_resolution
	
	if reference_resolution.x <= 0 or reference_resolution.y <= 0:
		var x: int = ProjectSettings.get_setting_with_override("display/window/size/viewport_width")
		var y: int = ProjectSettings.get_setting_with_override("display/window/size/viewport_height")
		reference_resolution = Vector2i(x, y)
	
	return reference_resolution
