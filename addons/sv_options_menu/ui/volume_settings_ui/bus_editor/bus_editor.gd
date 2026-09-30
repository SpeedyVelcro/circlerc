extends HBoxContainer
## User interface for editing audio bus volume
##
## User interface for editing the volume and mute/unmute status of a single
## audio bus.

## Audio bus this user interface controls
@export var bus: AudioBusReference
## Icon displayed by the mute button when sound is on
@export var mute_button_icon_unmuted: Texture2D
## Icon displayed by the mute button when muted
@export var mute_button_icon_muted: Texture2D

var _level: int:
	get:
		return round(_volume_slider.value)
	set(value):
		_volume_slider.set_value_no_signal(value)
@onready var _mute_button: Button = $MuteButton
@onready var _level_label: Label = $LevelLabel
@onready var _volume_slider: Slider = $VolumeSlider


# Override
func _ready() -> void:
	# Ensure that label does not shrink when volume level is lower than 100,
	# so that the sliders don't go out of alignment.
	_level_label.text = "100"
	_level_label.update_minimum_size()
	_level_label.custom_minimum_size.x = _level_label.get_minimum_size().x
	
	if bus == null:
		push_warning("Audio bus must be set for bus editor to work properly")
		return
	
	# TODO: better to do this on bus reference setget in case it's set after ready
	var level_percent = _get_bus_volume_percent()
	var mute_status = _get_bus_mute_status()
	
	_volume_slider.set_value_no_signal(level_percent)
	_level_label.text = str(level_percent)
	
	_mute_button.set_pressed_no_signal(mute_status)
	_set_mute_button_texture(mute_status)


func _get_bus_volume_percent() -> int:
	if bus is not AudioBusReference:
		push_error("Bus editor tried to get volume but audio bus wasn't set.")
		return 100
	
	return round(AudioServer.get_bus_volume_linear(bus.get_id()) * 100)


func _set_bus_volume_percent(value: int) -> void:
	if bus is not AudioBusReference:
		push_error("Bus editor tried to set volume but audio bus wasn't set.")
		return
	
	AudioServer.set_bus_volume_linear(bus.get_id(), float(value) / 100.0)


func _get_bus_mute_status() -> bool:
	if bus is not AudioBusReference:
		push_error("Bus editor tried to get mute status but audio bus wasn't set.")
		return false
	
	return AudioServer.is_bus_mute(bus.get_id())


func _set_bus_mute_status(value: bool) -> void:
	if bus is not AudioBusReference:
		push_error("Bus editor tried to set mute status but audio bus wasn't set.")
		return
	
	AudioServer.set_bus_mute(bus.get_id(), value)


func _set_mute_button_texture(mute_status: bool) -> void:
	_mute_button.icon = mute_button_icon_muted if mute_status else mute_button_icon_unmuted


# Signal connection
func _on_mute_button_toggled(toggled_on: bool) -> void:
	_set_bus_mute_status(toggled_on)
	_set_mute_button_texture(toggled_on)
	
	var options_config := OptionsConfigProvider.get_config()
	var options := OptionsProvider.get_cloud_options() if options_config.volume_cloud_sync else OptionsProvider.get_local_options()
	
	options.set_option_by_keys(options_config.get_audio_bus_mute_path(bus), toggled_on)


# Signal connection
func _on_volume_slider_value_changed(value: float) -> void:
	var percent: int = round(value)
	_level_label.text = str(percent)
	
	if bus is not AudioBusReference:
		push_error("Player tried to set volume, but the bus editor did not have its audio bus set.")
		return
	
	_set_bus_volume_percent(percent)
	# This function is called every frame, so don't waste CPU by setting the value on our game options yet


# Signal connection
func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
	
	var options_config := OptionsConfigProvider.get_config()
	var options := OptionsProvider.get_cloud_options() if options_config.volume_cloud_sync else OptionsProvider.get_local_options()
	
	var percent: int = round(_volume_slider.value)
	var linear := _volume_slider.value / 100.0
	
	options.set_option_by_keys(options_config.get_audio_bus_volume_path(bus), linear)
