class_name SVAboutUIController
extends Node
## UI Controller for SV About Menu
##
## Place one of these in your scene and assign them to the various UI elements.
## This node primarily handles state management.

## Information about the game, comprising the sections and entries that will
## be displayed in the about menu. You must set this to an [SVAboutGameInfo]
## with at least one entry.
@export var game_info: SVAboutGameInfo:
	set(value):
		game_info = value
		game_info_changed.emit(game_info)
		_update_game_info()
	get:
		return game_info

## Emitted when [member game_info] is changed.
signal game_info_changed(to: SVAboutGameInfo)

## Emitted when the selected entry is changed.
signal selection_changed(to: SVAboutEntry)

var _is_top_level_selected := true

var _selected_top_level_entry: int = 0

var _selected_section := ""

var _selected_section_entry: int = 0


## Selects the given top-level entry.
func select_top_level_entry(index: int) -> void:
	if game_info == null:
		push_error("Game info not set on SV About Menu UI Controller.")
		return
	
	if index >= game_info.top_level_entries.size():
		push_error("Cannot select top-level entry with index %d because index is out of bounds." % index)
		return
	
	_is_top_level_selected = true
	_selected_top_level_entry = index
	selection_changed.emit(game_info.top_level_entries[index])


## Selects the entry with given index in the given section.
func select_section_entry(section: String, index: int) -> void:
	if game_info == null:
		push_error("Game info not set on SV About Menu UI Controller.")
		return
	
	if not game_info.get_sections().keys().has(section):
		push_error("Cannot select \"%s\" because it doesn't exist on the game info." % section)
		return
	
	if index >= game_info.get_sections()[section].entries.size():
		push_error("Cannot select index %d in section \"%s\" because index is out of bounds." % [index, section])
		return
	
	_is_top_level_selected = false
	_selected_section = section
	_selected_section_entry = index
	selection_changed.emit(game_info.get_sections()[section].entries[index])


## Selects the first entry defined on [member game_info].
func select_first_entry() -> void:
	if game_info == null:
		push_error("Game info not set on SV About Menu UI Controller.")
		return
	
	if game_info.top_level_entries.size() > 0:
		select_top_level_entry(0)
		return
	
	for section in game_info.get_sections().keys():
		if game_info.get_sections()[section].entries.size() > 0:
			select_section_entry(section, 0)
			return
	
	push_error("Cannot select first entry as game info has no entries defined.")
	return


## Gets the currently selected entry. Returns null and pushes an error if the
## selection is invalid.
func get_selection() -> SVAboutEntry:
	if game_info == null:
		push_error("Game info not set on SV About Menu UI Controller.")
		return null
	
	if _is_top_level_selected:
		if _selected_top_level_entry >= game_info.top_level_entries.size():
			push_error("Top level selection %d is invalid because it is out of bounds." % _selected_top_level_entry)
			return null
		
		return game_info.top_level_entries[_selected_top_level_entry]
	
	if not game_info.get_sections().keys().has(_selected_section):
		push_error("Selected section \"%s\" does not exist." % _selected_section)
		return null
	
	if _selected_section_entry >= game_info.get_sections()[_selected_section].entries.size():
		push_error("Selected index %d in sections \"%s\" is invalid because index is out of bounds." % [_selected_section_entry, _selected_section])
		return null
	
	return game_info.get_sections()[_selected_section].entries[_selected_section_entry]


func _update_game_info() -> void:
	select_first_entry()
