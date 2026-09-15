# Enemy.gd
# Basic idea: a PathFollow2D follows the path and this enemy instance follows
# that PathFollow2D using rigid body methods.
# The PathFollow2D tries to space out from others on the same path.
# When Enemy is too far it tells the PathFollow2D to slow down and let it catch up.

extends RigidBody2D

var path = null:
	set(value):
		_path = value
		path_points = path.get_curve().get_baked_points()
	get:
		return _path

var _path = null
@export var max_speed = 100.0
var path_points
var path_index = 0
var next_point_threshold = 1
var velocity = Vector2(0, 0)
var rotation_factor = 100.0
@export var acceleration = 15.0
@export var reverse_acceleration = 6.0
var path_follow_resource = preload("res://Entity/Enemy/EnemyPathFollow.tscn")
var path_follow = null
var path_follow_max_distance = 64.0
enum {
	STATE_PATROL,
	STATE_REVERSE,
	STATE_STOP
}
var state = STATE_PATROL

func _ready():
	get_parent().connect("ready", Callable(self, "_on_parent_ready"))
	_on_state_enter(state)

func _on_parent_ready():
	var potential_path = get_parent()
	if potential_path is Path2D:
		path = potential_path
		path_follow = path_follow_resource.instantiate()
		path.add_child(path_follow)
		path_follow.set_max_speed(max_speed)
		# Get the closest point on the path
		# position used rather than global_position as this is in the curve's local space.
		var f_offset = path.get_curve().get_closest_offset(position)
		# Put the path_follow at that point
		path_follow.progress = f_offset
		path_follow.progress = path_follow.progress + path_follow_max_distance
		global_rotation = get_angle_to(path_follow.get_global_position())

func _physics_process(_delta):
	match state:
		STATE_PATROL:
			var target = path_follow.get_global_position()
			var target_relative_vector = target - global_position
			# Affect path_follow speed
			if target_relative_vector.length() > path_follow_max_distance:
				path_follow.set_speed_multiplier(0.0)
			else:
				path_follow.set_speed_multiplier(1.0)
			# Follow the target
			if is_path_follow_assigned():
				# Calculate velocity and direction
				# Rotate
				var rotation_vector = Vector2(cos(global_rotation), sin(global_rotation))
				var target_relative_angle = rotation_vector.angle_to(target_relative_vector)
				# var rotation_speed = linear_velocity.length() * rotation_factor
				# rotation += min(rotation_speed, target_relative_angle)
				# apply_torque_impulse(target_relative_angle * rotation_factor)
				set_angular_velocity(target_relative_angle * rotation_factor)
				# Accelarate
				var distance_multiplier = clamp((target_relative_vector.length() - 16.0) / 32.0, 0.0, 1.0)
				apply_central_impulse(rotation_vector * acceleration * distance_multiplier)
		STATE_REVERSE:
			var rotation_vector = Vector2(cos(global_rotation), sin(global_rotation))
			apply_central_impulse(rotation_vector.rotated(PI) * reverse_acceleration)

func change_state(p_state):
	_on_state_exit(state)
	state = p_state
	_on_state_enter(p_state)

func _on_state_enter(p_state):
	match p_state:
		STATE_PATROL:
			pass
		STATE_REVERSE:
			path_follow.set_speed_multiplier(0.0)
		STATE_STOP:
			path_follow.set_speed_multiplier(0.0)

func _on_state_exit(p_state):
	match p_state:
		STATE_PATROL:
			pass
		STATE_REVERSE:
			pass

func _on_Enemy_body_entered(body):
	if body is Player:
		var dam = abs(linear_velocity.length()) - 30
		dam = max(dam, 0.0)
		dam *= 0.25
		if (dam > 0.0):
			body.take_damage(dam)
			set_linear_velocity(Vector2(0, 0))
		$AnimationPlayer.stop()
		$AnimationPlayer.play("crash_back_up")

func reverse():
	change_state(STATE_REVERSE)

func stop():
	change_state(STATE_STOP)

func patrol():
	change_state(STATE_PATROL)

func is_path_assigned():
	return path != null

func is_path_follow_assigned():
	return path_follow != null

func _on_CollisionAudio_finished():
	print("collision audio done")
