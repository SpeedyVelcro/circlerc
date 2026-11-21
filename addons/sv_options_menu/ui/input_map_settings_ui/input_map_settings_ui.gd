extends VBoxContainer
## UI for editing input map
##
## UI for editing all events in [InputMap] that have been declared editable in
## [property OptionsConfig.editable_input_actions]

@export_group("Icon Buttons")
## Icon used for the delete button for bindings. Passed down the tree recursively
## to the children that need it.
@export var delete_icon: Texture2D:
	set(value):
		delete_icon = value
		for action_editor in _get_action_editors():
			action_editor.delete_icon = value
	get:
		return delete_icon
## Icon used for the "add" button to create new bindings. Passed to child action
## editors.
@export var add_icon: Texture2D:
	set(value):
		add_icon = value
		for action_editor in _get_action_editors():
			action_editor.add_icon = value
	get:
		return add_icon
## [member Control.custom_minimum_size] for icon buttons such as the add and
## delete buttons.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var icon_button_custom_minimum_size = Vector2(32.0, 32.0):
	set(value):
		icon_button_custom_minimum_size = value
		for action_editor in _get_action_editors():
			action_editor.icon_button_custom_minimum_size = value
	get:
		return icon_button_custom_minimum_size
## [member Control.expand_icon] for icon buttons such as the add and delete
## buttons.
@export var icon_button_expand_icon := true:
	set(value):
		icon_button_expand_icon = value
		for action_editor in _get_action_editors():
			action_editor.icon_button_expand_icon = value
	get:
		return icon_button_expand_icon

var _action_editor_scene = preload("res://addons/sv_options_menu/ui/input_map_settings_ui/action_editor/action_editor.tscn")


# Override
func _ready() -> void:
	_populate_action_editors()


func _populate_action_editors():
	var options_config := OptionsConfigProvider.get_config()
	
	for node: Node in get_children().filter(func (n: Node): return n.name.contains("ActionEditor")):
		node.queue_free()
	
	if not options_config.manage_input_map:
		visible = false
		return
	
	var actions := options_config.editable_input_actions
	
	var i = 0
	for action: String in actions:
		var _action_editor: Control = _action_editor_scene.instantiate()
		_action_editor.name = "ActionEditor%d" % (i + 1) if i > 0 else "ActionEditor"
		_action_editor.action = action
		_action_editor.delete_icon = delete_icon
		_action_editor.add_icon = add_icon
		_action_editor.icon_button_custom_minimum_size = icon_button_custom_minimum_size
		_action_editor.icon_button_expand_icon = icon_button_expand_icon
		add_child(_action_editor)
		
		i += 1


func _get_action_editors() -> Array[Node]:
	return get_children().filter(func (n: Node): return n.name.contains("ActionEditor"))
