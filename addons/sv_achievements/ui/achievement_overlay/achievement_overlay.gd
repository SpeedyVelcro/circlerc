extends MarginContainer
## UI scene that automatically displays achievement popups
##
## When this scene is placed anywhere in your game where it will appear over
## everything else, it will automatically listen to achievements and display
## a popup notification in one of the corners of the scene when unlocked.

## Corner of the scene
enum SceneCorner {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}
## Animation when popup enters or leaves the scene
enum PopupAnimation {
	## Popup appears and disappears instantaneously.
	INSTANT,
	## Popup flies in and out vertically
	FLY,
	## Popup fades in and out
	FADE
}

## Corner of the scene to display achievement popups in.
@export var corner: SceneCorner

## Custom minimum size of each achievement popup. It is recommended that you
## set the y dimension to 0, so that the actual vertical size gets calculated
## by the size of the icon and other contents of the popup.
@export var popup_size: Vector2i = Vector2(480.0, 0.0)

## Vertical separation between each achievement popup
@export var popup_separation: float = 16.0

## Number of seconds achievement popups should display for in seconds, excluding
## animation time.
@export var display_time_sec: float = 4.0

## Animation to display when popup enters or leaves the scene. See [enum PopupAnimation].
@export var popup_animation: PopupAnimation

## Duration of animation 
@export var animation_time_sec: float = 0.5

## Transition type for animations. See [enum Tween.TransitionType]
@export var transition_type: Tween.TransitionType

## Ease type for animations. See [enum Tween.EaseType].
@export var ease_type: Tween.EaseType

## Override for the [LabelSettings] on the achievement popups' name labels. If this is
## not set, the name labels will show with a defualt label settings with 24px
## font.
@export var name_labels_settings_override: LabelSettings = null:
	set(value):
		name_labels_settings_override = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.name_label_settings_override = value
	get:
		return name_labels_settings_override

## Thickness of the margin within each popup in pixels.
@export var popup_margin_size: int = 16:
	set(value):
		popup_margin_size = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.margin_size = popup_margin_size
	get:
		return popup_margin_size

@export_category("Icons")
## Set to true to display achievement icons on popups. [member default_achievement_icon] and/or
## [member Achievement.icon] should be set if this is true.
@export var show_icons: bool = true:
	set(value):
		show_icons = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.show_icon = value
	get:
		return show_icons

## If set to a non-zero vector, each popup's achievement icon will be displayed at this
## size rather than the image's dimensions.
@export var icon_size_override: Vector2 = Vector2.ZERO:
	set(value):
		icon_size_override = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.icon_size_override = value

## If true, a border will be displayed around the icon. This border is a panel
## that displays above the icon with custom theming to show a white border around
## (not overlapping) its dimensions. To override this behaviour set a custom
## [StyleBox] with [member icon_border_stylebox_override].
@export var show_icon_borders: bool = true:
	set(value):
		show_icon_borders = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.show_icon_border = value
	get:
		return show_icon_borders

## Stylebox used to display a border around the achievement icon. Set this to
## replace the default icon border (by default a white border). See
## [member show_icon_border].
@export var icon_border_stylebox_override: StyleBox:
	set(value):
		icon_border_stylebox_override = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.icon_border_stylebox_override = value
	get:
		return icon_border_stylebox_override

## Separation in pixels between each popup's icon and the rest of its achievement info.
@export var icon_separation: int = 16:
	set(value):
		icon_separation = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.icon_separation = value

## Default achievement icon to display if the [member Achievement.icon] is not
## set. Leaving this unset may result in undefined behaviour. Set [member display_icon]
## to false instead if you want to hide the icon.
@export var default_achievement_icon: Texture2D:
	set(value):
		default_achievement_icon = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.default_achievement_icon = value
	get:
		return default_achievement_icon

@export_category("Rewards")
## Set to true to display reward in the popup (if the [member achievement] has one).
## Off by default to reduce clutter and allow more space for the desccription, but
## if achievement rewards are particularly important in your game you may wish to
## turn this on. 
@export var show_rewards: bool = false:
	set(value):
		show_rewards = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.show_reward = value
	get:
		return show_rewards

## Set to true to bold the text "Reward:" that displays before the reward
## description.
@export var bold_reward_titles: bool = false:
	set(value):
		bold_reward_titles = value
		for popup in _popups:
			if is_instance_valid(popup):
				popup.bold_reward_title = value
	get:
		return bold_reward_titles


const _OFF_SCREEN_PADDING: float = 4.0

