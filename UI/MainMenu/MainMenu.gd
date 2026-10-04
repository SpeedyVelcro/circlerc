# MainMenu.gd

extends Control

@export var start_menu_root_control: Control
@export var options_menu_root_control: Control
@export var about_menu_root_control: Control
@export var level_select_menu_root_control: Control
@export var achievement_menu_root_control: Control
@export var social_media_root_control: Control
@export var background_layer: CanvasLayer
@export var quit_button: Button

var current_tweens: Array[Tween] = []


# Override
func _ready():
	if OS.get_name() == "HTML5":
		quit_button.set_visible(false)


# Signal connection
func _on_ButtonPlay_pressed():
	SceneTransition.fade("res://Level/Instance/001.tscn", 0.2, 0.5)


# Signal connection
func _on_ButtonLevelSelect_pressed():
	_play_animations(
		_create_menu_fly_out_tween(start_menu_root_control, Vector2.ZERO, Vector2(0.0, -1280.0)),
		_create_menu_fly_in_tween(level_select_menu_root_control, Vector2(0.0, 1280.0), Vector2.ZERO),
		_create_background_fly_tween(Vector2.ZERO, Vector2(0.0, -512.0)),
		_create_hide_social_menu_tween()
	)


# Signal connection
func _on_level_select_back() -> void:
	_play_animations(
		_create_menu_fly_in_tween(start_menu_root_control, Vector2(0.0, -1280.0), Vector2.ZERO),
		_create_menu_fly_out_tween(level_select_menu_root_control, Vector2.ZERO, Vector2(0.0, 1280.0)),
		_create_background_fly_tween(Vector2(0.0, -512.0), Vector2.ZERO),
		_create_show_social_menu_tween()
	)


# Signal connection
func _on_ButtonCredits_pressed():
	_play_animations(
		_create_menu_fly_out_tween(start_menu_root_control, Vector2.ZERO, Vector2(1280.0, 0.0)),
		_create_menu_fly_in_tween(about_menu_root_control, Vector2(-1280.0, 0.0), Vector2.ZERO),
		_create_background_fly_tween(Vector2.ZERO, Vector2(512.0, 0.0)),
		_create_hide_social_menu_tween()
	)


# Signal connection
func _on_about_menu_back() -> void:
	_play_animations(
		_create_menu_fly_in_tween(start_menu_root_control, Vector2(1280.0, 0.0), Vector2.ZERO),
		_create_menu_fly_out_tween(about_menu_root_control, Vector2.ZERO, Vector2(-1280.0, 0.0)),
		_create_background_fly_tween(Vector2(512.0, 0.0), Vector2.ZERO),
		_create_show_social_menu_tween()
	)


# Signal connection
func _on_ButtonQuit_pressed():
	Profile.save_profile()
	OptionsSaver.save()
	AchievementService.save_progress()
	get_tree().quit()


# Signal connection
func _on_AchievementsButton_pressed() -> void:
	_play_animations(
		_create_menu_fly_out_tween(start_menu_root_control, Vector2.ZERO, Vector2(0.0, 1280.0)),
		_create_menu_fly_in_tween(achievement_menu_root_control, Vector2(0.0, -1280.0), Vector2.ZERO),
		_create_background_fly_tween(Vector2.ZERO, Vector2(0.0, 512.0)),
		_create_hide_social_menu_tween()
	)


# Signal connection
func _on_achievement_menu_back() -> void:
	_play_animations(
		_create_menu_fly_in_tween(start_menu_root_control, Vector2(0.0, 1280.0), Vector2.ZERO),
		_create_menu_fly_out_tween(achievement_menu_root_control, Vector2.ZERO, Vector2(0.0, -1280.0)),
		_create_background_fly_tween(Vector2(0.0, 512.0), Vector2.ZERO),
		_create_show_social_menu_tween()
	)


