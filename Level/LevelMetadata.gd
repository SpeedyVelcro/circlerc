class_name LevelMetadata
extends Resource

@export_file("*.scn", "*.tscn") var scene_path: String = ""
@export_multiline var caption: String = ""
@export var par: TimeScore:
	set(value):
		par = value
	get:
		return par if par != null else TimeScore.NONE


func is_time_under_par(time: TimeScore) -> bool:
	if par.is_none():
		return false # You are not under par if there is no par.
	
	return time.get_total_milliseconds() <= par.get_total_milliseconds()
