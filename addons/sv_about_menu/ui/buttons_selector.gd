class_name SVAboutButtonsSelector
extends VBoxContainer
## Buttons selector for SV About Menu
##
## Button-based UI for selecting [SVAboutGameInfo] entries. You must set
## [member ui_controller] to use this node.

## Place a [SVAboutUIController] node in your scene and set it here. This is
## required for sharing state between nodes.
@export var ui_controller: SVAboutUIController:
	set(value):
		ui_controller = value
		_regenerate_children()
	get:
		return ui_controller

## [LabelSettings] to apply to all section title labels.
@export var section_title_label_settings: LabelSettings:
	set(value):
		section_title_label_settings = value
		for label in _section_labels:
			label.label_settings = value
	get:
		return section_title_label_settings

## Horizontal alignment of section title labels.
@export var section_title_horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT:
	set(value):
		section_title_horizontal_alignment = value
		for label in _section_labels:
			label.horizontal_alignment = value
	get:
		return section_title_horizontal_alignment

@export var button_text_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER:
	set(value):
		button_text_alignment = value
		for button in _buttons:
			button.alignment = value

var _section_labels: Array[Label] = []
var _buttons: Array[Button] = []
var _readied := false


# Override
func _ready() -> void:
	_readied = true
	_regenerate_children()


func _regenerate_children() -> void:
	if not _readied:
		return
	
	_clear_children()
	
	if ui_controller == null:
		push_error("UI controller not set on buttons selector.")
		return
	
	var game_info := ui_controller.game_info
	
	if game_info == null:
		push_error("Cannot generate buttons selector children. Game info is not set on UI controller.")
		return
	
	for i in range(game_info.top_level_entries.size()):
		var entry = game_info.top_level_entries[i]
		
		var button := Button.new()
		add_child(button)
		_buttons.append(button)
		
		button.clip_text = true
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = entry.get_title()
		button.alignment = button_text_alignment
		
		button.pressed.connect(_on_top_level_button_pressed.bindv([i]))
	
	var sections := game_info.get_sections()
	
	for section in sections.keys():
		var label := Label.new()
		add_child(label)
		_section_labels.append(label)
		
		label.text = section
		label.label_settings = section_title_label_settings
		label.horizontal_alignment = section_title_horizontal_alignment
		
		var entries := sections[section].entries
		
		for i in range(entries.size()):
			var entry = entries[i]
			
			var button := Button.new()
			add_child(button)
			_buttons.append(button)
			
			button.clip_text = true
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.text = entry.get_title()
			button.alignment = button_text_alignment
			
			button.pressed.connect(_on_section_button_pressed.bindv([section, i]))

func _clear_children() -> void:
	_disconnect_signals()
	
	for child in get_children():
		child.queue_free()
	
	_section_labels = []
	_buttons = []


# Signal connection
func _on_top_level_button_pressed(index: int) -> void:
	if ui_controller == null:
		push_error("UI controller not set on button selector.")
		return
	
	ui_controller.select_top_level_entry(index)


# Signal connection
func _on_section_button_pressed(section: String, index: int) -> void:
	if ui_controller == null:
		push_error("UI controller not set on button selector.")
		return
	
	ui_controller.select_section_entry(section, index)


func _disconnect_signals() -> void:
	# Don't ask me how it works but apparently get_incoming_connections() also
	# returns connections to callables created using .bindv() on this object's
	# methods.
	for connection in get_incoming_connections():
		connection["signal"].disconnect(connection["callable"])


# Override
func _exit_tree() -> void:
	_disconnect_signals()
