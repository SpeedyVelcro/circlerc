# Profile.gd

extends Node

var level_list = preload("res://Level/LevelList.tres")
const PROFILE_PATH = "user://profile.json"
var level_unlocked = []
var level_best_time = []

func _ready():
	load_profile()

func new_profile():
	for i in range(level_list.get_number_of_levels()):
		level_unlocked.append(false)
		level_best_time.append(-1)
	level_unlocked[0] = true
	save_profile()

func save_profile():
	# Store info in dictionary
	var dict = {
		"level_unlocked" : level_unlocked,
		"level_best_time" : level_best_time
	}
	# Save dictionary to file
	var file = File.new()
	file.open(PROFILE_PATH, File.WRITE)
	file.store_string(JSON.new().stringify(dict))
	file.close()

func load_profile():
	# Load
	var file = File.new()
	if file.file_exists(PROFILE_PATH):
		# Get dictionary from file
		file.open(PROFILE_PATH, File.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var dict = test_json_conv.get_data()
		file.close()
		# Get info out of dictionary
		# Levels unlocked
		level_unlocked = dict["level_unlocked"]
		while level_unlocked.size() < level_list.get_number_of_levels():
			level_unlocked.append("false")
		# Best time
		level_best_time = dict["level_best_time"]
		while level_best_time.size() < level_list.get_number_of_levels():
			level_best_time.append(-1)
	else:
		new_profile()

func submit_level_time(level : int, time_cent : int):
	var prev_time = get_level_best_time(level)
	if time_cent < prev_time or prev_time == -1:
		set_level_best_time(level, time_cent)

# Getters and setters
func set_level_unlocked(level : int, value : bool):
	level_unlocked[level] = value
	save_profile()

func is_level_unlocked(level : int):
	return level_unlocked[level]

func set_level_best_time(level : int, time_cent : int):
	# Don't use this! Use publish_level_time() instead.
	level_best_time[level] = time_cent
	save_profile()

func get_level_best_time(level: int):
	return level_best_time[level]
