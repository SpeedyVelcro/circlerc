class_name AchievementObjective
extends Resource
## Base class for achievement objectives.
##
## Domain object that represents an achievement objective. This base class,
## when used on its own, is a simple boolean flag.

## Human-readable description of the objective
@export var description: String = ""

## True if the objective has been completed. When this is set to true, it will
## emit [signal completed]
var completion_state: bool = false:
	set(value):
		var previous_value = _completion_state_internal
		_completion_state_internal = value
		if value and not previous_value:
			completed.emit()
	get:
		return _completion_state_internal

var _completion_state_internal: bool = false

## Emitted when the objective is completed.
signal completed
## Emitted when the objective is reset using [method reset_completion]
signal reset

## If the objective is capable of displaying progress, then this signal will
## emit whenever the progress is changed with the new value.
signal progress_changed(value: float)


## Complete the objective. This is equivalent to setting [member completion_state]
## to true.
func complete():
	completion_state = true


## Returns true if this objective's progress to completion can be represented
## as a progress bar, and is configured such that a progress bar should show
## when displayed in the UI.
func should_show_progress_bar() -> bool:
	return false


## Returns true if this objective is of a type that can be expressed as a progress
## bar, regardless of whether it is configured to do so.
func is_progress_type() -> bool:
	return false


## Returns true if this achievement objective is capable of having children
## and is configured such that they should show when displayed in the UI.
func should_show_children() -> bool:
	return false


## Gets the progress to completion for display in a [ProgressBar], provided that
## this objective can be represented as a progress bar. If not, it will return
## a default value of 0.0.
func get_progress() -> float:
	return 0.0


## Gets the value that [method get_progress] is out of. If this objective does
## not support progress, it just returns 0.0.
func get_progress_target() -> float:
	return 0.0


## Returns the subobjectives under this objective. If the objective does not
## support subobjectives, it returns an empty array by default.
func get_children() -> Array[AchievementObjective]:
	return []


## Returns a JSON-serializable [Dictionary] that contains the completion status
## and progress towards completion of this objective.
func serialize_completion() -> Dictionary:
	return {
		"complete": completion_state
	}


## Configures the progress and completion of this achievement objective
## according to a [Dictionary] in the format returned by [method serialize_completion]
func deserialize_completion(dict: Dictionary) -> void:
	_completion_state_internal = bool(dict["complete"]) \
			if dict.has("complete") and dict["complete"] is bool \
			else false


## Returns a human-readable description of the objective. Unlike reading
## [member description] directly, this falls back on default text if the
## description text is empty.
func get_description_with_fallback() -> String:
	return description if not description.is_empty() else _get_default_objective_description()


## Resets the completion status of this objective and any sub-objectives.
func reset_completion() -> void:
	for objective in get_children():
		objective.reset_completion()
	completion_state = false
	reset.emit()


## Override this to change the default objective descriptionreturned as a fallback
## by [method get_description_with_fallback]
func _get_default_objective_description() -> String:
	return "Complete the following:" if should_show_children() else "Complete an objective."
