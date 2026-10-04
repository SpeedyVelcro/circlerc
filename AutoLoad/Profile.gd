# Profile.gd

extends Node

const _CURRENT_SAVE_VERSION: int = 4

var level_list = preload("res://Level/LevelList.tres") # TODO: make private
const PROFILE_PATH = "user://profile.json"
# TODO: make these private
var level_unlocked: Array[bool] = []
var level_best_time: Array[TimeScore] = []
var level_no_hit: Array[bool] = []
var level_par_and_no_hit: Array[bool] = []


func new_profile():
	for i in range(level_list.get_number_of_levels()):
		level_unlocked.append(false)
		level_best_time.append(TimeScore.NONE)
		level_no_hit.append(false)
		level_par_and_no_hit.append(false)
	level_unlocked[0] = true
	save_profile()


func save_profile():
	# Store info in dictionary
	var dict = {
		"version": _CURRENT_SAVE_VERSION,
		"level_unlocked" : level_unlocked,
		"level_best_time" : level_best_time.map(func(time): return time.serialize()),
		"level_no_hit": level_no_hit,
		"level_par_and_no_hit": level_par_and_no_hit
	}
	# Save dictionary to file
	var file = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(dict))
	file.close()


func load_profile():
	# TODO: defend against missing fields and incorrect types
	# Load
	if FileAccess.file_exists(PROFILE_PATH):
		# Get dictionary from file
		var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var dict = test_json_conv.get_data()
		file.close()
		
		if _get_save_version(dict) < 2:
			_migrate_save_to_v2(dict)
		
		if _get_save_version(dict) < 3:
			_migrate_save_to_v3(dict)
		
		if _get_save_version(dict) < 4:
			_migrate_save_to_v4(dict)
		
		# Get info out of dictionary
		# Levels unlocked
		level_unlocked.assign(dict["level_unlocked"])
		while level_unlocked.size() < level_list.get_number_of_levels():
			level_unlocked.append(false)
		# Best time
		level_best_time.assign(dict["level_best_time"].map(func(time_data): return TimeScore.deserialize(time_data)))
		while level_best_time.size() < level_list.get_number_of_levels():
			level_best_time.append(TimeScore.NONE)
		# No-hit
		level_no_hit.assign(dict["level_no_hit"])
		while level_no_hit.size() < level_list.get_number_of_levels():
			level_no_hit.append(false)
		# Par and no-hit
		level_par_and_no_hit.assign(dict["level_par_and_no_hit"])
		while level_par_and_no_hit.size() < level_list.get_number_of_levels():
			level_par_and_no_hit.append(false)
	else:
		new_profile()


func submit_level_time(level_number : int, time : TimeScore, no_hit: bool) -> void:
	const SAVE_STEP := false
	var new_best := false
	var new_par := false
	var new_no_hit := false
	var new_no_hit_par := false
	
	var prev_time := get_level_best_time(level_number)
	if time.get_total_milliseconds() < prev_time.get_total_milliseconds():
		set_level_best_time(level_number, time, SAVE_STEP)
		new_best = true
	
	var prev_par := level_list.is_time_under_level_par(level_number, prev_time)
	if (not prev_par) and level_list.is_time_under_level_par(level_number, time):
		# Unde par is automatically calculated by the Profile on get, but we
		# will still need to mark that we are newly under par in order to
		# unlock the achievement.
		new_par = true
	
	var prev_no_hit := is_level_no_hit(level_number)
	if (not prev_no_hit) and no_hit:
		const VALUE := true
		set_level_no_hit(level_number, VALUE, SAVE_STEP)
		new_no_hit = true
	
	var prev_par_and_no_hit := is_level_par_and_no_hit(level_number)
	if (not prev_par_and_no_hit) \
			and no_hit \
			and level_list.is_time_under_level_par(level_number, time):
		const VALUE := true
		set_level_par_and_no_hit(level_number, VALUE, SAVE_STEP)
		new_no_hit_par = true
	
	if new_best or new_par or new_no_hit or new_no_hit_par:
		save_profile()
	
	var finish_all_achievement := AchievementService.get_achievement("finish-all")
	var no_hit_all_achievement := AchievementService.get_achievement("no-hit-all")
	var par_all_achievement := AchievementService.get_achievement("par-all")
	var no_hit_par_all_achievement := AchievementService.get_achievement("no-hit-par-all")
	
	if new_best:
		finish_all_achievement.objective.objectives[level_number - 1].complete()
	
	if new_no_hit:
		no_hit_all_achievement.objective.objectives[level_number - 1].complete()
	
	if new_par:
		par_all_achievement.objective.objectives[level_number - 1].complete()
	
	if new_no_hit_par:
		no_hit_par_all_achievement.objective.objectives[level_number - 1].complete()
	
	if new_best or new_par or new_no_hit or new_no_hit_par:
		AchievementService.save_progress()


