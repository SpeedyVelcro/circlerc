extends GridContainer
## Settings UI for volume options
##
## Settings UI for volume options, when managed by SV Options Menu.
## [member OptionsConfig.manage_volume] must be enabled, otherwise this
## scene will hide itself.

## Icon displayed by mute buttons when sound is on
@export var mute_button_icon_unmuted: Texture2D:
	set(value):
		mute_button_icon_unmuted = value
		for bus_editor in _bus_editors:
			bus_editor.mute_button_icon_unmuted = value
	get:
		return mute_button_icon_unmuted
## Icon displayed by mute buttons when muted
@export var mute_button_icon_muted: Texture2D:
	set(value):
		mute_button_icon_muted = value
		for bus_editor in _bus_editors:
			bus_editor.mute_button_icon_muted = value
	get:
		return mute_button_icon_muted
## [member Control.custom_minimum_size] for mute buttons.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var mute_button_custom_minimum_size := Vector2(24.0, 24.0):
	set(value):
		mute_button_custom_minimum_size = value
		for bus_editor in _bus_editors:
			bus_editor.mute_button_custom_minimum_size = value
	get:
		return mute_button_custom_minimum_size
## [member Control.expand_icon] for the mute buttons.
@export var mute_button_expand_icon := true:
	set(value):
		mute_button_expand_icon = value
		for bus_editor in _bus_editors:
			bus_editor.mute_button_expand_icon = value
	get:
		return mute_button_expand_icon

var _bus_editor_scene = preload("res://addons/sv_options_menu/ui/volume_settings_ui/bus_editor/bus_editor.tscn") 
var _bus_editors: Array[Control] = []
var _labels: Array[Label] = []

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
		_labels.append(name_label)
		
		var bus_editor: Control = _bus_editor_scene.instantiate()
		bus_editor.bus = config.reference
		bus_editor.mute_button_icon_unmuted = mute_button_icon_unmuted
		bus_editor.mute_button_icon_muted = mute_button_icon_muted
		bus_editor.mute_button_custom_minimum_size = mute_button_custom_minimum_size
		bus_editor.mute_button_expand_icon = mute_button_expand_icon
		bus_editor.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND_FILL
		add_child(bus_editor)
		_bus_editors.append(bus_editor)
