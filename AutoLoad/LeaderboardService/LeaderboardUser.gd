@abstract class_name LeaderboardUser
extends Resource
## User who participates in the leaderboard.
##
## This is a backend-agnostic representation of a user who participates in the
## leaderboard. Because different backends may have different ways of storing
## their user info (e.g. whether they have an id or if they just use a username),
## this class is abstract and should be extended for each backend.


## Returns a human-readable string that represents the user. Usually this is
## either the username, or a separately configured display name depending on the
## platform.
@abstract func get_display_name() -> String


## Returns true if this and another given [LeaderboardUser] refer to the same
## user.
@abstract func is_same_user(user: LeaderboardUser) -> bool
