# LevelDetail.gd

extends Control

@export var level_list: Resource

func update_level(level_number):
	var txt = "Level "
	txt += str(level_number + 1)
	txt += "\n"
	txt += level_list._get_caption(level_number)
	$Label.set_text(txt)
