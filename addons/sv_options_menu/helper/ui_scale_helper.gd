class_name OptionsUIScaleHelper
extends Object
## SV Options Menu helper class for UI scale
##
## Helper class for interacting with UI scale in SV Options Menu. Provides a
## range of static helper methods.


## Calculates the default UI scale based on [OptionsConfig] and its resolution
## settings.
static func calculate_default_ui_scale(options_config: OptionsConfig) -> float:
	if options_config.default_ui_scale > 0.0:
		return options_config.default_ui_scale
	
	if options_config.manage_resolution:
		# Resolution won't have been applied yet, so can't get it directly from OptionsDisplayHelper.
		var default_resolution := options_config.calculate_default_resolution()
		var ratio := calculate_ratio_to_reference_resolution(options_config, default_resolution)
		return snap_to_valid_ui_scale(ratio, options_config, default_resolution)
	else:
		var ratio := calculate_ratio_to_reference_resolution(options_config)
		return snap_to_valid_ui_scale(ratio, options_config)


## Snaps the given UI scale according to options in options_config. Usually called
## when the resolution changes, but you should check [method is_ui_scale_in_bounds]
## first to make sure you don't pointlessly override custom UI scales that are
## still within bounds.
static func snap_to_valid_ui_scale(ui_scale: float, options_config: OptionsConfig, resolution := Vector2i(0, 0)) -> float:
	var snap_scales: Array[float] = options_config.ui_scaling_snap_values.duplicate_deep()
	snap_scales.sort()
	snap_scales = snap_scales.filter(func (s: float): return is_ui_scale_in_bounds(s, options_config, resolution))
	
	if snap_scales.is_empty():
		return ui_scale
	
	if snap_scales.size() == 1:
		return snap_scales.front()
	
	if snap_scales.has(ui_scale):
		return ui_scale
	
	var low_index := snap_scales.size() - 1
	var high_index := snap_scales.size()
	
	for i in range(snap_scales.size()):
		if snap_scales[i] > ui_scale:
			high_index = snap_scales[i]
			low_index = snap_scales[i - 1]
			break
	
	if low_index < 0:
		return snap_scales.front()
	
	if high_index >= snap_scales.size():
		return snap_scales.back()
	
	var low_scale := snap_scales[low_index]
	var high_scale := snap_scales[high_index]
	
	# Not exactly a midpoint but you get the idea
	var midpoint := low_scale + ((high_scale - low_scale) * options_config.ui_scaling_snap_bias)
	
	return high_scale if ui_scale >= midpoint else low_scale


## Checks if the given UI scale is within bounds set according to the minimum and
## cap (which changes based on given or current resolution) based on [OptionsConfig].
static func is_ui_scale_in_bounds(ui_scale: float, options_config: OptionsConfig, resolution := Vector2i(0, 0)) -> bool:
	if ui_scale < options_config.ui_minimum_scale:
		return false
	
	if not options_config.ui_scaling_auto_cap:
		return true
	
	var cap := calculate_ui_scale_cap(options_config, resolution)
	
	return ui_scale <= cap


## Calculate the cap based on the current resolution that should be used when
## [member OptionsConfig.ui_scaling_auto_cap] is true (note: this is not checked
## here, it is assumed you would only call this if you are applying the cap so
## it should be true anyway).
static func calculate_ui_scale_cap(options_config: OptionsConfig, resolution := Vector2i(0, 0)) -> float:
	var ratio := calculate_ratio_to_reference_resolution(options_config, resolution)
	var calculated_cap := max(options_config.ui_minimum_scale, ratio)
	# Add leeway
	return calculated_cap * (1.0 + max(0.0, options_config.ui_scaling_auto_cap_leeway))


## Returns the ratio between the given resolution (or the current resolution
## if none is provided) and the reference resolution (see
## [member OptionsConfig.ui_scaling_reference_resolution]). This is done on the
## smallest dimension of the given resolution.
static func calculate_ratio_to_reference_resolution(options_config: OptionsConfig, resolution := Vector2i(0, 0)) -> float:
	if resolution == Vector2i.ZERO:
		resolution = OptionsDisplayHelper.get_current_resolution()
	var smallest_dimension_is_y := resolution.y <= resolution.x
	
	var reference_resolution := options_config.get_reference_resolution()
	
	var ratio: float
	
	if smallest_dimension_is_y:
		ratio = float(resolution.y) / float(reference_resolution.y)
	else:
		ratio = float(resolution.x) / float(reference_resolution.x)
	
	return ratio
