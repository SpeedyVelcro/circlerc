class_name IndexedAchievementObjective
extends AchievementObjective
## Objective containing an array of child objectives.
##
## An [AchievementObjective] that collates a number of child AchievementObjectives
## that can be accessed by index. The objective is completed when all child
## objectives have been completed.
# TODO: signals for when count_complete changes

## Array of objectives for this objective to contain. Assign this at creation. Do not add
## or remove objectives at runtime as this will mess up the internal signalling.
@export var objectives: Array[AchievementObjective]:
	set(value):
		_disconnect_children()
		objectives = value
		_connect_children()
	get:
		return objectives

## Set to true to indicate that this objective should show a progress bar
## when displayed in a UI. The default is false because typically this kind of
## objective is displayed in a tree-format that enumerates all of its children
## individually, which is good enough.
@export var show_progress_bar: bool = false

## Set to true to indicate that a UI displaying this objective should also enumerate
## and display its children. If you set this to false, you may want to set
## [member show_progress_bar] to true to give a rough indication of progress.
@export var show_children: bool = true


## Returns the number of objectives in the collection
func count() -> int:
	if objectives == null:
		return 0
	
	return objectives.size()


## Returns the number of completed objectives in the collection
func count_complete() -> int:
	if objectives == null:
		return 0
	
	return objectives.filter(func (o: AchievementObjective) -> bool: return o.completion_state).size()


# Override
func serialize_completion() -> Dictionary:
	var dict := super()
	dict["subobjectives"] = objectives.map(func (objective: AchievementObjective) -> Dictionary: return objective.serialize_completion())
	return dict


# Override
func deserialize_completion(dict: Dictionary) -> void:
	var array: Array = dict["subobjectives"] \
			if dict.has("subobjectives") and dict["subobjectives"] is Array \
			else []
	
	for i in range(objectives.size()):
		objectives[i].deserialize_completion(array[i] \
				if i < array.size() and array[i] is Dictionary \
				else {})
	
	super(dict)


# Override
func should_show_children() -> bool:
	return show_children


# Override
func should_show_progress_bar() -> bool:
	return show_progress_bar


# Override
func get_progress() -> float:
	return float(count_complete())


# Override
func get_progress_target() -> float:
	return float(count())


# Override
func get_children() -> Array[AchievementObjective]:
	return objectives


# Override
func is_progress_type() -> bool:
	return true


func _connect_children() -> void:
	for objective: AchievementObjective in objectives:
		objective.completed.connect(_on_child_objective_completed)


func _disconnect_children() -> void:
	if objectives == null:
		return
	
	for objective: AchievementObjective in objectives:
		if objective.completed.is_connected(_on_child_objective_completed):
			objective.completed.connect(_on_child_objective_completed)


# Signal connection
func _on_child_objective_completed() -> void:
	progress_changed.emit(float(count_complete()))
	
	if objectives.all(func (o: AchievementObjective) -> bool: return o.completion_state):
		complete()
