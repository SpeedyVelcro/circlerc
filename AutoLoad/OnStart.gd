extends Node
## Autoload for on-start functionality
##
## This script should be registered as the final autoload. It can be used
## for all initialization that is required regardless of the main scene (i.e.
## regardless of whether the game was started normally or started through
## "Run Current Scene" through the editor).
##
## Appropriate initialization tasks for this script include loading settings,
## reading secrets, calling init methods on other autoloads, etc. Tasks such
## as choosing the starting scene that are only applicable when running the game
## normally are better done in the main scene.


# Override
func _ready() -> void:
	Profile.load_profile()
