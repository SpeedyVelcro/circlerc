extends MarginContainer
## UI for displaying a single achievement.
##
## This UI displays a single [Achievement] from SV Achievements. It adapts to
## the achievement's configuration, displaying e.g. a progress bar
## or sub-achievements. The UI updates according to changes in the achievement's
## unlock status and the completion status of its objectives.

## Achievement to display. Required.
@export var achievement: Achievement:
	set(value):
		_disconnect_achievement_signals()
		achievement = value
		_display_achievement()
		_connect_achievement_signals()
	get:
		return achievement

## Override for the [LabelSettings] on the achievement name label. If this is
## not set, the name label will show with a defualt label settings with 24px
## font.
@export var name_label_settings_override: LabelSettings:
	set(value):
		name_label_settings_override = value
		_update_name_label_settings()
	get:
		return name_label_settings_override

## Minimum size for the sync button.
@export var sync_button_minimum_size: Vector2 = Vector2(80, 0):
	set(value):
		sync_button_minimum_size = value
		_update_sync_button_minimum_size()
	get:
		return sync_button_minimum_size

## Margin size to display around the achievement.
@export var margin_size_override: int = 16:
	set(value):
		margin_size_override = value
		remove_theme_constant_override("margin_bottom")
		remove_theme_constant_override("margin_left")
		remove_theme_constant_override("margin_right")
		remove_theme_constant_override("margin_top")
		add_theme_constant_override("margin_bottom", value)
		add_theme_constant_override("margin_left", value)
		add_theme_constant_override("margin_right", value)
		add_theme_constant_override("margin_top", value)
	get:
		return margin_size_override

## [StyleBox] displayed over the achievement UI when focused. If this is not set,
## falls back on the [code]"focus"[/code] stylebox for [Button] set for the
## current theme.
@export var focus_stylebox_override: StyleBox = null

@export_category("Icon")
## Set to true to display the icon. [member default_achievement_icon] and/or
## [member Achievement.icon] should be set if this is true.
@export var show_icon: bool = true:
	set(value):
		show_icon = value
		_update_icon()
	get:
		return show_icon

## If set to a non-zero vector, achievement icons will be displayed at this
## size rather than their image's dimensions.
@export var icon_size_override: Vector2 = Vector2(0, 0):
	set(value):
		icon_size_override = value
		_update_icon_size_override()
	get:
		return icon_size_override

## When true and this achievement is locked, a grayscale filter will be applied
## to the icon.
@export var grayscale_icon_when_locked: bool = true:
	set(value):
		grayscale_icon_when_locked = value
		_update_icon()
	get:
		return grayscale_icon_when_locked

## Shader material to use instead of the default when achievement is locked
## and [member grayscale_icon_when_locked] is true. You can use this to apply
## a grayscale shader with different channel weights. If you so choose, you may
## also set this to use a completely different type of shader when achievements
## are locked.
@export var grayscale_shader_override: ShaderMaterial:
	set(value):
		grayscale_shader_override = value
		_update_icon()
	get:
		return grayscale_shader_override

## If true, a border will be displayed around the icon. This border is a panel
## that displays above the icon with custom theming to show a white border around
## (not overlapping) its dimensions. To override this behaviour set a custom
## [StyleBox] with [member icon_border_stylebox_override].
@export var show_icon_border: bool = true:
	set(value):
		show_icon_border = value
		_update_icon()
	get:
		return show_icon_border

## Stylebox used to display a border around the achievement icon. Set this to
## replace the default icon border (by default a white border). See
## [member show_icon_border].
@export var icon_border_stylebox_override: StyleBox:
	set(value):
		icon_border_stylebox_override = value
		_update_icon()
	get:
		return icon_border_stylebox_override

## Default achievement icon to display if the [member Achievement.icon] is not
## set. Leaving this unset may result in undefined behaviour. Set [member display_icon]
## to false instead if you want to hide the icon.
@export var default_achievement_icon: Texture2D:
	set(value):
		default_achievement_icon = value
		_update_icon()
	get:
		return default_achievement_icon

## Icon to display instead of [member Achievement.icon] if the achievement
## hasn't been unlocked. If this is left unset, then the achievement icon will
## still be displayed when locked.
@export var locked_achievement_icon: Texture2D:
	set(value):
		locked_achievement_icon = value
		_update_icon()
	get:
		return locked_achievement_icon

