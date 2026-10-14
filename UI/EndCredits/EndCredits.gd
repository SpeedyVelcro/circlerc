extends Control

@export var left_particles: CPUParticles2D
@export var right_particles: CPUParticles2D
@export var credits_label: RichTextLabel
@export var confetti_cannon_audio_stream_player: AudioStreamPlayer

var _credits_scrolling := false
var _credits_scroll_speed: float = 24.0
var _game_info: SVAboutGameInfo = preload("res://GameInfo.tres")


func _ready() -> void:
	var _credits_text := _game_info.top_level_entries[1].get_description()
	if _credits_text is String and not _credits_text.is_empty():
		credits_label.text = _credits_text


func _process(delta: float) -> void:
	if _credits_scrolling:
		credits_label.offset_transform_position.y -= _credits_scroll_speed * delta


# Signal connection
func _on_particles_delay_timer_timeout() -> void:
	left_particles.emitting = true
	right_particles.emitting = true
	confetti_cannon_audio_stream_player.play()


# Signal connection
func _on_credits_delay_timer_timeout() -> void:
	_credits_scrolling = true


# Signal connection
func _on_menu_button_pressed() -> void:
	SceneTransition.fade("res://UI/MainMenu/MainMenu.tscn")
