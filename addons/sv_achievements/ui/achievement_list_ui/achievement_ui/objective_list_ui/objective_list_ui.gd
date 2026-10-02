extends VBoxContainer
## Objective list UI for SV Achievements.
##
## Displays the given [AchievementObjective] and any children (if the objective
## is appropriately configured) in a hierarchical (via indentation) list.

## Top-level [AchievementObjective] to display
@export var objective: AchievementObjective:
	set(value):
		objective = value
		_clear_list()
		_populate_list()
	get():
		return objective

## Icon to display when objectives are incomplete. It is recommended you use a
## [DPITexture].
@export var incomplete_icon: Texture2D:
	set(value):
		if value == incomplete_icon:
			return
		incomplete_icon = value
		_update_completion_icons()
	get:
		return incomplete_icon

## Icon to display when the objectives are completed. It is recommended you use a
## [DPITexture].
@export var complete_icon: Texture2D:
	set(value):
		if value == complete_icon:
			return
		complete_icon = value
		_update_completion_icons()
	get:
		return complete_icon

## Size of a single level of indentation in pixels.
@export var indent_size: float = 24.0:
	set(value):
		if value == indent_size:
			return
		indent_size = value
		_update_indents()
	get:
		return indent_size

var _objective_ui_controls: Array[Control] = []

var _objective_ui_scene := preload("res://addons/sv_achievements/ui/achievement_list_ui/achievement_ui/objective_list_ui/objective_ui/objective_ui.tscn")


# Override
func _ready() -> void:
	_populate_list()


func _populate_list() -> void:
	if objective == null:
		return
	
	_add_objective(objective)


func _add_objective(to_add: AchievementObjective, indent_level: int = 0) -> void:
	var scene := _objective_ui_scene.instantiate()
	scene.objective = to_add
	scene.complete_icon = complete_icon
	scene.incomplete_icon = incomplete_icon
	scene.indent_level = indent_level
	scene.indent_size = indent_size
	add_child(scene)
	_objective_ui_controls.append(scene)
	
	var children := to_add.get_children()
	for child in children:
		# Will terminate as long as there are no cyclic dependencies (unlikely,
		# as I'm pretty sure you can't load a resource with cyclic dependencies)
		_add_objective(child, indent_level + 1)


func _update_indents() -> void:
	for control in _objective_ui_controls:
		control.indent_size = indent_size


func _update_completion_icons() -> void:
	for control in _objective_ui_controls:
		control.complete_icon = complete_icon
		control.incomplete_icon = incomplete_icon


func _clear_list() -> void:
	for control in _objective_ui_controls:
		remove_child(control)
	_objective_ui_controls = []
