class_name LeaderboardUserNewgrounds
extends LeaderboardUser

@export var username: String = ""

@export var user_id: int = -1


# Override
func get_display_name() -> String:
	if username.is_empty():
		if user_id < 0:
			push_error("Score did not have any valid information for user. Displaying ERROR GETTING USER instead.")
			return "ERROR GETTING USER"
		
		push_error("Score did not have a valid username for Newgrounds user with ID %d" % user_id)
		return "User ID: %d" % user_id
	
	return username


# Override
func is_same_user(user: LeaderboardUser) -> bool:
	if user is not LeaderboardUserNewgrounds:
		return false
	
	if user_id < 0:
		return false
	
	if user.id < 0:
		return false
	
	return user_id == user.user_id
