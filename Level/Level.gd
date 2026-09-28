extends Node

var _current_level: int = -1 # Starts at 1
var time: TimeScore = TimeScore.ZERO
var has_finished = false
var started = false

@export var level_list: LevelList

signal time_elapsed(new_time: TimeScore)
signal finished

func _ready():
	_current_level = level_list.scene_root_node_to_number(self)
	
	$VictoryMenu.set_level(_current_level)
	for fin in get_tree().get_nodes_in_group("finish"):
		fin.connect("activated", Callable(self, "_on_Finish_activated").bind(), CONNECT_ONE_SHOT)
		$HUD.set_level(_current_level)

func _process(delta):
	if started and not has_finished:
		var milliseconds_elapsed = 1000 * delta
		time.advance(milliseconds_elapsed)
		emit_signal("time_elapsed", time)

func _on_Finish_activated():
	has_finished = true
	emit_signal("finished")
	
	
	$VictoryAudio.play()
	$FinishTimer.start(1.5)
	$HUDFadeTimer.start(1.5)
	
	Profile.submit_level_time(_current_level, time)
	$VictoryMenu.set_time(time)
	
	# Unlock next level
	Profile.set_level_unlocked(_current_level + 1, true)

func _on_FinishTimer_timeout():
	$VictoryMenu.display()

func next_level():
	if _current_level >= level_list.get_number_of_levels():
		# Final level so back to main menu
		SceneTransition.fade("res://UI/MainMenu/MainMenu.tscn")
	else:
		# Go to next level
		var next = level_list.get_level_scene_path(_current_level + 1)
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
