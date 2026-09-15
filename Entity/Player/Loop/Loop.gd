# Loop.gd

extends Node2D

var starting_angle = 0
var radius = 24
var direction = 1
var progress_rad = 0 # Progress in radians
var circle_resolution = 64 # Points in full circle
var capturables = []
var alpha = 1.0
var success_threshold = 0.945 # Should be adjusted so success is just a couple
		# pixels before front of car hits beginning of circle
		# TODO: make this actually distance based, not proportion based so that
		# it gives a similar feel regardless of radius
var success_lifetime_sec = 0.5
# Success circle
var draw_success_circle = false
var success_circle_progress = 0.0
var success_circle_time = 1.0

signal completed

func _process(delta):
	if draw_success_circle:
		success_circle_progress += delta / success_circle_time
		queue_redraw()
		if success_circle_progress >= 1.0:
			draw_success_circle = false

func _draw():
	# Draw arc
	# TODO: fuck I just realised there's an inbuilt function for this, should probably replace everything
	var origin = Vector2(0, 0)
	var points = PackedVector2Array()
	var color = Color.WHITE
	color.a = alpha
	for i in range(circle_resolution + 1):
		if (i as float) / ((circle_resolution as float) + 1) > progress_rad / (2 * PI):
			break
		var angle = starting_angle + (i * 2 * PI / circle_resolution) * direction
		var pos = origin + Vector2(cos(angle), sin(angle)) * radius
		points.push_back(pos)
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, 2.0)
	# Draw success circle
	if draw_success_circle:
		var initial_a = 0.5
		var final_a = 0.0
		var initial_scale = 1.0
		var final_scale = 1.3
		var a = initial_a + (final_a - initial_a) * success_circle_progress
		var s = initial_scale + (final_scale - initial_scale) * success_circle_progress
		color = Color.WHITE
		color.a = a
		draw_circle(origin, (radius as float) * s, color)

func complete():
	for cap in capturables:
		connect("completed", Callable(cap, "_on_Loop_complete").bind(), CONNECT_ONE_SHOT)
	emit_signal("completed")
	$Timer.start(success_lifetime_sec)
	draw_success_circle = true
	

func _on_Player_loop_advance(value_rad):
	progress_rad += abs(value_rad)
	queue_redraw() # Re-draw
	if progress_rad >= (2 * PI) * success_threshold:
		progress_rad = 2 * PI
		complete()

func _on_Player_loop_cancel():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "alpha", 0.0, 0.1)
	tween.play()

func _on_Timer_timeout():
	# Success lifetime over so fade out.
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "alpha", 0.0, 3.0)
	tween.play()

func _on_FadeTween_tween_completed(_object, _key):
	# Faded out so free
	queue_free()

func _on_Area2D_area_entered(area):
	# area is known to be a Capturable by collision mask
	capturables.append(area)

func _on_Area2D_area_exited(area):
	# area is known to be a Capturable by collision mask
	# This will probably never happen anyway but oh well
	capturables.erase(area)

# Getters and setters
func get_radius():
	return radius

func set_radius(value):
	radius = value
	$Area2D/CollisionShape2D.shape.set_radius(value)

func set_alpha(value):
	alpha = value
	queue_redraw() # Re-draw with new alpha

func get_alpha():
	return alpha
