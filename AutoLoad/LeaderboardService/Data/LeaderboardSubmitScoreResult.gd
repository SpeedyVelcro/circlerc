class_name LeaderboardSubmitScoreResult
extends Object

static var FAILURE: LeaderboardSubmitScoreResult:
	get:
		return LeaderboardSubmitScoreResult.new(false, -1)

static var SUCCESS: LeaderboardSubmitScoreResult:
	get:
		return LeaderboardSubmitScoreResult.new(true, -1)

## Whether submitting the score was successful.
var success: bool

## New rank. -1 if the backend does not support this data.
var rank: int


# Override
func _init(p_success: bool, p_rank: int) -> void:
	self.success = p_success
	self.rank = p_rank


static func create_ranked_success(p_rank: int) -> LeaderboardSubmitScoreResult:
	return LeaderboardSubmitScoreResult.new(true, p_rank)
