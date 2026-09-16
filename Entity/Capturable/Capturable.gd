# Capturable.gd

extends Area2D

signal captured

@export var active = true

func _on_Loop_complete():
	if active:
		emit_signal("captured")

# Getters and setters
func set_active(value):
	active = value

func is_active():
	return active
