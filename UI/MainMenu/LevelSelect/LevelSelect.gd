# LevelSelect.gd

extends Control

@export var level_list: Resource
var level_button_resource = preload("res://UI/MainMenu/LevelSelect/ButtonLevel.tscn")
var selected_level = 0
# Nodes
@export var grid_container_path: NodePath
@onready var grid_container = get_node(grid_container_path)
@export var level_number_label_path: NodePath
@onready var level_number_label = get_node(level_number_label_path)
@export var level_caption_label_path: NodePath
@onready var level_caption_label = get_node(level_caption_label_path)
@export var best_time_label_path: NodePath
@onready var best_time_label = get_node(best_time_label_path) 

func _ready():
	# Populate level grid
	var button_group := ButtonGroup.new()
	for i in level_list.get_number_of_levels():
		var lb = level_button_resource.instantiate()
		grid_container.add_child(lb)
		lb.button_group = button_group
		lb.set_text(str(i + 1).pad_zeros(2))
		lb.connect("pressed", Callable(self, "_on_ButtonLevel_pressed").bind(i))
		if not Profile.is_level_unlocked(i):
			lb.set_disabled(true)
		if i == 0:
			lb.set_pressed(true)
			# Doing it in code doesn't emit the signal so we do that ourselves:
			lb.emit_signal("pressed")

func _on_ButtonLevel_pressed(level_number):
	selected_level = level_number
	# Update details
	level_number_label.set_text("Level " + str(level_number + 1))
	level_caption_label.set_text(level_list._get_caption(level_number))
	var t_cent = Profile.get_level_best_time(level_number)
	if t_cent == -1:
		best_time_label.set_text("xx:xx:xx")
	else:
		var t_sec = 0
		var t_min = 0
		while t_cent >= 100:
			t_cent -= 100
			t_sec += 1
		while t_sec >= 60:
			t_sec -= 60
			t_min += 1
		var s_cent = str(floor(t_cent)).pad_zeros(2)
		var s_sec = str(floor(t_sec)).pad_zeros(2)
		var s_min = str(floor(t_min)). pad_zeros(2)
		best_time_label.set_text(s_min + ":" + s_sec + ":" + s_cent)

func _on_ButtonBack_pressed():
	SceneTransition.instant("res://UI/MainMenu/MainMenu.tscn")

func _on_ButtonPlay_pressed():
	SceneTransition.fade(level_list.get_level(selected_level), 0.2, 1.0)
