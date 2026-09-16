# SceneTransitionPlayer.gd

extends AnimationPlayer

@onready var color_rect = get_node("CanvasLayer/ColorRect")

func _ready():
	# Just in case I was an idiot and forgot to make the ColorRect transparent.
	color_rect.set_visible(false)
