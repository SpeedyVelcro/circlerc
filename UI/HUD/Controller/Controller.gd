# Controller.gd

extends Control

var normal_visual_position
var hidden_visual_position
var hide_time = 0.2

func _ready():
	normal_visual_position = $Visual.get_position()
	hidden_visual_position = normal_visual_position
	hidden_visual_position.y += 96


@warning_ignore("native_method_override") # TODO: rename
func show():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Visual, "position", normal_visual_position, hide_time)
	tween.play()


@warning_ignore("native_method_override") # TODO: rename
func hide():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Visual, "position", normal_visual_position, hide_time)
	tween.play()

# Manipulate gizmos
func steer_left():
	$Visual/SteerSprite.play("left")

func steer_straight():
	$Visual/SteerSprite.play("straight")

func steer_right():
	$Visual/SteerSprite.play("right")

func throttle_forward():
	$Visual/ThrottleSprite.play("forward")

func throttle_stop():
	$Visual/ThrottleSprite.play("stop")

func throttle_reverse():
	$Visual/ThrottleSprite.play("reverse")
