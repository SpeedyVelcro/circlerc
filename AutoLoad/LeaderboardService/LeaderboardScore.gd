class_name LeaderboardScore
extends Resource
## A single score in a leaderboard.
##
## This is a backend-agnostic respresentation of a score. API responses from
## various backends will be converted to this format.

## The user who achieved this score.
@export var user: LeaderboardUser = null

## The score.
@export var score: int = -1

## The position of this score on the leaderboard. If the backend does not
## support getting this data, this will be given as -1.
@export var rank: int = -1
