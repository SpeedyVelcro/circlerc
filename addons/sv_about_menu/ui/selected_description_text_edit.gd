class_name SVAboutSelectedDescriptionTextEdit
extends TextEdit
## Description [TextEdit] for SV About Menu.
##
## Displays the description of the currently selected entry. You must set
## a [member ui_controller].
##
## This isn't very useful if you use BBCode. Use a [SVAboutSelectedDescriptionLabel]
## instead, and turn on [member RichTextLabel.selection_enabled].

## Place a [SVAboutUIController] node in your scene and set it here. This is
## required for sharing state between nodes.
@export var ui_controller: SVAboutUIController:
	set(value):
		_disconnect_signals()
		ui_controller = value
		_connect_signals()
		_update_text()
	get:
		return ui_controller

var _readied := false


func _ready() -> void:
	_readied = true
	_update_text()


func _update_text() -> void:
	if not _readied:
		return
	
	if ui_controller == null:
		push_error("UI controller not set on selected description label.")
		return
	
	var selection = ui_controller.get_selection()
	
	if selection == null:
		push_error("Selected description label cannot display description as there is no valid selection.")
		return
	
	text = selection.get_description()
	scroll_vertical = 0


# Signal connection
func _on_ui_controller_selection_changed(to: SVAboutEntry) -> void:
	_update_text()


func _connect_signals() -> void:
	if ui_controller == null:
		return
	
	if not ui_controller.selection_changed.is_connected(_on_ui_controller_selection_changed):
		ui_controller.selection_changed.connect(_on_ui_controller_selection_changed)


func _disconnect_signals() -> void:
	if ui_controller == null:
		return
	
	if ui_controller.selection_changed.is_connected(_on_ui_controller_selection_changed):
		ui_controller.selection_changed.disconnect(_on_ui_controller_selection_changed)


# Override
func _exit_tree() -> void:
	_disconnect_signals()
