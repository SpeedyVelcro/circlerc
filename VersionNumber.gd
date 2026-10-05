class_name VersionNumber
extends Object
## Helper class for getting version number
##
## Use VersionNumber.value to get a [String] representing the version number -
## or lack thereof - of the project.

## Version number [String] based on [ProjectSettings].
static var value: String:
	get:
		var version_number = ProjectSettings.get_setting_with_override("application/config/version")
		if version_number == null or version_number is not String or version_number.is_empty():
			push_warning("Version number is not set in this build.")
			return "Unknown Version"
		elif version_number == "dev":
			return "Development Version"
		else:
			return version_number
