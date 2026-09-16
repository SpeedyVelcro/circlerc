# Level.gd

extends Node

@export var current_level: int = 1 # Starts at 1
var level_list = preload("res://Level/LevelList.tres")
var time_elapsed_centisec = 0
var has_finished = false
var started = false

signal time_elapsed(time_sec)
signal finished

func _ready():
	$VictoryMenu.set_level(current_level)
	for fin in get_tree().get_nodes_in_group("finish"):
		fin.connect("activated", Callable(self, "_on_Finish_activated").bind(), CONNECT_ONE_SHOT)
		$HUD.set_level(current_level - 1)

func _process(delta):
	if started and not has_finished:
		var t = 100 * delta
		time_elapsed_centisec += t
		emit_signal("time_elapsed", t)

func _on_Finish_activated():
	emit_signal("finished")
	$VictoryAudio.play()
	has_finished = true
	$FinishTimer.start(1.5)
	$HUDFadeTimer.start(1.5)
	Profile.submit_level_time(current_level - 1, time_elapsed_centisec)
	$VictoryMenu.set_time_cent(time_elapsed_centisec)

func _on_FinishTimer_timeout():
	$VictoryMenu.display()

func next_level():
	if current_level >= level_list.get_number_of_levels():
		# Final level so back to main menu
		SceneTransition.fade("res://UI/MainMenu/MainMenu.tscn")
	else:
		# Unlock next level
		Profile.set_level_unlocked(current_level, true) # Inherently next level
				# as current_level starts from 1
		# Go to next level
		var next = level_list.get_level(current_level) # Inherently next level as
				# current_level starts from 1
		SceneTransition.fade(next)

func _on_Player_first_move():
	started = true

func _on_Player_death():
	$DeathTimer.start(2.0)

func _on_DeathTimer_timeout():
	SceneTransition.fade(get_tree().get_current_scene().get_scene_file_path(), 1.0, 0.5)

func _on_HUDFadeTimer_timeout():
	$HUD.fade_out()

func _on_VictoryMenu_next_level():
	next_level()
