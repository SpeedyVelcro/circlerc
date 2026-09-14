# PauseMenu.gd

extends CanvasLayer

var pause_allowed = true

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().is_paused():
			unpause()
		elif pause_allowed:
			pause()

func pause():
	get_tree().set_pause(true)
	$Visual.set_visible(true)

func unpause():
	get_tree().set_pause(false)
	$Visual.set_visible(false)

func _on_ButtonResume_pressed():
	unpause()

func _on_ButtonRestart_pressed():
	get_tree().set_pause(false)
	SceneTransition.instant(get_tree().get_current_scene().get_scene_file_path())

func _on_ButtonQuit_pressed():
	get_tree().set_pause(false)
	SceneTransition.instant("res://UI/MainMenu/MainMenu.tscn")

func _on_Level_finished():
	pause_allowed = false
