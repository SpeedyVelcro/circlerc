class_name SVAboutGameInfo
extends Resource
## All information to be displayed in SV About Menu.
##
## Top-level data structure that contains all the information about the game
## to be displayed in SV About Menu

## Entries displayed at the top level. Typically this should be general info
## such as an "About" entry displaying the main license and copyright notice,
## and/or a traditional "Credits" entry.
@export var top_level_entries: Array[SVAboutEntry] = []

## Titled sections containing multiple entries. You may, for example, have a
## "Third-Party Licenses" section, and/or maybe an "Assets" section.
##
## This variable only contains developer-defined sections. For auto-generated
## sections (currently just the one when [member include_godot_copyright_info]
## is [code]true[/code]), use [method get_sections].
@export var custom_sections: Dictionary[String, SVAboutEntries] = {}

# TODO: verify whether this includes the main Godot Engine license. If not,
# the section needs to be renamed to "Godot Engine Components" and a note
# would need to be added to this doc comment to advise the user to add the Godot
# license themselves.
## Include all licenses returned by [method Engine.get_copyright_info] when
## displaying this game info. This will be included in its own "Godot Engine"
## section.
@export var include_godot_copyright_info := true

## Title to use for the section generated if [member include_godot_copyright_info]
## is [code]true[/code].
@export var godot_copyright_info_section_title := "Godot Engine"

## When generating entries with [member include_godot_copyright_info] set to
## [code]true[/code], prepends the name of the component before the copyright
## notice.
##
## Depending on how you arrange your UI, this might be useful to make which
## component the license applies to clearer.
@export var godot_copyright_info_entries_start_with_name := false

## If [member include_godot_copyright_info] is [code]true[/code], then you can
## put component titles into this array to exclude them from the auto-generated
## section. Strings are case-sensitive and must match exactly.
##
## One use for this would be to remove the [code]"Godot Engine"[/code] component
## from the auto-generated section so you can instead put the Godot Engine
## license in a section for components used directly by your game.
@export var godot_copyright_info_excludes: Array[String] = []


## Get all sections, including both those defined in [member custom_sections]
## and any auto-generated ones.
func get_sections() -> Dictionary[String, SVAboutEntries]:
	var sections: Dictionary[String, SVAboutEntries] = custom_sections.duplicate()
	
	# TODO: That's a lot of string concatenation, might want to cache this.
	if include_godot_copyright_info:
		var entries_wrapper := SVAboutEntries.new()
		var info := Engine.get_copyright_info()
		for component in info:
			if godot_copyright_info_excludes.has(component.name):
				continue
			
			var entry := SVAboutEntryCustom.new()
			entry.title = component.name
			if godot_copyright_info_entries_start_with_name:
				entry.description = component.name + "\n\n"
			
			# Specifying file paths is not necessary here as this is
			# aimed at players of the compiled game binary, not Godot developers.
			# therefore we can omit the info in part["files"].
			var display_files := false
			if component.parts.size() > 1:
				# HOWEVER, if there are multiple copyright notices, we do need those
				# in order to distinguish the copyright notices.
				display_files = true
			for part in component.parts:
				if display_files and part["files"].size() == 1:
					entry.description += "Files: " + part["files"][0] + "\n"
				if display_files and part["files"].size() > 1:
					entry.description += "Files:\n"
					for line in part["files"]:
						entry.description += line + "\n"
					entry.description += "\n"
				for copyright in part["copyright"]:
					entry.description += "Copyright © " + copyright + "\n"
				if part["copyright"].size() > 0:
					entry.description += "\n"
				var license_info := Engine.get_license_info()
				if license_info.has(part["license"]):
					entry.description += license_info[part["license"]]
				else:
					# This component likely has multiple licenses so we'll have to check
					# which licenses the string contains.
					entry.description += "Licenses: " + part["license"] + "\n\n"
					for license in license_info.keys():
						if part["license"].contains(license):
							entry.description += license + " license:\n" + license_info[license] + "\n\n"
			entries_wrapper.entries.append(entry)
		sections[godot_copyright_info_section_title] = entries_wrapper
	
	return sections
