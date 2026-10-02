class_name SVAchievementsProjectSettings
extends Object
## Helper class for configuring [ProjectSettings].
##
## This class contains a method to configure [ProjectSettings] with default
## values. As suggested by the documentation, this should be called both at plugin
## load and runtime because values at their defaults are not saved. Hence, this
## has been separated out into its own class for reuse instead of only
## being called in plugin.gd.


## Configure default settings and property hints in [ProjectSettings] for SV
## Achievements. Call this in plugin.gd, and on game start at runtime (should be
## done automatically if you autoload AchievementService)
static func configure() -> void:
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_ACHIEVEMENTS_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_ACHIEVEMENTS_PATH, "")
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_ACHIEVEMENTS_PATH, "")
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_ACHIEVEMENTS_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.tres,*.res"
	})
	
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_COMPLETION_SAVE_FILE_PATH_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_COMPLETION_SAVE_FILE_PATH_PATH, SVAchievementsConstants.SETTINGS_DEFAULT_COMPLETION_SAVE_FILE_PATH)
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_ACHIEVEMENTS_PATH, SVAchievementsConstants.SETTINGS_DEFAULT_COMPLETION_SAVE_FILE_PATH)
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_COMPLETION_SAVE_FILE_PATH_PATH,
		"type": TYPE_STRING
	})
	
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_ENABLE_SYNC_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_ENABLE_SYNC_PATH, false)
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_ENABLE_SYNC_PATH, false)
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_ENABLE_SYNC_PATH,
		"type": TYPE_BOOL
	})
	
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_ACHIEVEMENT_API_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_ACHIEVEMENT_API_PATH, SVAchievementsConstants.AchievementAPI.NONE)
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_ACHIEVEMENT_API_PATH, SVAchievementsConstants.AchievementAPI.NONE)
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_ACHIEVEMENT_API_PATH,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _enum_to_hint_string(SVAchievementsConstants.AchievementAPI)
	})
	
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_CUSTOM_ACHIEVEMENT_SYNC_ADAPTER_PATH_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_CUSTOM_ACHIEVEMENT_SYNC_ADAPTER_PATH_PATH, "")
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_CUSTOM_ACHIEVEMENT_SYNC_ADAPTER_PATH_PATH, "")
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_CUSTOM_ACHIEVEMENT_SYNC_ADAPTER_PATH_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.gd"
	})
	
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_ALLOW_LOCKED_SYNC_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_ALLOW_LOCKED_SYNC_PATH, false)
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_ALLOW_LOCKED_SYNC_PATH, false)
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_ALLOW_LOCKED_SYNC_PATH,
		"type": TYPE_BOOL
	})
	
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_TWO_WAY_SYNC_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_TWO_WAY_SYNC_PATH, false)
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_TWO_WAY_SYNC_PATH, false)
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_TWO_WAY_SYNC_PATH,
		"type": TYPE_BOOL
	})
	
	if not ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_AUTO_SYNC_ON_START_PATH):
		ProjectSettings.set_setting(SVAchievementsConstants.SETTINGS_AUTO_SYNC_ON_START_PATH, false)
	ProjectSettings.set_initial_value(SVAchievementsConstants.SETTINGS_AUTO_SYNC_ON_START_PATH, false)
	ProjectSettings.add_property_info({
		"name": SVAchievementsConstants.SETTINGS_AUTO_SYNC_ON_START_PATH,
		"type": TYPE_BOOL
	})


static func _enum_to_hint_string(enum_dict: Dictionary) -> String:
	var hint_string := ""
	for key in enum_dict.keys():
		if not hint_string.is_empty():
			hint_string += ","
		hint_string += "%s:%d" % [key.capitalize(), enum_dict[key]]
	return hint_string
