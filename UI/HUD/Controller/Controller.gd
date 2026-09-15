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
	# Inside tree check necessary to prevent annoying error messages when
			# RC car is deleted
	if $Tween.is_inside_tree():
		$Tween.follow_property(get_node("Visual"), "position",
				$Visual.get_position(), self, "normal_visual_position", hide_time,
				Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()


@warning_ignore("native_method_override") # TODO: rename
func hide():
	# Inside tree check necessary to prevent annoying error messages when
			# RC car is deleted
	if $Tween.is_inside_tree():
		$Tween.follow_property(get_node("Visual"), "position",
				$Visual.get_position(), self, "hidden_visual_position", hide_time,
				Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()

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

func _on_Controller_tree_exiting():
	# Stop tween so we don't get annoying error messages (even though they're
	# silent and don't do anything)
	$Tween.stop_all()
