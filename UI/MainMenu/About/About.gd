extends Control


# Signal connection
func _on_ButtonBack_pressed():
	SceneTransition.instant("res://UI/MainMenu/MainMenu.tscn")
