class_name Achievement
extends Resource
## An achievement in SV Achievements.
##
## Resource that contains data about an achievement in SV Achievements. Create
## instances of this resource and configure using the exported variables.

## A unique string representing the achievement. This is used for certain functionality
## such as saving the list of unlocked achievements. Using the same name as another
## achievement may result in undefined behaviour. It is recommended to name this
## in hyphen-separated lowercase, for example "earn-1000-points" or "win-game-hardcore".
##
## Modders are advised to use longer strings with e.g. the mod name and/or author
## name to make ID clashes less likely. For example: "speedyvelcro-ultimate-overhaul-kill-30-enemies"
@export var achievement_id: String = ""

## Human-readable name of the achievement. This will be displayed in UIs.
@export var name: String = ""

## When this objective completes, the achievement will be unlocked.
@export var objective: AchievementObjective = AchievementObjective.new():
	set(value):
		_disconnect_objective()
		objective = value
		_connect_objective()
	get:
		return objective

## Human-readable description of how to achieve the achievement. This will be
## displayed in UIs.
@export_multiline var description: String = ""

## Human-readable desccription of the reward - if any - that will be unlocked
## when this achievement is unlocked. This will be displayed in UIs only if
## it is set to a non-empty string.
##
## Note that rewards need to be implemented yourself by hooking into the signals
## that emit when an achievement is unlocked.
@export var reward_description: String = ""

## Icon to display when unlocked (or greyed out when locked if the icon isn't
## secret). This will be displayed in UIs.
@export var icon: Texture2D

## If true, this achievement will not be shown at all in UIs if it hasn't been
## unlocked yet. Players will not even be shown that there is a secret
## achievement.
@export var invisible: bool = false

## If true, the name will not be shown in UIs if the achievement has not been
## unlocked yet, and a default secret name will be used instead.
##
## If [member invisible] is true, this property has no effect as the
## achievement will not be visible anyway.
@export var secret_name: bool = false

## If true, the description will not be shown in UIs if the achievement has not
## been unlocked yet, and a default secret description will be used instead.
##
## If [member invisible] is true, this property has no effect as the
## achievement will not be visible anyway.
@export var secret_description: bool = false

## If true and [member reward_description] is set, the reward text will not
## be displayed in UIs before this achievement unlocks. If there is no
## reward description, this property has no effect.
##
## If [member invisible] is true, this property has no effect as the
## achievement will not be visible anyway.
@export var secret_reward: bool = false

## If true, the icon will not be shown in UIs if the achievement has not been
## unlocked yet, and a default "locked" icon will be used instead.
##
## If [member invisible] is true, this property has no effect as the
## achievement will not be visible anyway.
@export var secret_icon: bool = false

## Set to true to indicate that this achievement should enumerate its [Objective](s)
## if displayed in a UI. If you set this to true, you should consider setting your
## objective descriptions, otherwise they will display the default (collections and
## indexed objectives have fairly helpful default text though)
@export var show_objectives: bool = false

## Set to true that this achievement should display a progress bar if displayed
## in a UI and its topmost objective is one that can be displayed as a bar
## ([IntProgressAchievementObjective], [FloatProgressAchievementObjective],
## [CollectionAchievementObjective], and [IndexedAchievementObjective]). This
## is separate from the visibility of individual objective progress bars, and
## indeed you can show the top-level objective's progress at both the achievement
## and the objective level (though it is recommended that you just go for the
## achievement level to avoid confusion)
@export var show_progress_bar: bool = true

@export_group("API Info")
## ID of the corresponding medal on Newgrounds.
@export var newgrounds_id: int = -1

## ID of the corresponding trophy on Game Jolt. Should be either a String or an int.
@export var game_jolt_id: Variant

## Extra field that you can use to store API info when using custom API adapters.
@export var custom_api_info: Variant


## If this is true, the player has completed the achievement. You may force-unlock
## the achievement by setting this to true, or using [method unlock]
var unlock_state: bool = false:
	set(value):
		var previous_value = unlock_state
		unlock_state = value
		if value and not previous_value:
			unlocked.emit()
	get:
		return unlock_state

## Emitted when the achievement is unlocked (i.e. completed)
signal unlocked
## If the top-level objective is capable of displaying progress, then this signal will
## emit whenever the progress is changed with the new value.
signal progress_changed(value: float)
## Emitted when the achievement is reset using [method reset_completion]
signal reset
## Emitted when sync is requested by calling [method sync]. Note that there are other
## times you will likely want to sync, e.g. when [signal unlocked] or [signal progress_changed]
## are called, so consumers should listen to those signals as well.
signal sync_requested


## Completes the achievement. Equivalent to setting [member unlock_state] to
## true.
func unlock() -> void:
	unlock_state = true

## Returns true if the achievement has been completed (unlocked). Equivalent
## to getting [member unlock_state].
func is_unlocked() -> bool:
	return unlock_state


## Resets the completion status of this achievement, and resets completion and
## progress of all its objectives.
func reset_completion() -> void:
	if objective != null:
		objective.reset_completion()
	unlock_state = false
	reset.emit()


## Returns the completion state of the achievement as a JSON-serializable
## dictionary.
func serialize_completion() -> Dictionary:
	var dict := {}
	
	dict["unlocked"] = unlock_state
	if objective != null:
		dict["objective"] = objective.serialize_completion()
	
	return dict


## Restores the completion status of the achievement from a dictionary in
## the format created by [method serialize_completion]
func deserialize_completion(dict: Dictionary):
	unlock_state = dict["unlocked"] \
			if dict.has("unlocked") and dict["unlocked"] is bool \
			else false
	
	if objective != null:
		objective.deserialize_completion(dict["objective"] \
				if dict.has("objective") and dict["objective"] is Dictionary \
				else {})


## Returns progress if the top-level objective can be expressed as progress.
## Otherwise returns 0.0.
func get_progress() -> float:
	if objective == null:
		return 0.0
	
	return objective.get_progress()


## Returns the progress required to complete the top-level objective (see
## [method get_progress]), provided that the top-level objective can be expressed
## as progress. Otherwise returns 0.0.
func get_progress_target() -> float:
	if objective == null:
		return 0.0
	
	return objective.get_progress_target()


## Returns true if [member show_progress_bar] is true and the top-level objecctive
## is one of the progress-bar-compatible types.
func should_show_progress_bar() -> bool:
	if objective == null:
		return false
	
	return show_progress_bar and objective.is_progress_type()


## Call to synchronize this achievement with the achievement API, provided that
## [ProjectSettings] is correctly configured to allow synchronisation. (Does
## nothing if sync is disabled)
##
## This is done by emitting a signal so if AchievementService doesn't "own" this
## achievement it will also do nothing.
func request_sync() -> void:
	sync_requested.emit()


func _connect_objective() -> void:
	if objective == null:
		return
	
	objective.completed.connect(_on_objective_completed)
	objective.progress_changed.connect(_on_objective_progress_changed)


func _disconnect_objective() -> void:
	if objective == null:
		return
	
	if objective.completed.is_connected(_on_objective_completed):
		objective.completed.disconnect(_on_objective_completed)
	
	if objective.progress_changed.is_connected(_on_objective_progress_changed):
		objective.progress_changed.disconnect(_on_objective_progress_changed)


# Signal connection
func _on_objective_completed() -> void:
	unlock()


# Signal connection
func _on_objective_progress_changed(value: float) -> void:
	progress_changed.emit(value)
