@abstract
class_name SVAboutEntry
extends Resource
## An entry in SV About Menu
##
## A single entry in the about menu; usually a software component and its
## license, but could also be something like the game's credits.


@abstract
## Returns the title of this entry. Usually the name of a software component,
## but it may be something like "About" or "Credits" for more general entries.
func get_title() -> String

@abstract
## Returns the description of this entry. Usually license text. May be BBCode
## formatted.
func get_description() -> String
