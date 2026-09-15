# EnemyPathFollow.gd

extends PathFollow2D

var max_speed = 0.0
var speed_multiplier = 1.0

func _process(delta):
	var closest_relative_offset = 999.0
	var path_follow_count = 1
	for sibling in get_parent().get_children():
		if sibling.get_groups().has("enemy_path_follow") and sibling != self:
			path_follow_count += 1
			var sibling_relative_offset = sibling.get_progress_ratio() - progress_ratio
			while sibling_relative_offset < 0.0:
				sibling_relative_offset += 1.0
			closest_relative_offset = min(closest_relative_offset, sibling_relative_offset)
	if not (closest_relative_offset < ((1.0 / path_follow_count) * 0.5)):
		# This is the actual line that does the movement
		progress += max_speed * delta * speed_multiplier
		

# Getters and setters
func set_max_speed(value):
	max_speed = value

func get_max_speed():
	return max_speed

func set_speed_multiplier(value):
	speed_multiplier = value

func get_speed_multiplier():
	return speed_multiplier
