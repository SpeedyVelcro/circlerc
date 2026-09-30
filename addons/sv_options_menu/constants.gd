class_name OptionsConstants
extends Object
## SV Options Menu common constants
##
## "Static" class that provides constants used across multiple scripts.

## Path where developer-configured OptionsConfig file is expected to be found.
const OPTIONS_CONFIG_PATH = "res://options_config.tres"


## enum declaring serializable-representation of the specific type of an
## [InputEvent].
enum InputEventType {
	# Values are explicit to remind you to maintain backwards-compatibility (these
	# will be saved to user settings files)
	KEY = 0,
	MOUSE = 1,
	JOYPAD_BUTTON = 2,
	JOYPAD_MOTION = 3
}
