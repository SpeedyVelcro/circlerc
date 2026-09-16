# SceneTransition.gd

extends Node

var transition_player_resource = preload("res://AutoLoad/SceneTransitionPlayer.tscn")
var transition_player
var next_scene
var next_in_time_sec

func _ready():
	transition_player = transition_player_resource.instantiate()
	add_child(transition_player)
	transition_player.connect("animation_finished", Callable(self, "_on_SceneTransitionPlayer_animation_finished"))

func instant(scene: String):
	get_tree().change_scene_to_file(scene)

func fade(scene : String, out_time_sec : float = 0.5, in_time_sec : float = 0.5):
	# TODO: actually write a fade lol
	next_scene = scene
	next_in_time_sec = in_time_sec
	transition_player.set_speed_scale(1 / out_time_sec)
	transition_player.play("fade_out")

func _on_SceneTransitionPlayer_animation_finished(anim_name):
	match anim_name:
		"fade_out":
			get_tree().change_scene_to_file(next_scene)
			transition_player.set_speed_scale(1 / next_in_time_sec)
			transition_player.play("fade_in")
