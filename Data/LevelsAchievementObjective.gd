class_name LevelsAchievementObjective
extends IndexedAchievementObjective
## An [IndexedAchievementObjective] with one sub-objective per level.
##
## Configure this resources export variables to determine which levels
## get sub-objectives, and what the descriptions should read. Objectives
## are appended to the [member objectives] list on initialization.

## When [code]true[/code], this objective will have one subobjective per level
## for all levels. If [code]false[/code], use [member starting_level] and
## [member number_of_levels] instead.
##
## Has no effect after initialization.
@export var all_levels: bool = true

## The [LevelList] to use as the authoritative source for the number of levels if
## [member all_levels] is set to [code]true[/code].
@export var based_on_level_list: LevelList = preload("res://Level/LevelList.tres")

## Level to start enumerating objectives from when [member all_levels] is [code]false[/code].
## This is 1-based (starts counting from 1 rather than 0).
##
## Has no effect after initialization.
@export var starting_level: int = 1

## Number of levels to include objectives for, starting from [member starting_level].
## Only used if [member all_levels] is [code]false[/code].
##
## Has no effect after initialization.
@export var number_of_levels: int = 0

## Format string used for auto-filling descriptions. Used [code]"%d"[/code] to
## substitute the level number.
##
## Has no effect after initialization.
@export var description_format_string: String = "Level %d":
	set(value):
		description_format_string = value
		# Last exported property so now set the objectives value again to generate
		# the objectives
		# TODO: This should be replaced with listening to NOTIFICATION_RESOURCE_DESERIALIZED
		# one it is merged: https://github.com/godotengine/godot/pull/109752
		_exports_have_been_set = true
		objectives = objectives

var _exports_have_been_set := false


# Override
func _append_generated_objectives() -> void:
	if not _exports_have_been_set:
		return
	
	var _starting_level: int = 1 if all_levels else starting_level
	var _number_of_levels: int = based_on_level_list.get_number_of_levels() if all_levels else starting_level
	
	for n in range(_starting_level, _number_of_levels + 1):
		var objective = AchievementObjective.new()
		objective.description = description_format_string % n
		objectives.append(objective)