# These arrays have an entry for each popup, with the index being consistent
# across the arrays. When a popup is deleted, its index in _popups is set to
# null, but any associated timers or tweens are kept to avoid having to recreate
# them later. If a timer or tween does not have an associated popup, you can
# safely re-configure them as they are not being used.
var _popups: Array[Control] = []
var _timers: Array[Timer] = []
var _tweens: Array[Tween] = []

@onready var _display_region_control: Control = $DisplayRegionControl

var _popup_scene := preload("res://addons/sv_achievements/ui/achievement_overlay/achievement_popup/achievement_popup.tscn")


# Override
func _ready() -> void:
	AchievementService.achievement_unlocked.connect(_on_achievement_unlocked)


## Pops up the given achievement
func popup(achievement: Achievement) -> void:
	if _display_region_control == null:
		push_error("Tried to create achievement popup but display region was not set or did not exist.")
		return
	
	var index := _create_popup(achievement)
	var popup := _popups[index]
	
	_display_region_control.add_child(popup)
	
	match corner:
		SceneCorner.TOP_LEFT:
			popup.grow_horizontal = Control.GROW_DIRECTION_END
			popup.grow_vertical = Control.GROW_DIRECTION_END
		SceneCorner.TOP_RIGHT:
			popup.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			popup.grow_vertical = Control.GROW_DIRECTION_END
		SceneCorner.BOTTOM_LEFT:
			popup.grow_horizontal = Control.GROW_DIRECTION_END
			popup.grow_vertical = Control.GROW_DIRECTION_BEGIN
		SceneCorner.BOTTOM_RIGHT:
			popup.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			popup.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	popup.custom_minimum_size = popup_size
	
	popup.set_anchors_and_offsets_preset(_get_layout_preset(corner), Control.LayoutPresetMode.PRESET_MODE_KEEP_SIZE)
	popup.offset_top = _get_popup_top_anchor_offset(corner, index, popup.get_minimum_size())
	popup.offset_bottom = _get_popup_bottom_anchor_offset(corner, index, popup.get_minimum_size())
	
	match popup_animation:
		PopupAnimation.INSTANT:
			var timer := _get_timer(index)
			timer.timeout.connect(_delete_popup.bind(index, CONNECT_ONE_SHOT))
			timer.one_shot = true
			timer.start(display_time_sec)
		PopupAnimation.FLY:
			var target_top := popup.offset_top
			var target_bottom := popup.offset_bottom
			var off_screen_top = _get_popup_off_screen_top_anchor_offset(corner, index, popup.get_minimum_size())
			var off_screen_bottom = _get_popup_off_screen_bottom_anchor_offset(corner, index, popup.get_minimum_size())
			
			popup.offset_top = off_screen_top
			popup.offset_bottom = off_screen_bottom
			
			var tween := _get_new_tween(index)
			tween.set_loops(1)
			tween.set_trans(transition_type)
			tween.set_ease(ease_type)
			
			tween.tween_property(popup, "offset_top", target_top, animation_time_sec)
			tween.parallel().tween_property(popup, "offset_bottom", target_bottom, animation_time_sec)
			
			tween.tween_interval(display_time_sec)
			
			tween.tween_property(popup, "offset_top", off_screen_top, animation_time_sec)
			tween.parallel().tween_property(popup, "offset_bottom", off_screen_bottom, animation_time_sec)
			
			tween.tween_callback(_delete_popup.bind(index))
			
			tween.play()
		PopupAnimation.FADE:
			popup.modulate = Color(1.0, 1.0, 1.0, 0.0)
			
			var tween := _get_new_tween(index)
			tween.set_loops(1)
			tween.set_trans(transition_type)
			tween.set_ease(ease_type)
			
			tween.tween_property(popup, "modulate", Color(1.0, 1.0, 1.0, 1.0), animation_time_sec)
			tween.tween_interval(display_time_sec)
			tween.tween_property(popup, "modulate", Color(1.0, 1.0, 1.0, 0.0), animation_time_sec)
			
			tween.tween_callback(_delete_popup.bind(index))
			
			tween.play()


func _create_popup(achievement: Achievement) -> int:
	var popup: Control = _popup_scene.instantiate()
	
	var index := _popups.find(null)
	if index < 0:
		index = _popups.size()
		_popups.append(popup)
	else:
		_popups.set(index, popup)
	
	popup.achievement = achievement
	popup.name_label_settings_override = name_labels_settings_override
	popup.margin_size = popup_margin_size
	popup.show_icon = show_icons
	popup.icon_size_override = icon_size_override
	popup.show_icon_border = show_icon_borders
	popup.icon_border_stylebox_override = icon_border_stylebox_override
	popup.icon_separation = icon_separation
	popup.default_achievement_icon = default_achievement_icon
	popup.show_reward = show_rewards
	popup.bold_reward_title = bold_reward_titles
	
	return index


