## List of levels and associated metadata
##
## Carries an [Array], [member levels], of [LevelMetadata] resources.
class_name LevelList
extends Resource

@export var levels: Array[LevelMetadata] = []


func has_level(number: int) -> bool:
	if number > levels.size():
		return false
	
	if number <= 0:
		return false
	
	return true


func get_level(number: int) -> LevelMetadata:
	if not has_level(number):
		push_error("No level %d" % number)
		return null
	
	return levels[number - 1]


func load_level(number: int) -> PackedScene:
	if not has_level(number):
		push_error("No level %d" % number)
		return null
	
	var path := get_level_scene_path(number)
	var level = load(path)
	
	if level is not PackedScene:
		push_error("Loading level at path %s did not return a PackedScene" % path)
		return null
	
	return level


func get_level_scene_path(number: int) -> String:
	if not has_level(number):
		push_error("No level %d" % number)
		return ""
	
	return get_level(number).scene_path


func get_level_caption(number: int) -> String:
	if not has_level(number):
		push_error("No level %d" % number)
		return "Level caption not found"
	
	return get_level(number).caption


func get_level_par_time(number: int) -> TimeScore:
	if not has_level(number):
		push_error("No level %d" % number)
		return TimeScore.NONE
	
	return get_level(number).par


func get_number_of_levels():
	return levels.size()


## Gets the level number that corresponds to the given scene path, if it has
## one (otherwise errors and returns -1).
func scene_path_to_number(scene_path: String) -> int:
	var scene_uid := ResourceUID.path_to_uid(scene_path)
	
	for i in range(levels.size()):
		var level := levels[i]
		if scene_uid == ResourceUID.path_to_uid(level.scene_path):
			return i + 1
	
	push_error("Scene path %s is not associated to a level number." % scene_path)
	return -1


func scene_root_node_to_number(root_node: Node) -> int:
	return scene_path_to_number(root_node.scene_file_path)
