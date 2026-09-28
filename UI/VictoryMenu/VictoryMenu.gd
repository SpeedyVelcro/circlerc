# VictoryMenu.gd
extends CanvasLayer

@onready var visibility_node = get_node("CenterContainer")
@onready var level_title_label = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/LevelTitle")
@onready var time_label = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/Time")
@onready var best_time_label = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/RecordPrevious/BestTime")
@onready var record_previous_node = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/RecordPrevious")
@onready var record_new_node = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/RecordNew")
@export var input_allowed = false
var level_number = 0
var time: TimeScore = TimeScore.NONE
var best_time: TimeScore = TimeScore.NONE

signal next_level

func _ready():
	record_previous_node.set_visible(true)
	record_new_node.set_visible(false)
	visibility_node.set_visible(false)
	input_allowed = false
	var c = $ColorRect.get_modulate()
	c.a = 0
	$ColorRect.set_modulate(c)

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
	time_label.text = value.get_display_string()
	if time.get_total_milliseconds() < best_time.get_total_milliseconds():
		record_previous_node.set_visible(false)
		record_new_node.set_visible(true)

func set_level(value):
	# Input level starting from 1
	level_number = value
	level_title_label.set_text("Level " + str(level_number))
	best_time = Profile.get_level_best_time(level_number)
	best_time_label.text = best_time.get_display_string()
	
