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
	var int_cent = int(centiseconds)
	var str_min = String(floor(minutes)).pad_zeros(2)
	var str_sec = String(floor(seconds)).pad_zeros(2)
	var str_cent = String(floor(centiseconds)).pad_zeros(2)
	$Label.set_text(str_min + ":" + str_sec + ":" + str_cent)

func finalise():
	$Label.set("theme_override_colors/font_color", Color.GREEN)
