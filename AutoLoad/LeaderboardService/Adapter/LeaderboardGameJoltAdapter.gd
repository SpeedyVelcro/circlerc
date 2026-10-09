class_name LeaderboardGameJoltAdapter
extends LeaderboardBackendAdapter
# TODO: Support guests

# Override
func submit_score(leaderboard: LeaderboardReference, score: int, _formatted_score: String = "") -> LeaderboardSubmitScoreResult:
	if leaderboard == null:
		push_error("Cannot submit to null leaderboard.")
		return LeaderboardSubmitScoreResult.FAILURE
	
	var score_string := str(score) if _formatted_score.is_empty() else _formatted_score
	
	# TODO: Support submitting extra data
	GameJolt.scores_add(score_string, score, leaderboard.game_jolt_id)
	var res: Dictionary = await GameJolt.scores_add_completed
	
	if not _is_response_successful(res):
		push_error("Failed to submit score to Game Jolt. Message: %s" % _get_response_message(res))
		return LeaderboardSubmitScoreResult.FAILURE
	
	# NB: For some reason the addon enforces the table ID type as string
	GameJolt.scores_get_rank(score, str(leaderboard.game_jolt_id))
	var get_rank_res: Dictionary = await GameJolt.scores_get_rank_completed
	
	var rank_error := false
	if not _is_response_successful(get_rank_res):
		push_error("Failed to get rank of score %d from Game Jolt. Message: %s" % [score, _get_response_message(get_rank_res)])
		rank_error = true
	
	if not get_rank_res.has["rank"]:
		push_error("Response from Game Jolt is missing rank.")
		rank_error = true
	
	if get_rank_res["rank"] is not int or get_rank_res["rank"] is not float or get_rank_res["rank"] is not String:
		push_error("Response from Game Jolt for rank is not convertable to int.")
		rank_error = true
	
	if rank_error:
		return LeaderboardSubmitScoreResult.SUCCESS
	else:
		return LeaderboardSubmitScoreResult.create_ranked_success(int(get_rank_res["rank"]))


# Override
func get_scores(leaderboard: LeaderboardReference, from_rank: int = 1, to_rank: int = 10) -> Array[LeaderboardScore]:
	if leaderboard == null:
		push_error("Cannot fetch scores from null leaderboard.")
		return []
	
	GameJolt.scores_fetch(100, leaderboard.game_jolt_id)
	var res: Dictionary = await GameJolt.scores_fetch_completed
	
	if not _is_response_successful(res):
		push_error("Failed to fetch scores from Game Jolt. Message: %s" % _get_response_message(res))
		return []
	
	# This is not documented at all on the Game Jolt side, but take my word for it
	# that, when you are using the API in json format, repeated data is in an array
	# under a key which is just the pluralised form of what you're fetching. In this
	# case "scores".
	if not res.has("scores"):
		# I don't know if this is an error or not to completely omit this key instead
		# of just having an empty array. I'm assuming it's not so I'm just handling
		# it gracefully here as if there are no scores.
		return []
	
	if res["scores"] is not Array:
		push_error("Fetched scores but scores key was not an array.")
		return []
	
	var translate_score := func (res_score: Variant, rank: int) -> LeaderboardScore:
		var leaderboard_score := LeaderboardScore.new()
		leaderboard_score.user = LeaderboardUserGameJolt.new()
		
		leaderboard_score.rank = rank
		
		if res_score is not Dictionary:
			push_error("One of the fetched scores was the wrong type (not a dictionary).")
			return leaderboard_score
		
		if res_score.has("sort") and \
				(res_score["sort"] is int or \
				res_score["sort"] is float or \
				res_score["sort"] is String):
			leaderboard_score.score = int(res_score["sort"])
		
		if res_score.has("user") and \
				res_score["user"] is String:
			leaderboard_score.user.username = res_score["user"]
		
		if res_score.has("user_id") and \
				(res_score["user_id"] is int or \
				res_score["user_id"] is float or \
				res_score["user_id"] is String):
			leaderboard_score.user.id = int(res_score["user_id"])
		
		if res_score.has("guest") and \
				res_score["guest"] is String and \
				(not res_score["guest"].is_empty()):
			leaderboard_score.user.guest = true
			leaderboard_score.user.guest_name = res_score["guest"]
		
		return leaderboard_score
	
	var scores: Array[LeaderboardScore] = []
	
	for i in range(res["scores"]):
		scores.append(translate_score.call(res["scores"][i], i + 1))
	
	if from_rank > scores.size():
		return []
	
	return scores.slice(from_rank - 1, to_rank)


func _is_response_successful(res: Dictionary) -> bool:
	if not res.has("success"):
		return false
	
	if res["success"] is bool:
		return res["success"]
	
	if res["success"] is int or res["success"] is float:
		return bool(res["success"])
	
	if res["success"] is String:
		return res["success"].to_lower() == "true"
	
	return false


func _get_response_message(res: Dictionary) -> String:
	if res.has("message") and res["message"] is String:
		return res["message"]
	
	return ""
