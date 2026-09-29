# LevelSelect.gd

extends Control

@export var level_list: LevelList
var level_button_resource = preload("res://UI/MainMenu/LevelSelect/ButtonLevel.tscn")
var selected_level = 1
# Nodes
@export var level_button_container: Control
@export var level_number_label: Label
@export var level_caption_label: Label
@export var personal_best_time_label: Label
@export var par_time_label: Label
@export var par_check_texture_rect: TextureRect
@export var no_hit_check_texture_rect: TextureRect
@export var par_and_no_hit_check_texture_rect: TextureRect

func _ready():
	# Populate level grid
	var button_group := ButtonGroup.new()
	for i in level_list.get_number_of_levels():
		var lb = level_button_resource.instantiate()
		level_button_container.add_child(lb)
		lb.button_group = button_group
		lb.set_text(str(i + 1).pad_zeros(2))
		lb.connect("pressed", Callable(self, "_on_ButtonLevel_pressed").bind(i + 1))
		if not Profile.is_level_unlocked(i + 1):
			lb.set_disabled(true)
		if i == 0:
			lb.set_pressed(true)
			# Doing it in code doesn't emit the signal so we do that ourselves:
			lb.emit_signal("pressed")

func _on_ButtonLevel_pressed(level_number: int):
	selected_level = level_number
	# Update details
	level_number_label.text = "Level " + str(level_number)
	level_caption_label.text = level_list.get_level_caption(level_number)
	personal_best_time_label.text = Profile.get_level_best_time(level_number).get_display_string()
	par_time_label.text = level_list.get_level_par_time(level_number).get_display_string()

func _on_ButtonBack_pressed():
	SceneTransition.instant("res://UI/MainMenu/MainMenu.tscn")

func _on_ButtonPlay_pressed():
	SceneTransition.fade(level_list.get_level_scene_path(selected_level), 0.2, 1.0)
