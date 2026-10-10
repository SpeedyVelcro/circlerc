@abstract class_name LeaderboardBackendAdapter
extends Object


@abstract func submit_score(leaderboard: LeaderboardReference, score: int, formatted_score: String = "") -> LeaderboardSubmitScoreResult


@abstract func get_scores(leaderboard: LeaderboardReference, from_rank: int = 1, to_rank: int = 10) -> Array[LeaderboardScore]


@abstract func get_current_user() -> LeaderboardUser


@abstract func can_submit() -> bool
