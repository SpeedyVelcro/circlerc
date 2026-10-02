extends Node
## Autoloaded service for interacting with achievements in the SV Achievements addon.
##
## Service (autoloaded as AchievementService) that tracks achievements and completion,
## and allows interacting with and persisting achievement completion.

## Achievements array. Once it is set, you should treat the array as immutable.
## Do not add or remove elements after setting it, as this will break internal
## signal connections.
var achievements: Array[Achievement] = []

## True if sync is enabled. Achievements will sync with the achievement API configured
## in [ProjectSettings] whenever an achievement is unlocked. A sync button will
## also be available in the UI. On ready, this is set by reading [ProjectSettings],
## but should thereafter be set on this singleton if you want to change it.
var sync_enabled: bool = false:
	set(value):
		sync_enabled = value
		sync_enabled_changed.emit(value)
	get:
		return sync_enabled

## True if locked achievements can also be synced instead of just unlocked ones
## (as is the default behaviour). On ready, this is set by reading [ProjectSettings],
## but should thereafter be set on this singleton if you want to change it.
var locked_sync_allowed: bool = false:
	set(value):
		locked_sync_allowed = value
		locked_sync_allowed_changed.emit(value)
	get:
		return locked_sync_allowed

## True if two-way sync is enabled. Under this scheme, achievement progress from
## the API can be used to update local achievement progress. The achievement
## progress with higher priority is used. Functionality may be limited depending
## on which API is used. On ready, this is set by reading [ProjectSettings],
## but should thereafter be set on this singleton if you want to change it.
var two_way_sync: bool = false:
	set(value):
		two_way_sync = value
		two_way_sync_changed.emit(value)
	get:
		return two_way_sync

## Emitted when an achievement is unlocked.
signal achievement_unlocked(achievement: Achievement)

## Emitted when the value of [member sync_enabled] changes.
signal sync_enabled_changed(new_value: bool)

## Emitted when the value of [member locked_sync_allowed] changes.
signal locked_sync_allowed_changed(new_value: bool)

## Emitted when the value of [member two_way_sync] changes.
signal two_way_sync_changed(new_value: bool)


# Override
func _ready() -> void:
	SVAchievementsProjectSettings.configure()
	_load_settings()
	_load_achievements()
	_connect_achievements()
	load_progress()
	if _is_auto_sync_on_start():
		sync_all_achievements()


## Gets the achievement with the given ID. If there is no achievement with that
## ID, returns null.
func get_achievement(id: String) -> Achievement:
	var index := achievements.find_custom(func (a: Achievement) -> bool: return a.achievement_id == id)
	
	if index < 0:
		push_error("No achievement exists with ID \"%s\"" % id)
		return null
	
	return achievements[index]


## Unlock the achievement that has the given ID.
func unlock(id: String) -> void:
	var achievement := get_achievement(id)
	
	if achievement == null:
		return # get_achievement() already pushed an error to the console
	
	achievement.unlock()


## Resets the completion status and progress of all achievements.
func reset_completion() -> void:
	for achievement in achievements:
		achievement.reset_completion()


## Save completion status and progress of all achievements to the JSON file configured in [ProjectSettings],
## or to the given filepath if provided.
##
## AchievementService attempts to automatically call this when when the game exits, but
## it can't detect calls to [code]get_tree().quit()[/code]. Therefore, you should call
## this manually yourself when you are about to quit the game via code. You may also wish
## to call this regularly whenever you save any other data, as good practice to avoid
## data loss.
func save_progress(file_path_override := "") -> void:
	var settings_file_path := _get_settings_completion_file_path()
	if settings_file_path.is_empty():
		return # Already printed error
	
	var file_path = file_path_override if not file_path_override.is_empty() else settings_file_path
	if not (file_path.is_absolute_path() or file_path.is_relative_path()):
		push_error("The provided file path override is not a valid filename.")
		return
	
	var serialized := {}
	for achievement in achievements:
		serialized[achievement.achievement_id] = achievement.serialize_completion()
	
	DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Error opening file for write: %d" % FileAccess.get_open_error())
		return
	
	var json := JSON.stringify(serialized, "\t")
	file.store_string(json)
	file.close()