## Icon to display when achievement's icon is secret. If this is not set, then
## [member default_achievement_icon] will be used instead.
@export var secret_achievement_icon: Texture2D:
	set(value):
		secret_achievement_icon = value
		_update_icon()
	get:
		return secret_achievement_icon

@export_category("Details")
## Text to display in place of the achievement name when [member Achievement.secret_name]
## is true.
@export var secret_name: String = "Hidden Achievement":
	set(value):
		secret_name = value
		_update_details()
	get:
		return secret_name

## Text to display in place of the achievement description when
## [member Achievement.secret_description] is true.
@export var secret_description: String = "Unlock this achievement to find out more.":
	set(value):
		secret_description = value
		_update_details()
	get:
		return secret_description

@export_category("Reward")
## Set to true to bold the text "Reward:" that displays before the reward
## description.
@export var bold_reward_title: bool:
	set(value):
		bold_reward_title = value
		_update_reward()
	get:
		return bold_reward_title

## This text will be displayed if the achievement has an award but [member Achievement.secret_reward]
## is set to true.
@export var secret_reward_description: String = "???":
	set(value):
		secret_reward_description = value
		_update_reward()
	get:
		return secret_reward_description

@export_category("Objectives")
## If this is true and the achievement has [member Achievement.show_objectives]
## set to true, then objectives will be shown in a collapsible list.
@export var show_objective_list: bool = true:
	set(value):
		show_objective_list = value
		_update_objective_list()
	get:
		return show_objective_list

## Icon to display in the objective list when objectives are incomplete. It is
## recommended you use a [DPITexture].
@export var objective_incomplete_icon: Texture2D:
	set(value):
		objective_incomplete_icon = value
		_update_objective_list()
	get:
		return objective_incomplete_icon

## Icon to display in the objective list when objectives are completed. It is
## recommended you use a [DPITexture].
@export var objective_complete_icon: Texture2D:
	set(value):
		objective_complete_icon = value
		_update_objective_list()
	get:
		return objective_complete_icon

## Size of a single level of indentation in the objective list in pixels.
@export var objective_list_indent_size: float = 24.0:
	set(value):
		objective_list_indent_size = value
		_update_objective_list()
	get:
		return objective_list_indent_size

@onready var _icon_texture_rect: TextureRect = $VBoxContainer/HBoxContainer/VBoxContainer/IconTextureRect
@onready var _icon_spacer: Control = $VBoxContainer/IconSpacerReferenceRect
@onready var _icon_border_panel: Panel = $VBoxContainer/HBoxContainer/VBoxContainer/IconTextureRect/IconBorderPanel
@onready var _name_label: Label = $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/NameLabel
@onready var _description_label: Label = $VBoxContainer/HBoxContainer/VBoxContainer2/DescriptionLabel
@onready var _sync_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/SyncButton
@onready var _reward_container: Control = $VBoxContainer/HBoxContainer/VBoxContainer2/RewardContainer
@onready var _reward_title_label: RichTextLabel = $VBoxContainer/HBoxContainer/VBoxContainer2/RewardContainer/RewardTitleLabel
@onready var _reward_label: Label = $VBoxContainer/HBoxContainer/VBoxContainer2/RewardContainer/RewardLabel
@onready var _progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var _progress_label: Label = $VBoxContainer/ProgressBar/ProgressLabel
@onready var _objective_container: Control = $VBoxContainer/ObjectiveFoldableContainer
@onready var _objective_list_ui: Control = $VBoxContainer/ObjectiveFoldableContainer/ObjectiveListUI

var _default_name_label_settings: LabelSettings
var _default_icon_border_stylebox: StyleBox = preload("res://addons/sv_achievements/ui/theming/icon_border/icon_border_white.tres")
var _default_grayscale_shader: ShaderMaterial = preload("res://addons/sv_achievements/shader/grayscale_itu_shader_material.tres")

# Override
func _ready() -> void:
	_default_name_label_settings = _name_label.label_settings
	
	_update_name_label_settings()
	_update_icon_size_override()
	_update_sync_button_minimum_size()
	
	_display_achievement()
	_connect_singleton_signals()


