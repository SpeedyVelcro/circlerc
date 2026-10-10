class_name LeaderboardUIController
extends Node

## Current page of scores to display. 0-based. A value of -1 means no page is
## being displayed.
##
## Changing this does not make HTTP requests or update any UI elements until
## you call [method update].
@export var page: int = -1

## Number of scores to be displayed on each page.
##
## Changing this does not make HTTP requests or update any UI elements until
## you call [method update].
@export var page_size: int = 10

## Leaderboard to display a page from. Null when no leaderboard is selected.
##
## Changing this does not make HTTP requests or update any UI elements until
## you call [method update].
@export var leaderboard: LeaderboardReference = null

@export var formatter: LeaderboardScoreFormatter = null

var _last_update_page := page
var _last_update_page_size := page_size
var _last_update_leaderboard := leaderboard
var _on_first_page := false
var _on_last_page := false
var _scores: Array[LeaderboardScore]
var _loading: bool

## Emitted when scores should be hidden (i.e. an empty page should be shown).
signal scores_hidden
## Emitted when scores are about to be shown, but before any requests have finished
## and therefore before the score has actually updated. Connecting to this
## allows you to implement a loading UI.
signal started_loading
## Emitted when scores should be shown. The scores to be shown are included as
## a parameter.
signal scores_shown(scores: Array[LeaderboardScore])
## Emitted when a page is shown with no previous pages.
signal reached_first_page
## Emitted when a page is shown with no following pages.
signal reached_last_page
## Emitted when any page in the middle is shown. i.e. it is sandwiched by pages
## both before and after it. It is not the first or last page.
signal reached_middle_page


## Update the leaderboard page displayed. Makes HTTP requests, and emits signals
## to update associated UI elements.
##
## This is a separate method rather than being done automatically on setting
## properties in order to avoid spamming HTTP requests (and possibly causing a
## race condition). Instead, you can set multiple properties and then call this
## method once you're done.
func update() -> void:
	if not has_pending_changes():
		return
	
	_last_update_leaderboard = leaderboard
	_last_update_page = page
	_last_update_page_size = page_size
	
	if page < 0 or page_size <= 0 or leaderboard == null:
		_scores = []
		scores_hidden.emit()
		return
	
	var from_rank := 1 + (page_size * (page - 1))
	var to_rank := 1 + (page_size * page) - 1
	
	_loading = true
	started_loading.emit()
	
	# We get one extra score to see if there's anything on the next page.
	var scores := await LeaderboardService.get_scores(leaderboard, from_rank, to_rank + 1)
	
	_loading = false
	
	var last_page := scores.size() < page_size + 1
	
	_scores = scores.slice(0, page_size)
	
	if _scores.is_empty():
		scores_hidden.emit()
	else:
		scores_shown.emit(_scores)
		_on_first_page = page == 1
		_on_last_page = last_page
		if _on_first_page:
			reached_first_page.emit()
		if _on_last_page:
			reached_last_page.emit()
		if not (_on_first_page or _on_last_page):
			reached_middle_page.emit()


## Returns [code]true[/code] if any properties have been changed since the last
## update and therefore new scores need to be fetched.
func has_pending_changes() -> bool:
	return leaderboard != _last_update_leaderboard \
			or page != _last_update_page \
			or page_size != _last_update_page_size


## Gets the scores on the current page (only updates when [method update] is called).
func get_scores() -> Array[LeaderboardScore]:
	return _scores


## Returns [code]true[/code] if you are on the first page of scores.
func is_on_first_page() -> bool:
	return _on_first_page


## Returns [code]true[/code] if you are on the last page of scores i.e. there aren't
## any more pages to page through.
func is_on_last_page() -> bool:
	return _on_last_page


## Returns [code]false[/code] if you are on the first or last page of scores.
## Returns [code]true[/code] otherwise.
func is_on_middle_page() -> bool:
	return not (_on_first_page or _on_last_page)


func is_hidden() -> bool:
	return _scores.is_empty()


func is_loading() -> bool:
	return _loading


func format_score(score: int) -> String:
	if formatter == null:
		return str(score)
	else:
		return formatter.format_score(score)
