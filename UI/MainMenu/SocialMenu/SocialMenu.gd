extends MarginContainer


# Signal connection
func _on_git_hub_button_pressed() -> void:
	OS.shell_open("https://github.com/SpeedyVelcro/circlerc")


# Signal connection
func _on_website_button_pressed() -> void:
	OS.shell_open("https://speedyvelcro.com/")


# Signal connection
func _on_x_button_pressed() -> void:
	OS.shell_open("https://x.com/SpeedyVelcro")


# Signal connection
func _on_blue_sky_button_pressed() -> void:
	OS.shell_open("https://bsky.app/profile/speedyvelcro.bsky.social")


# Signal connection
func _on_mastodon_button_pressed() -> void:
	OS.shell_open("https://mastodon.social/@SpeedyVelcro")


# Signal connection
func _on_threads_button_pressed() -> void:
	OS.shell_open("https://www.threads.com/@speedyvelcro")


# Signal connection
func _on_instagram_button_pressed() -> void:
	OS.shell_open("https://www.instagram.com/speedyvelcro/")


func _on_tumblr_button_pressed() -> void:
	OS.shell_open("https://www.tumblr.com/speedyvelcro")


func _on_you_tube_button_pressed() -> void:
	OS.shell_open("https://www.youtube.com/channel/UCYLhMt9H_Y7x1b0BGkkXJiA")
