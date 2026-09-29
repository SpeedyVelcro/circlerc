class_name LevelMetadata
extends Resource

@export_file("*.scn", "*.tscn") var scene_path: String = ""
@export_multiline var caption: String = ""
@export var par: TimeScore:
	set(value):
		par = value
	get:
		return par if par != null else TimeScore.NONE
