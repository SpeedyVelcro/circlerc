class_name LeaderboardUserGameJolt
extends LeaderboardUser

## Whether this user is a guest
@export var guest: bool = false

## The username (only used if not a guest)
@export var username: String = ""

## The user ID (only used if not a guest)
@export var user_id: String = ""

## The guest's submitted name (Only used if this is a guest)
@export var guest_name: String = ""


# Override
func get_display_name() -> String:
	return guest_name if guest else username


# Override
func is_same_user(user: LeaderboardUser) -> bool:
	if user is not LeaderboardUserGameJolt:
		return false
	
	if guest or user.guest:
		# I reckon guests are inherently unique since there's no persistence
		# between sessions. Though I haven't found documentation to confirm this.
		return false
	
	# Game Jolt API requires a separate request (using the users fetch endpoint)
	# to get the user ID. It is not stored in the plugin, and it is not returned
	# by the auth endpoint either. Doing this would be complicated and the username
	# appears to be unique anyway (frankly I'm not even sure why the user ID
	# exists) so we only check on user IDs if we have them both.
	if user_id.is_empty() or user.user_id.is_empty():
		return username == user.username
	else:
		return user_id == user.user_id
