class_name SVAboutSelectedDescriptionLabel
extends RichTextLabel
## Description [Label] for SV About Menu.
##
## Displays the description of the currently selected entry. You must set
## a [member ui_controller].

## Place a [SVAboutUIController] node in your scene and set it here. This is
## required for sharing state between nodes.
@export var ui_controller: SVAboutUIController:
	set(value):
		_disconnect_ui_controller_signal()
		ui_controller = value
		_connect_ui_controller_signal()
		_update_text()
	get:
		return ui_controller


## When this is [code]true[/code], clickable links will open in the browser. (technically
## this uses [method OS.shell_open] so you should only set it to [code]true[/code]
## if you trust the label's contents.)
@export var open_links := false

var _readied := false


func _ready() -> void:
	_readied = true
	_update_text()
	
	meta_clicked.connect(_on_meta_clicked)


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
	scroll_to_line(0)


# Signal connection
func _on_ui_controller_selection_changed(to: SVAboutEntry) -> void:
	_update_text()


# Signal connection
func _on_meta_clicked(meta: Variant) -> void:
	if meta is not String:
		return
	
	if open_links:
		OS.shell_open(meta)


func _connect_ui_controller_signal() -> void:
	if ui_controller == null:
		return
	
	if not ui_controller.selection_changed.is_connected(_on_ui_controller_selection_changed):
		ui_controller.selection_changed.connect(_on_ui_controller_selection_changed)


func _disconnect_ui_controller_signal() -> void:
	if ui_controller == null:
		return
	
	if ui_controller.selection_changed.is_connected(_on_ui_controller_selection_changed):
		ui_controller.selection_changed.disconnect(_on_ui_controller_selection_changed)


# Override
func _exit_tree() -> void:
	_disconnect_ui_controller_signal()
	
	if meta_clicked.is_connected(_on_meta_clicked):
		meta_clicked.disconnect(_on_meta_clicked)
