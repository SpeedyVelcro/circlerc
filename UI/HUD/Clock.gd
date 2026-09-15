# Clock.gd

extends Control

var minutes = 0
var seconds = 0
var centiseconds = 0

func set_time(time_centisec):
	centiseconds += time_centisec
	while centiseconds >= 100:
		centiseconds -= 100
		seconds += 1
	while seconds >= 60:
		seconds -= 60
		minutes += 1
	update_text()

func update_text():
	var str_min = str(floor(minutes)).pad_zeros(2)
	var str_sec = str(floor(seconds)).pad_zeros(2)
	var str_cent = str(floori(centiseconds)).pad_zeros(2)
	$Label.set_text(str_min + ":" + str_sec + ":" + str_cent)

func finalise():
	$Label.label_settings.font_color = Color.GREEN
