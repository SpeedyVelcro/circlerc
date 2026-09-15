# HUD.gd

extends CanvasLayer

var level_finished = false
var fading_out = false # When true all the UI gizmos will begin interpolating to alpha 0
var fade_out_progress = 0.0
var fade_out_time_sec = 0.2

func _process(delta):
	if fading_out and fade_out_progress < 1.0:
		fade_out_progress += (1.0 / fade_out_time_sec) * delta
		clamp(fade_out_progress, 0.0, 1.0)
		var initial_alpha = 1.0
		var final_alpha = 0.0
		var interpolated = initial_alpha * (1 - fade_out_progress) + final_alpha * fade_out_progress
		set_alpha_all(interpolated)

func fade_out():
	fading_out = true

func _on_Player_steer_left():
	$Controller.steer_left()

func _on_Player_steer_straight():
	$Controller.steer_straight()

func _on_Player_steer_right():
	$Controller.steer_right()

func _on_Player_throttle_forward():
	$Controller.throttle_forward()

func _on_Player_throttle_stop():
	$Controller.throttle_stop()

func _on_Player_throttle_reverse():
	$Controller.throttle_reverse()

func _on_Player_health_changed(health, max_health):
	$HealthBar.set_progress(health / max_health)

func _on_ControllerArea_body_entered(_body):
	# Collision mask means only player can trigger this
	if not level_finished:
		$Controller.hide()

func _on_ControllerArea_body_exited(_body):
	# Collision mask means only player can trigger this
	if not level_finished:
		$Controller.show()

func _on_Level_time_elapsed(time_centisec):
	$Clock.set_time(time_centisec)

func _on_Level_finished():
	$Clock.finalise()
	# Hiding the controller actually draws attention lets not do that
	#$Controller.hide()
	level_finished = true

# Getters and setters
func set_level(value):
	# HUD doesn't actually store level, it just sends it to the nodes that need
			# it.
	$LevelDetail.update_level(value)

func set_alpha_all(value):
	var c
	c = $Controller.get_modulate()
	c.a = value
	$Controller.set_modulate(c)
	c = $HealthBar.get_modulate()
	c.a = value
	$HealthBar.set_modulate(c)
	c = $Clock.get_modulate()
	c.a = value
	$Clock.set_modulate(c)
	c = $LevelDetail.get_modulate()
	c.a = value
	$LevelDetail.set_modulate(c)
