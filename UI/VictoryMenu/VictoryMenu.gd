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
var time_cent = 0
var best_time_cent = 0

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
			next_level()
		elif Input.is_action_just_pressed("ui_cancel"):
			quit()

func display(skip = false):
	visibility_node.set_visible(true)
	$AnimationPlayer.play("fly_in")
	$AnimationPlayer.seek(0, true) # Ensures menu is below screen before next draw
	if skip:
		$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)

func centisec_to_string(value):
	if value < 0:
		return "xx:xx:xx"
	var cents = int(value)
	var secs = 0
	var mins = 0
	while cents >= 100:
		cents -= 100
		secs += 1
	while secs >= 60:
		secs -= 60
		mins += 1
	var str_min = String(floor(mins)).pad_zeros(2)
	var str_sec = String(floor(secs)).pad_zeros(2)
	var str_cent = String(floor(cents)).pad_zeros(2)
	return str_min + ":" + str_sec + ":" + str_cent + ":"

func quit():
	SceneTransition.instant("res://UI/MainMenu/MainMenu.tscn")

func retry():
	SceneTransition.instant(get_tree().get_current_scene().get_scene_file_path())

func next_level():
	emit_signal("next_level")

func _on_QuitButton_pressed():
	quit()

func _on_RetryButton_pressed():
	retry()

func _on_NextButton_pressed():
	next_level()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fly_in":
			# Just in case it's not set in the animation
			input_allowed = true

# Getters and setters
func set_time_cent(value):
	time_cent = value
	time_label.set_text(centisec_to_string(time_cent))
	if time_cent < best_time_cent:
		record_previous_node.set_visible(false)
		record_new_node.set_visible(true)

func set_level(value):
	# Input level starting from 1
	level_number = value
	level_title_label.set_text("Level " + String(level_number))
	best_time_cent = Profile.get_level_best_time(level_number - 1)
	best_time_label.set_text(centisec_to_string(best_time_cent))
	
