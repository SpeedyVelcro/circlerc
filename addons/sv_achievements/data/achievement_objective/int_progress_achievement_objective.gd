class_name IntProgressAchievementObjective
extends AchievementObjective
## Objective to meet an integer target
##
## This [AchievementObjective] completes when an int [member target] is reached.

## Current progress to the objective. Setting this to a value greater than
## or equal to [member target] will complete the objective.
var progress: int = 0:
	set(value):
		_progress_internal = value
		progress_changed.emit(value)
		if value >= target:
			complete()
	get:
		return _progress_internal

## Target to complete the objective. When [member progress] reaches this value,
## the objective will complete.
@export var target: int = 0

## Set to true to indicate that this objective should show a progress bar
## when displayed in a UI.
@export var show_progress_bar: bool = true


var _progress_internal: int = 0


## Increases the progress by 1 but only if the target hasn't been hit yet.
## Just a convenience function - equivalent to checking and incrementing
## [member progress] manually.
func increment() -> void:
	if progress < target:
		progress += 1


## Increases [member progress] to the given value. If you enter a value less
## than the current progress, this method does nothing. The value is also
## capped at the target.
func increase_to(value: int) -> void:
	if value < progress:
		return
	
	progress = min(value, target)


# Override
func serialize_completion() -> Dictionary:
	var dict := super()
	dict["progress"] = progress
	return dict


# Override
func deserialize_completion(dict: Dictionary) -> void:
	_progress_internal = int(dict["progress"]) \
			if dict.has("progress") and (dict["progress"] is int or dict["progress"] is float) \
			else 0
	
	super(dict)


# Override
func reset_completion() -> void:
	progress = 0
	super()


# Override
func should_show_progress_bar() -> bool:
	return show_progress_bar


# Override
func get_progress() -> float:
	return float(progress)


# Override
func get_progress_target() -> float:
	return float(target)


# Override
func is_progress_type() -> bool:
	return true
