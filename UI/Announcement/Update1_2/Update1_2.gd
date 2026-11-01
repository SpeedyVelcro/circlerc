extends Control


# Override
func _ready() -> void:
	$AnimationPlayer.play("main")


func end() -> void:
	get_tree().quit()
