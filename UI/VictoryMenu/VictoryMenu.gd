# VictoryMenu.gd
extends CanvasLayer

@export var visibility_node: Control
@export var level_title_label: Label
@export var time_label: Label
@export var par_time_label: Label
@export var best_time_label: Label
@export var new_personal_best_label: Label
@export var no_hits_label: Label
@export var under_par_label: Label
@export var leaderboard_ui_controller: LeaderboardUIController
@export var input_allowed = false
var level_list: LevelList = preload("res://Level/LevelList.tres")
var level_number = 0
var time: TimeScore = TimeScore.NONE
var best_time: TimeScore = TimeScore.NONE
var par: TimeScore = TimeScore.NONE

signal next_level

func _ready():
	new_personal_best_label.visible = false
	no_hits_label.visible = false
	under_par_label.visible = false
	visibility_node.visible = false
	input_allowed = false
	var c = $ColorRect.modulate
	c.a = 0
	$ColorRect.modulate = c

func _process(_delta):
	if input_allowed:
		if Input.is_action_just_pressed("ui_accept"):
			continue_to_next_level()
		elif Input.is_action_just_pressed("ui_cancel"):
			quit()

func display(skip = false):
	visibility_node.set_visible(true)
	$AnimationPlayer.play("fly_in")
	$AnimationPlayer.seek(0, true) # Ensures menu is below screen before next draw
	if skip:
		$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)

func quit():
	SceneTransition.instant("res://UI/MainMenu/MainMenu.tscn")

func retry():
	SceneTransition.instant(get_tree().get_current_scene().get_scene_file_path())

func continue_to_next_level():
	emit_signal("next_level")

func _on_QuitButton_pressed():
	quit()

func _on_RetryButton_pressed():
	retry()

func _on_NextButton_pressed():
	continue_to_next_level()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fly_in":
			# Just in case it's not set in the animation
			input_allowed = true

# Getters and setters
func set_time(value: TimeScore):
	time = value
	time_label.text = time.get_display_string()
	if time.get_total_milliseconds() < best_time.get_total_milliseconds():
		new_personal_best_label.visible = true
		best_time_label.text = time.get_display_string()
	if time.get_total_milliseconds() < par.get_total_milliseconds():
		under_par_label.visible = true
	
	leaderboard_ui_controller.set_score_to_submit(time.get_total_milliseconds())

func set_no_hits(value: bool):
	no_hits_label.visible = value

func set_level(value):
	# Input level starting from 1
	level_number = value
	level_title_label.set_text("Level " + str(level_number))
	best_time = Profile.get_level_best_time(level_number)
	best_time_label.text = best_time.get_display_string()
	par = level_list.get_level_par_time(level_number)
	par_time_label.text = par.get_display_string()
	
	leaderboard_ui_controller.leaderboard = level_list.get_level_leaderboard(level_number)
	leaderboard_ui_controller.update()