# Override
func _draw() -> void:
	const IGNORE_HIDDEN_FOCUS := true
	if has_focus(IGNORE_HIDDEN_FOCUS):
		draw_style_box(
			focus_stylebox_override if focus_stylebox_override else get_theme_stylebox("focus", "Button"),
			Rect2(Vector2.ZERO, size))


func _display_achievement() -> void:
	if achievement == null:
		# Only need the one error so it's displayed here on achievement set, instead of
		# every time any other property is changed.
		push_error("AchievementUI does not have an achievement set.")
		return
	
	_update_icon()
	_update_details()
	_update_reward()
	_update_progress()
	_update_objective_list()
	_update_sync_button()


func _update_name_label_settings() -> void:
	if _name_label == null:
		return # Not ready yet
	
	if name_label_settings_override != null:
		_name_label.label_settings = name_label_settings_override
	else:
		_name_label.label_settings = _default_name_label_settings


func _update_sync_button_minimum_size() -> void:
	if _sync_button == null:
		return # Not ready yet
	
	_sync_button.custom_minimum_size = sync_button_minimum_size


func _update_icon() -> void:
	if _icon_texture_rect == null or achievement == null:
		return # Not until ready
	
	if not show_icon:
		_icon_texture_rect.visible = false
		return
	
	_icon_texture_rect.visible = true
	
	if achievement.is_unlocked():
		_icon_texture_rect.texture = achievement.icon if achievement.icon != null else default_achievement_icon
		_icon_texture_rect.material = null
	else:
		if grayscale_icon_when_locked:
			_icon_texture_rect.material = grayscale_shader_override if grayscale_shader_override != null else _default_grayscale_shader
		else:
			_icon_texture_rect.material = null
		if achievement.secret_icon:
			_icon_texture_rect.texture = secret_achievement_icon if secret_achievement_icon != null else default_achievement_icon
		else:
			_icon_texture_rect.texture = locked_achievement_icon \
				if locked_achievement_icon != null \
				else achievement.icon \
					if achievement.icon != null \
					else default_achievement_icon
	
	if not show_icon_border:
		_icon_border_panel.visible = false
		return
	
	_icon_border_panel.visible = true
	
	_icon_border_panel.add_theme_stylebox_override("panel", icon_border_stylebox_override if icon_border_stylebox_override != null else _default_icon_border_stylebox)


func _update_icon_size_override() -> void:
	if _icon_texture_rect == null:
		return # Not until ready
	
	if icon_size_override == Vector2.ZERO:
		_icon_texture_rect.custom_minimum_size = Vector2.ZERO
		_icon_texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	else:
		_icon_texture_rect.custom_minimum_size = icon_size_override
		_icon_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE


func _update_details() -> void:
	if _name_label == null or _description_label == null or achievement == null:
		return # Not until ready
	
	if achievement.is_unlocked():
		_name_label.text = achievement.name
		_description_label.text = achievement.description
	else:
		_name_label.text = secret_name if achievement.secret_name else achievement.name
		_description_label.text = secret_description if achievement.secret_description else achievement.description


func _update_reward() -> void:
	if _reward_container == null or _reward_label == null or _reward_title_label == null or achievement == null:
		return # Not until ready
	
	if achievement.reward_description.is_empty():
		_reward_container.visible = false
		return
	
	_reward_container.visible = true
	
	_reward_title_label.text = "[b]Reward:[/b]" if bold_reward_title else "Reward:"
	
	if achievement.is_unlocked():
		_reward_label.text = achievement.reward_description
	else:
		_reward_label.text = secret_reward_description if achievement.secret_reward else achievement.reward_description


func _format_float(value: float) -> String:
	var new_string := str(value)
	if not new_string.contains("."):
		return new_string
	while new_string.ends_with("0"):
		new_string = new_string.trim_suffix("0")
	new_string = new_string.trim_suffix(".")
	return new_string


func _update_progress() -> void:
	if _progress_bar == null or _progress_label == null or achievement == null:
		return # Not ready yet
	
	if not achievement.should_show_progress_bar():
		_progress_bar.visible = false
		_update_icon_spacer()
		return
	
	_progress_bar.visible = true
	
	var progress := achievement.get_progress()
	var target := achievement.get_progress_target()
	
	_progress_bar.value = progress
	_progress_bar.max_value = target
	
	_progress_label.text = "%s/%s" % [_format_float(progress), _format_float(target)]
	
	_update_icon_spacer()


