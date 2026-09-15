# MainMenu.gd

extends Control

@export var quit_button: Button

func _ready():
	if OS.get_name() == "HTML5":
		quit_button.set_visible(false)

func _on_ButtonPlay_pressed():
	SceneTransition.fade("res://Level/Instance/001.tscn", 0.2, 0.5)

func _on_ButtonLevelSelect_pressed():
	SceneTransition.instant("res://UI/MainMenu/LevelSelect/LevelSelect.tscn")

func _on_ButtonCredits_pressed():
	SceneTransition.instant("res://UI/MainMenu/Credits/Credits.tscn")

func _on_ButtonQuit_pressed():
	get_tree().quit()
