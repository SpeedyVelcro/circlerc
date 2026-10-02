extends HBoxContainer
## Achievement Objective UI
##
## UI that displays information - including completion status - about a single
## [AchievementObjective] from SV Achievements.

## The [AchievementObjective] to display.
@export var objective: AchievementObjective:
	set(value):
		if value == objective:
			return
		_disconnect_signals()
		objective = value
		_display_objective()
		_connect_signals()
	get:
		return objective

## Icon to display when the objective is incomplete. It is recommended you use a
## [DPITexture].
@export var incomplete_icon: Texture2D:
	set(value):
		if value == incomplete_icon:
			return
		incomplete_icon = value
		_update_completion_icon()
	get:
		return incomplete_icon

## Icon to display when the objective is completed. It is recommended you use a
## [DPITexture].
@export var complete_icon: Texture2D:
	set(value):
		if value == complete_icon:
			return
		complete_icon = value
		_update_completion_icon()
	get:
		return complete_icon

## How many levels indented the objective should be shown
@export var indent_level: int = 0:
	set(value):
		if value == indent_level:
			return
		indent_level = value
		_update_indent()
	get:
		return indent_level

## Size of each indent level in pixels, used when [member indent_level] >= 1
@export var indent_size: float = 24.0:
	set(value):
		if value == indent_size:
			return
		indent_size = value
		_update_indent()
	get:
		return indent_size

@onready var _indent_control: Control = $IndentReferenceRect
@onready var _completion_icon_texture_rect: TextureRect = $CompletionIconTextureRect
@onready var _description_label: Label = $DescriptionLabel
@onready var _progress_bar: ProgressBar = $ProgressBar
@onready var _progress_bar_label: Label = $ProgressBar/ProgressBarLabel


# Override
func _ready() -> void:
	_display_objective()
	_update_indent()


# Override
func _exit_tree() -> void:
	_disconnect_signals()


func _display_objective() -> void:
	if objective == null:
		push_error("Objective UI does not have an AchievementObjective set.")
		return
	
	_update_completion_icon()
	_update_description()
	_update_progress()


func _update_completion_icon() -> void:
	if objective == null or _completion_icon_texture_rect == null:
		return
	
	if objective.completion_state:
		_completion_icon_texture_rect.texture = complete_icon
	else:
		_completion_icon_texture_rect.texture = incomplete_icon


func _update_description() -> void:
	if objective == null or _description_label == null:
		return
	
	_description_label.text = objective.get_description_with_fallback()


func _format_float(value: float) -> String:
	var new_string := str(value)
	if not new_string.contains("."):
		return new_string
	while new_string.ends_with("0"):
		new_string = new_string.trim_suffix("0")
	new_string = new_string.trim_suffix(".")
	return new_string


func _update_progress() -> void:
	if objective == null:
		return
	
	if _progress_bar != null:
		_progress_bar.visible = objective.should_show_progress_bar()
		_progress_bar.value = objective.get_progress()
		_progress_bar.max_value = objective.get_progress_target()
	
	if _progress_bar_label != null:
		var progress_string := _format_float(objective.get_progress())
		var target_string := _format_float(objective.get_progress_target())
		_progress_bar_label.text = "%s/%s" % [progress_string, target_string]


func _update_indent() -> void:
	if _indent_control == null:
		return # Will be re-run on ready anyway
	
	if indent_level <= 0 or indent_size <= 0.0:
		_indent_control.visible = false
		return
	
	_indent_control.visible = true
	_indent_control.custom_minimum_size.x = indent_size * float(indent_level)


func _connect_signals() -> void:
	objective.completed.connect(_on_objective_completed)
	objective.progress_changed.connect(_on_objective_progress_changed)
	objective.reset.connect(_on_objective_reset)

func _disconnect_signals() -> void:
	if objective == null:
		return
	
	if objective.completed.is_connected(_on_objective_completed):
		objective.completed.disconnect(_on_objective_completed)
	
	if objective.progress_changed.is_connected(_on_objective_progress_changed):
		objective.progress_changed.disconnect(_on_objective_progress_changed)
	
	if objective.reset.is_connected(_on_objective_reset):
		objective.reset.disconnect(_on_objective_reset)


# Signal connection
func _on_objective_completed() -> void:
	_update_completion_icon()


# Signal connection
func _on_objective_progress_changed(_value: float) -> void:
	_update_progress()


# Signal connection
func _on_objective_reset() -> void:
	_update_completion_icon()
	_update_progress()