## Load the completion status and progress of all achievements from the JSON file configured in
## [ProjectSettings], or from the given filepath if provided.
func load_progress(file_path_override := "") -> void:
	var settings_file_path := _get_settings_completion_file_path()
	if settings_file_path.is_empty():
		return # Already printed error
	
	var file_path = file_path_override if not file_path_override.is_empty() else settings_file_path
	if not (file_path.is_absolute_path() or file_path.is_relative_path()):
		push_error("The provided file path override is not a valid filename.")
		return
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		var error := FileAccess.get_open_error()
		match error:
			Error.ERR_FILE_NOT_FOUND:
				return # Likely first launch
			_:
				push_error("Error opening file for read: %d" % FileAccess.get_open_error())
				return
	
	var json := file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(json)
	if parsed is not Dictionary:
		push_error("Failed to parse achievement progress save file. Did not return a Dictionary.")
		return
	
	var dict: Dictionary = parsed
	
	for achievement in achievements:
		if dict.has(achievement.achievement_id) and dict[achievement.achievement_id] is Dictionary:
			achievement.deserialize_completion(dict[achievement.achievement_id])


func _get_settings_completion_file_path() -> String:
	var settings_filepath: Variant = ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_COMPLETION_SAVE_FILE_PATH_PATH)
	var typed_settings_filepath: String
	if settings_filepath is String and settings_filepath.is_absolute_path():
		typed_settings_filepath = settings_filepath
	else:
		push_error("Achievement completion save file path setting is invalid.")
		typed_settings_filepath = "" # Used as indication of error
	return typed_settings_filepath


# Override
func _notification(what: int) -> void:
	# We can't detect calls to get_tree().quit(), but we can at least handle all ways of quitting
	# through the OS here.
	# See https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html
	
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_CRASH:
			save_progress()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if ProjectSettings.get_setting_with_override("application/config/quit_on_go_back"):
				save_progress()


func _load_achievements() -> void:
	var achievements_setting = ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_ACHIEVEMENTS_PATH)
	
	if achievements_setting is not String:
		push_error("Setting %s is wrong type (not a string)" % SVAchievementsConstants.SETTINGS_ACHIEVEMENTS_PATH)
		return
	
	if achievements_setting == "":
		push_error("Achievement list was not set. This is a required setting. See \"SV Achievements\" under Project Settings.")
		assert("Breaking execution because achievement list was not set. Release build will not break here, so make sure you set the achievement list before you export!")
		return
	
	# Despite what the documentation says, it seems load() can read this .tres even if
	# ProjectSettings.editor/export/convert_text_resources_to_binary is true. See
	# https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-load
	# TODO: I should make a minimal example and raise this as a docs issue. (also verify
	# because it might just be because the type hint we're using does UIDs instead)
	var achievement_list = load(achievements_setting)
	
	if achievement_list == null:
		push_error("Achievement list at path \"%s\" failed to load." % achievements_setting)
		return
	
	if achievement_list is not AchievementList:
		push_error("Achievement list at path \"%s\" was wrong type." % achievements_setting)
		return
	
	achievements = achievement_list.achievements
	
	print("Loaded %d achievement(s)." % achievements.size())


## Synchronizes the achievement with the given id by calling the achievement
## API to unlock it or update its progress. Behaviour depends on sync configuration
## in [ProjectSettings], which will determine whether this is a one-way or two-way
## sync, which API to use, and whether the achievement will actually be synced
## at all. (If sync is disabled, just fails silently.)
func sync_achievement(id: String) -> void:
	sync_given_achievement(get_achievement(id))


## Similar to [method sync_achievement], but allows you to sync a provided achievement
## without it needing to be registered.
func sync_given_achievement(achievement: Achievement) -> void:
	if not sync_enabled:
		return
	
	if (not locked_sync_allowed) and (not achievement.is_unlocked()):
		return
	
	var adapter := _get_achievement_sync_adapter()
	
	if adapter == null:
		return
	
	if two_way_sync:
		adapter.sync_two_way(achievement)
	else:
		adapter.sync_one_way(achievement)


