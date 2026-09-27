class_name SVAboutEntryGodot
extends SVAboutEntry
## Entry in SV About Menu for the Godot Engine
##
## An [SVAboutEntry] that uses [method Engine.get_license_text] for its
## description. Note that this doesn't include licenses for all of Godot's
## third-party licenses. For those, consider using
## [member SVAboutGameInfo.include_godot_copyright_info].


## Puts the name of the engine ("Godot Engine") at the beginning of the
## description, before the copyright notice. 
##
## Useful for making it clear what the license is for, in-case the way you
## arranged your UI elements doesn't.
@export var prepend_engine_name_to_description := false


# Override
func get_title() -> String:
	return "Godot Engine"


# Override
func get_description() -> String:
	if not prepend_engine_name_to_description:
		return Engine.get_license_text()
	
	return "Godot Engine\n\n" + Engine.get_license_text()
