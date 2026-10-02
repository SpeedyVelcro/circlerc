class_name AchievementList
extends Resource
## A collection of achievements.
##
## An unsorted collection of achievements for the SV Achievements addon. This
## consists of an array and nothing else; it is simply here so you can create a
## loadable resource that can be selected from [ProjectSettings].

## Achievements contained in this AchievementList
@export var achievements: Array[Achievement]