# Getters and setters
func set_level_unlocked(level_number : int, value : bool) -> void:
	while level_unlocked.size() < level_number:
		level_unlocked.append(false)
	
	level_unlocked[level_number - 1] = value
	save_profile()


func is_level_unlocked(level_number: int) -> bool:
	return level_unlocked.size() >= level_number \
			and level_unlocked[level_number - 1]


func set_level_best_time(level_number: int, time: TimeScore, save := true) -> void:
	# Don't use this! Use publish_level_time() instead.
	while level_best_time.size() < level_number:
		level_best_time.append(TimeScore.NONE)
	
	level_best_time[level_number - 1] = time
	if save:
		save_profile()


func get_level_best_time(level_number: int) -> TimeScore:
	return level_best_time[level_number - 1] if level_best_time.size() >= level_number else TimeScore.NONE


func is_level_best_time_under_par(level_number: int) -> bool:
	return level_best_time.size() >= level_number \
			and level_list.is_time_under_level_par(level_number, level_best_time[level_number - 1])


func set_level_no_hit(level_number: int, value: bool, save := true) -> void:
	while level_no_hit.size() < level_number:
		level_no_hit.append(false)
	
	level_no_hit[level_number - 1] = value
	if save:
		save_profile()


func is_level_no_hit(level_number: int) -> bool:
	return level_no_hit.size() >= level_number \
			and level_no_hit[level_number - 1]


func is_level_finished(level_number: int) -> bool:
	return level_best_time.size() >= level_number \
			and not level_best_time[level_number - 1].is_none()


func set_level_par_and_no_hit(level_number: int, value: bool, save := true) -> void:
	while level_par_and_no_hit.size() < level_number:
		level_par_and_no_hit.append(false)
	
	level_par_and_no_hit[level_number - 1] = value
	if save:
		save_profile()


func is_level_par_and_no_hit(level_number: int) -> bool:
	return level_par_and_no_hit.size() >= level_number \
			and level_par_and_no_hit[level_number - 1]


func _get_save_version(dict: Dictionary) -> int:
	if not dict.has("version"):
		return 1
	
	var version = dict["version"]
	
	if version is float or version is int:
		return int(version)
	
	# If version is malformed it's probably best to just not mess with it
	push_error("Profile version field is wrong type. Treating as current version.")
	return _CURRENT_SAVE_VERSION


func _migrate_save_to_v2(dict: Dictionary) -> void:
	# Game version v1.1 to v1.2
	# Level 13 is now level 19. Level 14 is now level 20.
	
	if dict.has("level_unlocked") and dict["level_unlocked"] is Array:
		while dict["level_unlocked"].size() < level_list.get_number_of_levels():
			dict["level_unlocked"].append(false)
		
		if dict["level_unlocked"][13 - 1]:
			dict["level_unlocked"][19 - 1] = true
		
		if dict["level_unlocked"][14 - 1]:
			dict["level_unlocked"][14 - 1] = false # We only do this for level 14 because the previous level is different and therefore no longer completed
			dict["level_unlocked"][20 - 1] = true
	
	if dict.has("level_best_time") and dict["level_best_time"] is Array:
		while dict["level_best_time"].size() < level_list.get_number_of_levels():
			dict["level_best_time"].append(-1)
		
		if dict["level_best_time"][13 - 1] >= 0:
			dict["level_best_time"][19 - 1] = dict["level_best_time"][13 - 1]
			dict["level_best_time"][13 - 1] = -1
		
		if dict["level_best_time"][14 - 1] >= 0:
			# We drop the final level time entirely because it has been made
			# significantly harder. Players will have to try agian for a best
			# time.
			dict["level_best_time"][14 - 1] = -1
	
	dict["version"] = 2


func _migrate_save_to_v3(dict: Dictionary) -> void:
	# Best time is now stored as milliseconds rather than centiseconds.
	if dict.has("level_best_time") and dict["level_best_time"] is Array:
		var best_time_array = dict["level_best_time"]
		for i in range(best_time_array.size()):
			var time_data = best_time_array[i]
			if time_data is int or time_data is float:
				# We err on the side of a worse score as players on older saves
				# may have benefitted from rounding.
				best_time_array[i] = (int(time_data) * 10) + 1
	
	dict["version"] = 3


func _migrate_save_to_v4(dict: Dictionary) -> void:
	# Added no hit and par (par on its own is not stored but "par and no-hit" is).
	dict["level_no_hit"] = []
	dict["level_par_and_no_hit"] = []
	for _i in range(level_list.get_number_of_levels()):
		dict["level_no_hit"].append(false)
		dict["level_par_and_no_hit"].append(false)
	
	dict["version"] = 4
