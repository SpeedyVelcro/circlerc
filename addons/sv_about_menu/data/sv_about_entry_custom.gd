class_name SVAboutEntryCustom
extends SVAboutEntry
## Custom entry in SV About Menu
##
## An [SVAboutEntry] for which the developer can specify custom fields.

## The title of the entry. Usually the name of a software component but could
## be something like "About" or "Credits" for more general entries.
@export var title: String = ""

## The contents of the section. Usually license text. You may use BBCode for
## this field.
@export_multiline var description: String = ""


# Override
func get_title() -> String:
	return title


# Override
func get_description() -> String:
	return description
