class_name SVAchievementsConstants
extends Object
## SV Achievement Constants
##
## Contains several constants and enums for the SV Achievements plugin.

enum AchievementAPI {
	## Do not use any achievement API. If sync is enabled, it will do nothing.
	NONE = -1,
	## Use a custom achievement API by extending [AchievementSyncAdapter]. Be
	## sure to set your new class in [ProjectSettings].
	CUSTOM = 0,
	# Reserved: STEAM = 1
	## Use the godot-newgrounds-4 plugin v1.x by Aksel and contributors from
	## [url]https://github.com/jefvel/newgrounds-godot-4[/url]. Ensure the addon
	## is installed in your project.
	NEWGROUNDS = 2,
	## Use the game-jolt-api plugin v0.0.8 (and possibly above) by Joel Gomes da Silva from
	## [url]https://github.com/murikistudio/game-jolt-api[/url]. Ensure the addon
	## is installed in your project.
	GAME_JOLT = 3
}

const _SETTINGS_PLUGIN_PATH := "sv_achievements"
const _SETTINGS_GENERAL_PATH := _SETTINGS_PLUGIN_PATH + "/general"
const _SETTINGS_SYNC_PATH := _SETTINGS_PLUGIN_PATH + "/sync"

## Path to the setting in [ProjectSettings] that stores the game's achievements.
const SETTINGS_ACHIEVEMENTS_PATH := _SETTINGS_GENERAL_PATH + "/achievements"
## Path to the setting in [ProjectSettings] that stores the file path for the
## user's achievement completion save file.
const SETTINGS_COMPLETION_SAVE_FILE_PATH_PATH := _SETTINGS_GENERAL_PATH + "/completion_save_file_path"

## Path to the setting in [ProjectSettings] that indicates which achievement API
## will be used for sync functionality.
const SETTINGS_ACHIEVEMENT_API_PATH := _SETTINGS_SYNC_PATH + "/achievement_api"
## Path to the setting in [ProjectSettings] that stores the path to the .gd file
## defining a custom adapter when using a custom achievement API. Make sure to set
## the achievement API to custom before setting this.
const SETTINGS_CUSTOM_ACHIEVEMENT_SYNC_ADAPTER_PATH_PATH := _SETTINGS_SYNC_PATH + "/custom_achievement_sync_adapter_path"
## Path to the setting in [ProjectSettings] for whether sync buttons should be
## shown on achievements (these are for pushing unlock status to e.g. Steam
## or Newgrounds if it failed to unlock before). This is only read on startup.
const SETTINGS_ENABLE_SYNC_PATH := _SETTINGS_SYNC_PATH + "/enable_sync"
## Path to the setting in [ProjectSettings] for allowing synchronization of locked
## achievements as well as unlocked ones. This is only read on startup.
const SETTINGS_ALLOW_LOCKED_SYNC_PATH := _SETTINGS_SYNC_PATH + "/allow_locked_sync"
## Path to the setting in [ProjectSettings] for allowing two-way sync where the
## side with the greatest progress gets priority. This may be limited for
## certain kinds of achievements where the backend can't fully represent the
## achievement objectives (collection and indexed objectives are particularly
## uncommon on achievement backends). This is only read on startup.
const SETTINGS_TWO_WAY_SYNC_PATH := _SETTINGS_SYNC_PATH + "/two_way_sync"
## Path to the setting in [ProjectSettings] that causes AchievementService to
## automatically sync all achievements on start after loading them.
const SETTINGS_AUTO_SYNC_ON_START_PATH := _SETTINGS_SYNC_PATH + "/auto_sync_on_start"

## Default value for the path to the file that stores the user's achievement
## progress.
const SETTINGS_DEFAULT_COMPLETION_SAVE_FILE_PATH := "user://achievements.json"