func _update_objective_list() -> void:
	if _objective_container == null or _objective_list_ui == null or achievement == null:
		return # Not ready yet
	
	if not achievement.show_objectives or achievement.show_objectives == null:
		_objective_container.visible = false
		_update_icon_spacer()
		return
	
	_objective_container.visible = true
	_objective_list_ui.objective = achievement.objective
	_objective_list_ui.incomplete_icon = objective_incomplete_icon
	_objective_list_ui.complete_icon = objective_complete_icon
	_objective_list_ui.indent_size = objective_list_indent_size
	
	_update_icon_spacer()


func _update_icon_spacer() -> void:
	if _icon_spacer == null:
		return
	
	# If either of these are visible, they will show too close to the icon (and
	# also the description actually, so maybe this func is a bit of a misnomer).
	# But we also don't want to add un-necessary space between achievements if
	# they're not visible, hence setting this conditionally.
	_icon_spacer.visible = _progress_bar.visible or _objective_container.visible


func _update_sync_button() -> void:
	if _sync_button == null:
		return
	
	if AchievementService.sync_enabled:
		_sync_button.disabled = not (achievement.is_unlocked() or AchievementService.locked_sync_allowed)
	else:
		_sync_button.disabled = true


func _connect_singleton_signals() -> void:
	if not AchievementService.sync_enabled_changed.is_connected(_on_singleton_sync_enabled_changed):
		AchievementService.sync_enabled_changed.connect(_on_singleton_sync_enabled_changed)
	
	if not AchievementService.locked_sync_allowed_changed.is_connected(_on_singleton_locked_sync_allowed_changed):
		AchievementService.locked_sync_allowed_changed.connect(_on_singleton_locked_sync_allowed_changed)


func _disconnect_singleton_signals() -> void:
	if AchievementService.sync_enabled_changed.is_connected(_on_singleton_sync_enabled_changed):
		AchievementService.sync_enabled_changed.disconnect(_on_singleton_sync_enabled_changed)
	
	if AchievementService.locked_sync_allowed_changed.is_connected(_on_singleton_locked_sync_allowed_changed):
		AchievementService.locked_sync_allowed_changed.disconnect(_on_singleton_locked_sync_allowed_changed)


func _connect_achievement_signals() -> void:
	if achievement == null:
		return
	
	if not achievement.unlocked.is_connected(_on_achievement_unlocked):
		achievement.unlocked.connect(_on_achievement_unlocked)
	
	if not achievement.progress_changed.is_connected(_on_achievement_progress_changed):
		achievement.progress_changed.connect(_on_achievement_progress_changed)
	
	if not achievement.reset.is_connected(_on_achievement_reset):
		achievement.reset.connect(_on_achievement_reset)


func _disconnect_achievement_signals() -> void:
	if achievement == null:
		return
	
	if achievement.unlocked.is_connected(_on_achievement_unlocked):
		achievement.unlocked.disconnect(_on_achievement_unlocked)
	
	if achievement.progress_changed.is_connected(_on_achievement_progress_changed):
		achievement.progress_changed.disconnect(_on_achievement_progress_changed)
	
	if achievement.reset.is_connected(_on_achievement_reset):
		achievement.reset.disconnect(_on_achievement_reset)


# Signal connection
func _on_achievement_unlocked() -> void:
	_update_icon()
	_update_details()
	_update_reward()
	_update_sync_button()


# Signal connection
func _on_achievement_progress_changed(_value: float) -> void:
	_update_progress()


# Signal connection
func _on_achievement_reset() -> void:
	_update_icon()
	_update_details()
	_update_reward()
	_update_progress()
	_update_sync_button()


# Signal connection
func _on_sync_button_pressed() -> void:
	achievement.request_sync()


# Signal connection
func _on_singleton_sync_enabled_changed(new_value: bool) -> void:
	_update_sync_button()


func _on_singleton_locked_sync_allowed_changed(new_value: bool) -> void:
	_update_sync_button()


# Override
func _exit_tree() -> void:
	_disconnect_singleton_signals()
	_disconnect_achievement_signals()
