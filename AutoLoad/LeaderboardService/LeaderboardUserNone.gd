class_name LeaderboardUserNone
extends LeaderboardUser


# Override
func get_display_name() -> String:
	return "Unknown User"


# Override
func is_same_user(_user: LeaderboardUser) -> bool:
	return false
