class_name SVAboutEntries
extends Resource
## Wrapper for an [Array] of [SVAboutEntry].
##
## This class is only here as a workaround for a lack of nested typed
## collections in Godot.

## Wrapped entries array.
@export var entries: Array[SVAboutEntry] = []
