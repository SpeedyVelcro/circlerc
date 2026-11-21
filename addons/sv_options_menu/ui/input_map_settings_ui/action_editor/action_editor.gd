extends VBoxContainer
## Editor for an input map action
##
## UI for editing one input map action. Displays the name and allows you to
## modify, add, and delete input events.

## The [InputMap] action that this ActionEditor edits. The value should be
## the same as one of the actions returned by [method InputMap.get_actions].
@export var action: String = "":
	set(value):
		action = value
		_update_label()
		_populate_input_event_editors()
	get:
		return action

@export_group("Icon Buttons")
## Icon used for the delete button on each input event. Passed down to
## each input event editor.
@export var delete_icon: Texture2D:
	set(value):
		delete_icon = value
		_update_input_event_editor_delete_icons()
	get:
		return delete_icon
## Icon used for the add button (the button that adds new input events to
## the action).
@export var add_icon: Texture2D:
	set(value):
		add_icon = value
		_update_add_icon()
	get:
		return add_icon
## [member Control.custom_minimum_size] for icon buttons such as the add and
## delete buttons.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var icon_button_custom_minimum_size = Vector2(32.0, 32.0):
	set(value):
		icon_button_custom_minimum_size = value
		_update_icon_button_custom_minimum_size()
	get:
		return icon_button_custom_minimum_size
## [member Button.expand_icon] for icon buttons such as the add and delete
## buttons.
@export var icon_button_expand_icon := true:
	set(value):
		icon_button_expand_icon = value
		_update_icon_button_expand_icon()
	get:
		return icon_button_expand_icon

@onready var _label: Label = $Label
@onready var _input_event_container: Control = $HFlowContainer
@onready var _add_button: Button = $HFlowContainer/AddButton

var _input_event_editor_scene = preload("res://addons/sv_options_menu/ui/input_map_settings_ui/action_editor/event_editor/input_event_editor.tscn")
var _name_counter: int

# Override
func _ready() -> void:
	_update_label()
	_populate_input_event_editors()
	# _update_input_event_editor_delete_icons() # Not necessary as icons were set on populate
	_update_add_icon()


func _update_label():
	# TODO: Should support controller glyphs
	if _label == null:
		return # Not ready yet. Fail silently because this method will be re-run in _ready() anyway
	
	var options_config := OptionsConfigProvider.get_config()
	
	if options_config.input_action_labels.has(action):
		_label.text = options_config.input_action_labels[action]
	else:
		_label.text = action.capitalize()


func _update_input_event_editor_delete_icons() -> void:
	for editor: Node in _get_input_event_editors():
		editor.delete_icon = delete_icon


func _update_add_icon() -> void:
	if _add_button == null:
		return
	
	_add_button.icon = add_icon


func _update_icon_button_custom_minimum_size() -> void:
	if _add_button == null:
		return # Not ready yet
	
	_add_button.custom_minimum_size = icon_button_custom_minimum_size
	for input_event_editor in _get_input_event_editors():
		input_event_editor.delete_button_custom_minimum_size = icon_button_custom_minimum_size


func _update_icon_button_expand_icon() -> void:
	if _add_button == null:
		return # Not ready yet
	
	for input_event_editor in _get_input_event_editors():
		input_event_editor.delete_button_expand_icon = icon_button_expand_icon
		input_event_editor.binding_button_expand_icon = icon_button_expand_icon


func _populate_input_event_editors():
	if _input_event_container == null:
		return # Not ready yet. Fail silently because this method will be re-run in _ready() anyway
	
	var options_config := OptionsConfigProvider.get_config()
	
	for node: Node in _get_input_event_editors():
		node.queue_free()
	
	if not InputMap.has_action(action):
		if not name.contains("Placeholder"):
			push_error("Action %s does not exist on the input map. Action editor will not work." % action)
		_label.text = "INVALID ACTION"
		return
	
	var events := InputMap.action_get_events(action)
	
	for event: InputEvent in events:
		# TODO: DRY
		var _input_event_editor: Control = _input_event_editor_scene.instantiate()
		_input_event_editor.name = "InputEventEditor%d" % (_name_counter + 1) if _name_counter > 0 else "InputEventEditor"
		_input_event_editor.action = action
		_input_event_editor.input_event = event
		_input_event_editor.delete_icon = delete_icon
		_input_event_editor.delete_button_custom_minimum_size = icon_button_custom_minimum_size
		_input_event_editor.delete_button_expand_icon = icon_button_expand_icon
		_input_event_editor.binding_button_expand_icon = icon_button_expand_icon
		if options_config.locked_input_events.has(action):
			if options_config.locked_input_events[action].locked_events.any(func (e: InputEvent): return e.as_text() == event.as_text()):
				_input_event_editor.locked = true # TODO: the string comparison to check if we do this: is it robust enough?
		_input_event_container.add_child(_input_event_editor)
		
		_name_counter += 1
	
	_add_button.get_parent().move_child(_add_button, -1)


func _get_input_event_editors() -> Array[Node]:
	if _input_event_container == null:
		return []
	
	return _input_event_container.get_children().filter(func (n: Node): return n.name.contains("InputEventEditor"))


func _on_add_button_pressed() -> void:
	# TODO: DRY
	var _input_event_editor: Control = _input_event_editor_scene.instantiate()
	_input_event_editor.name = "InputEventEditor%d" % (_name_counter + 1) if _name_counter > 0 else "InputEventEditor"
	_input_event_editor.action = action
	_input_event_editor.delete_icon = delete_icon
	_input_event_editor.delete_button_custom_minimum_size = icon_button_custom_minimum_size
	_input_event_editor.delete_button_expand_icon = icon_button_expand_icon
	_input_event_editor.binding_button_expand_icon = icon_button_expand_icon
	_input_event_container.add_child(_input_event_editor)
	_input_event_editor.listen()
	
	_name_counter += 1
	_add_button.get_parent().move_child(_add_button, -1)
	
	# We do not need to update the input map or GameOptions here. The input event
	# is not set until the player presses a key (which the input event editor is
	# now listening for), so updating the InputMap etc. is the responsibility of
	# the InputEventEditor itself.
