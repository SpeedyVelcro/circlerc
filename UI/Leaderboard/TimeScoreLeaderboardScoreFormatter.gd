class_name TimeScoreLeaderboardScoreFormatter
extends LeaderboardScoreFormatter


func format_score(score: int) -> String:
	return TimeScore.deserialize(score).get_display_string()
