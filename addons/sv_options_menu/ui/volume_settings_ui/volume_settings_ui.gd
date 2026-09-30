extends GridContainer
## Settings UI for volume options
##
## Settings UI for volume options, when managed by SV Options Menu.
## [member OptionsConfig.manage_volume] must be enabled, otherwise this
## scene will hide itself.

## Icon displayed by mute buttons when sound is on
@export var mute_button_icon_unmuted: Texture2D
## Icon displayed by mute buttons when muted
@export var mute_button_icon_muted: Texture2D

var _bus_editor_scene = preload("res://addons/sv_options_menu/ui/volume_settings_ui/bus_editor/bus_editor.tscn") 


# Override
func _ready() -> void:
	if not OptionsConfigProvider.get_config().manage_volume:
		visible = false
	
	_remove_placeholders()
	_populate_controls()


func _remove_placeholders() -> void:
	for node: Node in get_children().filter(func(n: Node): return n.name.begins_with("Placeholder")):
		node.queue_free()


func _populate_controls() -> void:
	for config: EditableBusConfig in OptionsConfigProvider.get_config().editable_buses:
		var name_label := Label.new()
		name_label.text = config.name
		add_child(name_label)
		
		var bus_editor: Control = _bus_editor_scene.instantiate()
		bus_editor.bus = config.reference
		bus_editor.mute_button_icon_unmuted = mute_button_icon_unmuted
		bus_editor.mute_button_icon_muted = mute_button_icon_muted
		bus_editor.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND_FILL
		add_child(bus_editor)
