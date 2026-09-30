class_name AspectRatioHelper
extends Node
## Helper for dealing with aspect ratios.
##
## This helper has helpful functions for figuring out the relation between
## aspect ratios and resolutions


## Returns true if the given resolution is of the given aspect ratio.
static func is_aspect_ratio(resolution: Vector2i, aspect_ratio: Vector2i) -> bool:
	return float(resolution.x) / float(resolution.y) == float(aspect_ratio.x) / float(aspect_ratio.y)


## Finds the highest resolution of the given aspect ratio that fits within a
## given maximum resolution
static func fit_aspect_ratio_within(aspect_ratio: Vector2i, maximum: Vector2i) -> Vector2i:
	aspect_ratio = to_aspect_ratio(aspect_ratio) # Just in case we are given a non-simplified aspect ratio
	
	var limited_by_x = maximum.x / maximum.y < aspect_ratio.x / aspect_ratio.y
	
	var multiply_by: int
	if limited_by_x:
		multiply_by = floori(maximum.x / aspect_ratio.x)
	else:
		multiply_by = floori(maximum.y / aspect_ratio.y)
	
	return aspect_ratio * multiply_by


## Returns the simplest aspect ratio of the given resolutions's x and y dimensions.
static func to_aspect_ratio(resolution: Vector2i) -> Vector2i:
	return resolution / _highest_common_factor(resolution.x, resolution.y)


static func _highest_common_factor(a: int, b: int) -> int:
	# Euclid's algorithm requires a > b
	if b > a:
		var swap = a
		a = b
		b = swap
	
	var r: int = a % b
	if r == 0:
		return b
	else:
		return _highest_common_factor(b, r)
