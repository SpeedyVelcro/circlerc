# Credits.gd

extends Control

var credits_file = "res://Credits.txt"
var mit_file = "res://License/MIT.txt"
var ofl_file = "res://License/OFL.txt"
@export var text_edit_path: NodePath
@onready var text_edit = get_node(text_edit_path)

func _ready():
	display_text_file(credits_file)

func _on_ButtonBack_pressed():
	SceneTransition.instant("res://UI/MainMenu/MainMenu.tscn")

func display_text_file(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var credits_text = ""
	while true:
		credits_text += file.get_line()
		if file.eof_reached():
			break
		else:
			credits_text += "\n"
	file.close()
	text_edit.set_text(credits_text)

func _on_CreditsButton_pressed():
	display_text_file(credits_file)

func _on_MITButton_pressed():
	display_text_file(mit_file)

func _on_OFLButton_pressed():
	display_text_file(ofl_file)
