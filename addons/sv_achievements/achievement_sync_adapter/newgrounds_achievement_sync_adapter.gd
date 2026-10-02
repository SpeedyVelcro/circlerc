class_name NewgroundsAchievementSyncAdapter
extends AchievementSyncAdapter
## Adapter for the Newgrounds API
##
## An [AchievementSyncAdapter] for v1.x of the newgrounds-godot-4 plugin by Aksel and
## contributors found at [url]https://github.com/jefvel/newgrounds-godot-4[/url].
## You must have this plugin installed in your project for this class to work
## properly.


# Override
func sync_one_way(achievement: Achievement) -> void:
	if achievement.newgrounds_id < 0:
		push_error("Achievement %s does not have a newgrounds id." % achievement.achievement_id)
		return
	
	if achievement.is_unlocked():
		_get_ng_autoload().medal_unlock(achievement.newgrounds_id)


# Override
func sync_two_way(achievement: Achievement) -> void:
	if achievement.newgrounds_id < 0:
		push_error("Achievement %s does not have a newgrounds id." % achievement.achievement_id)
		return
	
	if achievement.is_unlocked():
		sync_one_way(achievement)
		return
	
	# TODO: Probably not very performant, is there a way of just loading one medal?
	var medals: Array = _get_ng_autoload().medal_get_list()
	var medal_index := medals.find_custom(func(medal) -> bool: return medal.id == achievement.newgrounds_id)
	if medal_index < 0:
		return
	
	if medals[medal_index].unlocked:
		achievement.unlock()


# Currently unused because it seems leaner to use the NG singleton, but I wanted
# to at least note this down because dynamically loading non-engine classes at
# runtime is quite unintuitive.
func _get_newgrounds_medal_unlocker_class() -> GDScript:
	var class_list := ProjectSettings.get_global_class_list()
	var class_data := class_list[class_list.find_custom(func(class_dict: Dictionary) -> bool: return class_dict["class"] == "NewgroundsMedalUnlocker")]
	var class_script = load(class_data["path"])
	return class_script


# Dynamic retrieval to avoid compile errors for users that are not using Newgrounds
# or this adapter.
func _get_ng_autoload() -> Node:
	return Engine.get_main_loop().root.get_node("NG")