# Signal connection
func _on_options_button_pressed() -> void:
	_play_animations(
		_create_menu_fly_out_tween(start_menu_root_control, Vector2.ZERO, Vector2(-1280.0, 0.0)),
		_create_menu_fly_in_tween(options_menu_root_control, Vector2(1280.0, 0.0), Vector2.ZERO),
		_create_background_fly_tween(Vector2.ZERO, Vector2(-512.0, 0.0)),
		_create_hide_social_menu_tween()
	)


# Signal connection
func _on_options_menu_back() -> void:
	_play_animations(
		_create_menu_fly_in_tween(start_menu_root_control, Vector2(-1280.0, 0.0), Vector2.ZERO),
		_create_menu_fly_out_tween(options_menu_root_control, Vector2.ZERO, Vector2(1280.0, 0.0)),
		_create_background_fly_tween(Vector2(-512.0, 0.0), Vector2.ZERO),
		_create_show_social_menu_tween()
	)


func _create_menu_fly_out_tween(control: Control, from: Vector2, to: Vector2) -> Tween:
	return _create_menu_fly_tween(control, from, to, true)


func _create_menu_fly_in_tween(control: Control, from: Vector2, to: Vector2) -> Tween:
	return _create_menu_fly_tween(control, from, to, false)


func _create_menu_fly_tween(control: Control, from: Vector2, to: Vector2, out: bool) -> Tween:
	var tween := get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func(): control.visible = true)
	tween.tween_callback(func(): control.offset_transform_enabled = true)
	if out:
		tween.tween_callback(func(): control.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED)
	
	tween.tween_property(control, "offset_transform_position", to, 0.7).from(from)
	
	tween.tween_callback(func(): control.offset_transform_enabled = false)
	tween.tween_callback(func(): control.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED)
	if out:
		tween.tween_callback(func(): control.visible = false)
	
	return tween


func _create_background_fly_tween(from: Vector2, to: Vector2) -> Tween:
	var tween := get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(background_layer, "offset", to, 0.7).from(from)
	
	return tween


func skip_animation() -> void:
	for tween in current_tweens:
		if tween.is_valid():
			tween.custom_step(float(INT32_MAX)) # Skips to end
	
	current_tweens = []


func _play_animations(...tweens: Array) -> void:
	skip_animation()
	
	current_tweens.assign(tweens)
	for tween in current_tweens:
		tween.play()


func _is_currently_animating() -> bool:
	for tween in current_tweens:
		if tween.is_valid():
			return true
	
	return false


func _create_show_social_menu_tween() -> Tween:
	var tween := get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_interval(0.1)
	
	tween.tween_callback(func(): social_media_root_control.visible = true)
	tween.tween_callback(func(): social_media_root_control.offset_transform_enabled = true)
	
	tween.tween_property(social_media_root_control, "offset_transform_position", Vector2(0, 0), 0.5).from(Vector2(-128, 0))
	
	tween.tween_callback(func(): social_media_root_control.offset_transform_enabled = false)
	tween.tween_callback(func(): social_media_root_control.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED)
	
	return tween


func _create_hide_social_menu_tween() -> Tween:
	var tween := get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func(): social_media_root_control.visible = true)
	tween.tween_callback(func(): social_media_root_control.offset_transform_enabled = true)
	tween.tween_callback(func(): social_media_root_control.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED)
	
	tween.tween_property(social_media_root_control, "offset_transform_position", Vector2(-128, 0), 0.5).from(Vector2(0, 0))
	
	tween.tween_callback(func(): social_media_root_control.offset_transform_enabled = false)
	tween.tween_callback(func(): social_media_root_control.visible = false)
	
	return tween


# Uncomment to allow skipping animation
#func _input(event: InputEvent) -> void:
	#if event is InputEventJoypadButton or event is InputEventMouseButton or event is InputEventKey:
		#if _is_currently_animating():
			#if event.is_released() or (event is InputEventMouseButton):
				#accept_event()
				#skip_animation()