func _delete_popup(index: int) -> void:
	_disconnect_popup(index)
	
	var popup := _popups[index]
	_popups[index] = null
	popup.queue_free()


func _disconnect_popup(index: int) -> void:
	var timer := _get_timer(index)
	for connection in timer.timeout.get_connections():
		connection["signal"].disconnect(connection["callable"])


func _get_timer(index: int) -> Timer:
	while index >= _timers.size():
		var timer := Timer.new()
		add_child(timer)
		_timers.append(timer)
	
	return _timers[index]


func _get_tween(index: int) -> Tween:
	while index >= _tweens.size():
		var tween := create_tween()
		_tweens.append(tween)
	
	return _tweens[index]


func _get_new_tween(index: int) -> Tween:
	if index >= _tweens.size():
		return _get_tween(index)
	
	_tweens[index].kill()
	
	var tween := create_tween()
	_tweens[index] = tween
	
	return tween


func _get_layout_preset(corner: SceneCorner) -> Control.LayoutPreset:
	match corner:
		SceneCorner.TOP_LEFT:
			return Control.LayoutPreset.PRESET_TOP_LEFT
		SceneCorner.TOP_RIGHT:
			return Control.LayoutPreset.PRESET_TOP_RIGHT
		SceneCorner.BOTTOM_LEFT:
			return Control.LayoutPreset.PRESET_BOTTOM_LEFT
		SceneCorner.BOTTOM_RIGHT:
			return Control.LayoutPreset.PRESET_BOTTOM_RIGHT
		_:
			push_error("Invalid corner: %s" % corner)
			return Control.LayoutPreset.PRESET_TOP_LEFT


func _get_popup_off_screen_top_anchor_offset(corner: SceneCorner, index: int, for_size: Vector2) -> float:
	match corner:
		SceneCorner.TOP_LEFT, SceneCorner.TOP_RIGHT:
			return -(_get_top_margin_size()) - _OFF_SCREEN_PADDING - for_size.y
		SceneCorner.BOTTOM_LEFT, SceneCorner.BOTTOM_RIGHT:
			return _get_bottom_margin_size() + _OFF_SCREEN_PADDING
		_:
			push_error("Invalid corner enum for achievement popup off-screen top anchor offset")
			return 0.0


func _get_popup_off_screen_bottom_anchor_offset(corner: SceneCorner, index: int, for_size: Vector2) -> float:
	match corner:
		SceneCorner.TOP_LEFT, SceneCorner.TOP_RIGHT:
			return -(_get_top_margin_size()) - _OFF_SCREEN_PADDING
		SceneCorner.BOTTOM_LEFT, SceneCorner.BOTTOM_RIGHT:
			return _get_bottom_margin_size() + _OFF_SCREEN_PADDING + for_size.y
		_:
			push_error("Invalid corner enum for achievement popup off-screen bottom anchor offset")
			return 0.0


func _get_popup_top_anchor_offset(corner: SceneCorner, index: int, for_size: Vector2) -> float:
	match corner:
		SceneCorner.TOP_LEFT, SceneCorner.TOP_RIGHT:
			return 0.0 + (index * popup_separation) + (index * for_size.y)
		SceneCorner.BOTTOM_LEFT, SceneCorner.BOTTOM_RIGHT:
			return for_size.y + (index * popup_separation) + (index * for_size.y)
		_:
			push_error("Invalid corner enum for achievement popup top anchor offset")
			return 0.0


func _get_popup_bottom_anchor_offset(corner: SceneCorner, index: int, for_size: Vector2) -> float:
	match corner:
		SceneCorner.TOP_LEFT, SceneCorner.TOP_RIGHT:
			return for_size.y - (index * popup_separation) - (index * for_size.y)
		SceneCorner.BOTTOM_LEFT, SceneCorner.BOTTOM_RIGHT:
			return 0.0 - (index * popup_separation) - (index * for_size.y)
		_:
			push_error("Invalid corner enum for achievement popup bottom anchor offset")
			return 0.0


func _get_bottom_margin_size() -> int:
	return get_theme_constant("margin_bottom", "MarginContainer")


func _get_top_margin_size() -> int:
	return get_theme_constant("margin_top", "MarginContainer")


func _disconnect_all() -> void:
	for index in range(_popups.size()):
		_disconnect_popup(index)
	
	if AchievementService.achievement_unlocked.is_connected(_on_achievement_unlocked):
		AchievementService.achievement_unlocked.disconnect(_on_achievement_unlocked)


# Signal connection
func _on_achievement_unlocked(achievement: Achievement) -> void:
	popup(achievement)


# Override
func _exit_tree() -> void:
	_disconnect_all()
	
	for tween in _tweens:
		tween.kill()
