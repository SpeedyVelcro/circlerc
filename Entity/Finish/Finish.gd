# Finish.gd

extends StaticBody2D

var finish_condition = true
var pip_target = 0
var pips_captured = 0

signal activated

func _ready():
	var pips = get_tree().get_nodes_in_group("pip")
	if pips.size() > 0:
		finish_condition = false
		$AnimatedSprite2D.play("down")
		$Capturable.set_active(false)
		for pip in pips:
			pip.connect("collected", Callable(self, "_on_Pip_collected").bind(), CONNECT_ONE_SHOT)
			pip_target += 1
	else:
		finish_condition = true
		$AnimatedSprite2D.play("wave")
		$Capturable.set_active(true)

func _on_Pip_collected():
	pips_captured += 1
	if pips_captured >= pip_target:
		finish_condition = true
		$Capturable.set_active(true)
		$AnimatedSprite2D.play("hoist")

func _on_Capturable_captured():
	emit_signal("activated")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite2D.get_animation() == "hoist":
		$AnimatedSprite2D.play("wave")
