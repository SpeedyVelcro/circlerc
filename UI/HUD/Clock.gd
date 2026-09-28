# Clock.gd

extends Control


func _ready() -> void:
	$Label.label_settings = $Label.label_settings.duplicate() # We will be making changes to some label settings properties


func set_time(time: TimeScore):
	$Label.set_text(time.get_display_string())


func finalise():
	$Label.label_settings.font_color = Color.GREEN
