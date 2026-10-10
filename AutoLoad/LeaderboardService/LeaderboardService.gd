extends Node
## Backend-agnostic service for interacting with leaderboards.
##
## This is a singleton (to be autoloaded) that provides methods for getting and
## submitting scores. Please note that this may have some limitations depending
## on which backend you are using.
##
## Newgrounds limitations:
## - You cannot get the position of an arbitrary score (although this service
##   will automatically enumerate the positions of scores when using [method get_scores])
##
## Game Jolt limitations:
## - [method get_scores] cannot get scores starting from an arbitrary rank. The
##   backend only supports skipping to an arbitrary score, which prevents
##   reliably paging through scores. Instead, get_scores() will get
##   the maximum number of scores from 0 (that is, the first 100 scores), and
##   then this will be treated as the entire leaderboard which you can page
##   through as normal. You will therefore not be able to page past score 100.

enum Backend {
	NONE,
	NEWGROUNDS,
	GAME_JOLT
}

var backend: Backend = Backend.NONE:
	set(value):
		backend = value
		match value:
			Backend.NONE:
				_backend_adapter = null
			Backend.NEWGROUNDS:
				_backend_adapter = LeaderboardNewgroundsAdapter.new()
			Backend.GAME_JOLT:
				_backend_adapter = LeaderboardGameJoltAdapter.new()
	get:
		return backend

var _backend_adapter: LeaderboardBackendAdapter = null


## Get scores from the given leaderboard, starting from the given rank (1-based, inclusive),
## to the given rank (inclusive). If you reach the end of the scoreboard, an empty array
## is returned.
func get_scores(leaderboard: LeaderboardReference, from_rank: int = 1, to_rank: int = 10) -> Array[LeaderboardScore]:
	if backend == Backend.NONE:
		return []
	
	@warning_ignore("redundant_await") # Not detected as a coroutine because it's an abstract. https://github.com/godotengine/godot/issues/110961
	return await _backend_adapter.get_scores(leaderboard, from_rank, to_rank)


## Submits the given score. Return true if successful. Some platforms require
## you to format the score on the frontend (e.g. Game Jolt). For these platforms,
## the value of [param formatted_score] will be used, unless it is an empty
## string, in which case the score will just be converted directly to a string.
func submit_score(leaderboard: LeaderboardReference, score: int, formatted_score: String = "") -> LeaderboardSubmitScoreResult:
	if backend == Backend.NONE:
		return LeaderboardSubmitScoreResult.FAILURE
	
	@warning_ignore("redundant_await") # Not detected as a coroutine because it's an abstract. https://github.com/godotengine/godot/issues/110961
	return await _backend_adapter.submit_score(leaderboard, score, formatted_score)


## Gets the current user (i.e. the logged-in user, or the user who is submitting
## scores).
func get_current_user() -> LeaderboardUser:
	if backend == Backend.NONE:
		return LeaderboardUserNone.new()
	
	return _backend_adapter.get_current_user()


## Returns [code]true[/code] if leaderboards are supported in this platform. This
## basically only returns [code]false[/code] if you set [member backend] to
## [enum Backend.NONE].
##
## This only guarantees that fetching scores is supproted. To check if submitting
## scores is supported, call [method can_submit].
func is_supported() -> bool:
	return _backend_adapter != null


## Returns [code]true[/code] if backend supports submitting scores and it is
## currently ready to submit scores (e.g. you might need to be logged in).
func can_submit() -> bool:
	return (_backend_adapter != null) and (_backend_adapter.can_submit())