## Syncs all achievements. See [method sync_achievement]
func sync_all_achievements() -> void:
	sync_given_achievements(achievements)


func sync_given_achievements(achievements: Array[Achievement]) -> void:
	if not sync_enabled:
		return
	
	var to_sync: Array[Achievement] = achievements.filter(func(achievement: Achievement) -> bool: \
			return achievement.is_unlocked() or locked_sync_allowed)
	
	var adapter := _get_achievement_sync_adapter()
	
	if adapter == null:
		return
	
	if two_way_sync:
		adapter.two_way_sync_multiple(achievements)
	else:
		adapter.one_way_sync_multiple(achievements)


func _is_auto_sync_on_start() -> bool:
	# Don't call get_setting() if it doesn't exist because we don't want to clutter the output with warnings.
	return ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_AUTO_SYNC_ON_START_PATH) \
		if ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_AUTO_SYNC_ON_START_PATH) \
		else false


func _get_achievement_sync_adapter() -> AchievementSyncAdapter:
	var api: SVAchievementsConstants.AchievementAPI = ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_ACHIEVEMENT_API_PATH) \
		if ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_ACHIEVEMENT_API_PATH) \
		else SVAchievementsConstants.AchievementAPI.NONE
	
	var adapter_path: String = ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_CUSTOM_ACHIEVEMENT_SYNC_ADAPTER_PATH_PATH) \
		if ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_CUSTOM_ACHIEVEMENT_SYNC_ADAPTER_PATH_PATH) \
		else ""
	
	match api:
		SVAchievementsConstants.AchievementAPI.NEWGROUNDS:
			return NewgroundsAchievementSyncAdapter.new()
		SVAchievementsConstants.AchievementAPI.GAME_JOLT:
			return GameJoltAchievementSyncAdapter.new()
		SVAchievementsConstants.AchievementAPI.CUSTOM:
			if adapter_path.is_empty() or not adapter_path.is_absolute_path() or adapter_path.get_extension().to_lower() != "gd":
				push_error("Adapter path in ProjectSettings is invalid path. Achievement sync will not work.")
				return null
			var adapter = load(adapter_path)
			if adapter is not AchievementSyncAdapter or adapter == null:
				push_error("Failed to load sync adapter. Achievement sync will not work.")
				return null
			return adapter
		SVAchievementsConstants.AchievementAPI.NONE:
			return null
		_:
			push_error("Invalid achievement API setting. Achievement sync will not work.")
			return null


func _load_settings() -> void:
	sync_enabled = ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_ENABLE_SYNC_PATH) \
		if ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_ENABLE_SYNC_PATH) \
		else false
	
	locked_sync_allowed = ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_ALLOW_LOCKED_SYNC_PATH) \
		if ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_ALLOW_LOCKED_SYNC_PATH) \
		else false
	
	two_way_sync = ProjectSettings.get_setting_with_override(SVAchievementsConstants.SETTINGS_TWO_WAY_SYNC_PATH) \
		if ProjectSettings.has_setting(SVAchievementsConstants.SETTINGS_TWO_WAY_SYNC_PATH) \
		else false


func _connect_achievements() -> void:
	for achievement in achievements:
		achievement.unlocked.connect(_on_achievement_unlocked.bind(achievement))
		achievement.sync_requested.connect(_on_achievement_sync_requested.bind(achievement))


func _disconnect_achievements() -> void:
	# Don't ask me how it works but apparently get_incoming_connections() also
	# returns connections to callables created using .bind() on this object's
	# methods.
	for connection in get_incoming_connections():
		connection["signal"].disconnect(connection["callable"])


# Signal connection
func _on_achievement_unlocked(achievement: Achievement) -> void:
	achievement_unlocked.emit(achievement)
	sync_given_achievement(achievement)


# Signal connection
func _on_achievement_sync_requested(achievement: Achievement) -> void:
	sync_given_achievement(achievement)

# Override
func _exit_tree() -> void:
	_disconnect_achievements()
