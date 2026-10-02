class_name CollectionAchievementObjective
extends AchievementObjective
## Collection of string-keyed objectives.
##
## An [AchievementObjective] that collates a collection of AchievementObjectives
## and completes when all of those objectives are complete. This is almost
## identical in behaviour to [IndexedAchievementObjective], however the collection
## is variant-keyed (although you will probably want to just use strings), allowing
## more human-friendly access to the underlying objectives.
##
## This might be useful, for example, for an achievement to complete multiple
## distinct areas in an open-world game, where they can be completed in any order.
## If you have a red area, a blue area, and a yellow area, you might key the
## objective collection with a String. And then to complete an objective, you
## could call e.g. [Achievement].objective.collection["red"].complete()
# TODO: signals for when count_complete changes

## Variant-keyed collection of objectives. Assign this at creation. Do not add
## or remove objectives at runtime as this will mess up the internal signalling.
## It is recommended you key this with meaningful strings for ease-of-use.
@export var collection: Dictionary[Variant, AchievementObjective]:
	set(value):
		_disconnect_children()
		collection = value
		_connect_children()
	get:
		return collection

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
	if collection == null:
		return 0
	
	return collection.size()


## Returns the number of completed objectives in the collection
func count_complete() -> int:
	if collection == null:
		return 0
	
	return collection.values().filter(func (o: AchievementObjective) -> bool: return o.completion_state).size()


# Override
func serialize_completion() -> Dictionary:
	var dict := super()
	
	dict["subobjectives"] = {}
	for key in collection.keys():
		dict["subobjectives"][key] = collection[key].serialize_completion()
	
	return dict


# Override
func deserialize_completion(dict: Dictionary) -> void:
	var collection_dict: Dictionary = dict["subobjectives"] \
			if dict.has("subobjectives") and dict["subobjectives"] is Dictionary \
			else {}
	
	for key in collection.keys():
		collection[key].deserialize_completion(collection_dict[key] \
				if collection_dict.has(key) and collection_dict[key] is Dictionary \
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
	return collection.values()


# Override
func is_progress_type() -> bool:
	return true


func _connect_children() -> void:
	for objective: AchievementObjective in collection.values():
		objective.completed.connect(_on_child_objective_completed)


func _disconnect_children() -> void:
	if collection == null:
		return
	
	for objective: AchievementObjective in collection.values():
		if objective.completed.is_connected(_on_child_objective_completed):
			objective.completed.connect(_on_child_objective_completed)


# Signal connection
func _on_child_objective_completed() -> void:
	progress_changed.emit(float(count_complete()))
	
	if collection.values().all(func (o: AchievementObjective) -> bool: return o.completion_state):
		complete()
