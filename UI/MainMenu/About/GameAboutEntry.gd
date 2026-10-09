class_name GameAboutEntry
extends SVAboutEntry

## Text to be displayed after the version number.
@export_multiline var text := ""


# Override
func get_title() -> String:
	return _get_game_name()


# Override
func get_description() -> String:
	return _get_game_name() + " " + VersionNumber.value + "\n\n" + text


func _get_game_name() -> String:
	return ProjectSettings.get_setting_with_override("application/config/name")
