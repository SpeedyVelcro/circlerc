class_name LeaderboardNewgroundsAdapter
extends LeaderboardBackendAdapter


# TODO: Support tag-based filtering as an alternative to using multiple scoreboards.
# This would probably be done by adding a new newgrounds_tag property on LeaderboardReference


# Override
func submit_score(leaderboard: LeaderboardReference, score: int, _formatted_score: String = "") -> LeaderboardSubmitScoreResult:
	if leaderboard == null:
		push_error("Cannot submit to null leaderboard.")
		return LeaderboardSubmitScoreResult.FAILURE
	
	var res := await NG.scoreboard_submit(leaderboard.newgrounds_id, score)
	
	if res == null:
		push_error("NG.scoreboard_submit() returned null")
		return LeaderboardSubmitScoreResult.FAILURE
	
	# Newgrounds does not respond with - and has no way of easily obtaining - the
	# resulting rank.
	return LeaderboardSubmitScoreResult.SUCCESS


# Override
func get_scores(leaderboard: LeaderboardReference, from_rank: int = 1, to_rank: int = 10) -> Array[LeaderboardScore]:
	if leaderboard == null:
		push_error("Cannot get scores from null leaderboard.")
		return []
	
	var limit := to_rank - (from_rank - 1)
	var skip := from_rank - 1
	var period := "A" # Defined as "all-time" here: https://www.newgrounds.io/help/components/#scoreboard-getscores
	
	var res := await NG.scoreboard_get_scores(leaderboard.newgrounds_id, limit, skip, period)
	
	var translated: Array[LeaderboardScore] = []
	for i in range(res.size()):
		var untranslated_score := res[i]
		
		var score := LeaderboardScore.new()
		
		var user := LeaderboardUserNewgrounds.new()
		if untranslated_score.user != null:
			user.username = untranslated_score.user.name
			user.user_id = untranslated_score.user.id
		else:
			# An absent user property means the active user. Documented here: https://www.newgrounds.io/help/objects/#Score
			# Examining the source code for the jefvel plugin suggests an absent user property is
			# converted to null.
			if NG.session != null and NG.session.user != null:
				user.username = NG.session.user.name
				user.user_id = NG.session.user.id
			else:
				push_error("Error when getting the name and ID of the logged in user for one of their scores.")
				user.username = "YOU (ERROR GETTING USERNAME)"
		
		score.user = user
		score.score = untranslated_score.value
		score.rank = from_rank + skip + i
	
	return translated
