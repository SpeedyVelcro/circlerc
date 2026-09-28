# LevelDetail.gd

extends Control

@export var level_list: LevelList

func update_level(level_number: int):
	var txt = "Level "
	txt += str(level_number)
	txt += "\n"
	txt += level_list.get_level_caption(level_number)
	$Label.set_text(txt)
