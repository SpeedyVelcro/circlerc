@abstract class_name AchievementSyncAdapter
extends Node
## Abstract adapter for SV Achievements sync functionality.
##
## This class should be extended in order to adapt the achievements API (e.g.
## Steam, Newgrounds, GameJolt etc.) that you want to synchronize with SV
## Achievements. You should then set your new class in [ProjectSettings] to
## tell SV Achievements to use it.


## API-specific implementation of overwriting the backend's completion status
## with that of the achievement. Override this method.
@abstract func sync_one_way(achievement: Achievement) -> void 


## API-specific implementation of two-way sync, where out of the backend and
## achievement, the most complete completion status is used. Override this
## method.
@abstract func sync_two_way(achievement: Achievement) -> void


## Synchronize all of the given achievements. By default this just calls
## [method one_way_sync] on each achievement iteratively, but if your API has a more
## performant implementation you may wish to override this method.
func one_way_sync_multiple(achievements: Array[Achievement]) -> void:
	for achievement in achievements:
		sync_one_way(achievement)


## Synchronize all of the given achievements two-way. By default this just calls
## [method one_way_sync] on each achievement iteratively, but if your API has a more
## performant implementation you may wish to override this method.
func two_way_sync_multiple(achievements: Array[Achievement]) -> void:
	for achievement in achievements:
		sync_two_way(achievement)
