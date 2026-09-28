class_name TimeScore
extends Resource
## A timestamp representing a time trial score.
##
## This timestamp measures to millisecond precision (though actual gameplay may
## be less precise due to process framerate). As a time trial score, it errs on
## the side of caution by rounding up when collapsing to a specific unit
## (using the [code]get_total_x()[/code] methods). Thus, players are not
## advantaged by favourable rounding.


var _milliseconds: int = 0
var _none: bool = false

## Timestamp that always returns the maximum value. You can use this for
## comparison when no score has been achieved, as any score will be better/less
## than this.
##
## Another motivation for the "none"-timestamp is that using this as a default
## value means you won't accidentally give out a high-score of zero seconds if
## there is a bug.
static var NONE: TimeScore:
	get():
		return TimeScore.new(-1)


## Gets a timestamp of zero milliseconds.
static var ZERO: TimeScore:
	get():
		return TimeScore.new(0)

const _MAXIMUM_MILLISECONDS: int = INT64_MAX


# Override
func _init(milliseconds: int = 0) -> void:
	if milliseconds < 0:
		_none = true
	else:
		_milliseconds = milliseconds


func is_none() -> bool:
	return _none


## Advances the timestamp by the given number of milliseconds. Resists integer
## overflows by capping the total time at INT64_MAX. Does nothing if this is
## the "none"-timestamp.
func advance(by_milliseconds: int) -> void:
	if is_none():
		return
	
	var threshold: int = _MAXIMUM_MILLISECONDS - by_milliseconds
	if _milliseconds >= threshold:
		_milliseconds = _MAXIMUM_MILLISECONDS
	else:
		_milliseconds += by_milliseconds


func get_total_milliseconds() -> int:
	# For the "none" timestamp, the time is always the maximum possible value.
	# This is good for comparison, as this makes any score better.
	return _milliseconds if not _none else _MAXIMUM_MILLISECONDS


func get_total_centiseconds(round_up := true) -> int:
	@warning_ignore("integer_division")
	var integer_part = get_total_milliseconds() / 10
	var remainder = get_total_milliseconds() % 10
	return integer_part if (not round_up) or remainder == 0 else integer_part + 1


func get_total_seconds(round_up := true) -> int:
	@warning_ignore("integer_division")
	var integer_part = get_total_milliseconds() / 1000
	var remainder = get_total_milliseconds() % 1000
	return integer_part if (not round_up) or remainder == 0 else integer_part + 1


func get_total_minutes(round_up := true) -> int:
	@warning_ignore("integer_division")
	var integer_part = get_total_milliseconds() / (1000 * 60)
	var remainder = get_total_milliseconds() % (1000 * 60)
	return integer_part if (not round_up) or remainder == 0 else integer_part + 1


## Returns an array of three integers - minutes, seconds, and centiseconds in
## that order - for displaying the timestamp. Returns all-zeroes for the none
## timestamp (use [method is_none] instead to differetiate this from an actual
## all-zero timestamp)
func get_display_segments(round_up := true) -> Array[int]:
	if _none:
		# While it might seem tempting to return a negative value, all-zeroes
		# at least will display properly on a digital clock.
		return [0, 0, 0]
	
	var centiseconds := get_total_centiseconds(round_up)
	centiseconds = centiseconds % 100
	
	var seconds := get_total_seconds(false)
	seconds = seconds % 60
	
	var minutes := get_total_minutes(false)
	
	return [minutes, seconds, centiseconds]


## Gets as a string in the format [code]"mm:ss:cc"[/code] where [code]mm[/code]
## is minutes, [code]ss[/code] is seconds, and [code]cc[/code] is centiseconds.
## For example, a timestamp of 75310 milliseconds would return [code]01:15:31[/code].
##
## If this is a "none"-timestamp, uses the string specified by [param null_segment]
## for each segment. By default, this would give [code]xx:xx:xx[/code]
func get_display_string(null_segment := "xx", round_up := true) -> String:
	if _none:
		return "%s:%s:%s" % [null_segment, null_segment, null_segment]
	else:
		var display_segments := get_display_segments(round_up).map(func(segment): return str(segment).pad_zeros(2))
		return "%s:%s:%s" % display_segments


func serialize() -> int:
	return _milliseconds


static func deserialize(from: int) -> TimeScore:
	return TimeScore.new(from)
