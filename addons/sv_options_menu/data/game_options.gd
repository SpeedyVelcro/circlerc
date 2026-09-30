class_name GameOptions
extends Resource
## User-configured options for the game
##
## Encapsulates a [Dictionary] of user-configured options, with associated
## utility methods for reading and changing these options. The dictionary
## is a dictionary of values and, possibly, nested dictionaries.
# TODO: has_option and has_option_by_keys methods
# TODO: unset_option and unset_options_by_keys methods
# TODO: propagate option_modified signals from fallback

var _options: Dictionary
var _fallback: GameOptions = null

## Emitted when an option is set using either [method set_option] or
## [method set_option_by_keys]. Includes the path that was changed. This is
## only emitted for the exact path that was changed - it is not propagated up
## or down - so you may want to filter paths to respond to using
## String.begins_with if you want to listen to an entire options category.
signal option_modified_by_keys(keys: Array[String], new_value: Variant)

## As [signal option_modofied_by_keys], but only emitted when the option was
## modified using [method set_option], or alternatively if it was set using
## [method set_option_by_keys] but using only string keys. If the keys include
## other data types, then only [signal option_modified_by_keys] will be emitted.
signal option_modified(path: String, new_value: Variant)


# Override
func _init(dictionary: Dictionary = {}):
	_options = dictionary


## Returns the option at the given key. Tries to retrieve the option from the
## fallback set by [method set_fallback] if it hasn't been set; otherwise
## returns null.
##
## Options nested multiple dictionaries deep can be retrieved using a path
## formed of forward-slash-separated keys such as [code]"path/to/option"[/code].
func get_option(key_or_path: String) -> Variant:
	var keys := path_to_keys(key_or_path)
	
	return get_option_by_keys(keys, key_or_path)


## As [member get_option], but provide the path as an array of keys. This is
## useful if you have a non-string key somewhere down the hierarchy.
func get_option_by_keys(keys: Array, log_name := "") -> Variant:
	log_name = log_name if not log_name.is_empty() else var_to_str(keys)
	
	var current_level: Variant = _options
	for key in keys:
		if current_level is Dictionary and current_level.has(key):
			current_level = current_level[key]
			continue
		if _fallback != null:
			return _fallback.get_option_by_keys(keys, log_name)
		push_warning("Attempted to access option at path %s in GameOptions, but this did not exist in GameOptions or any fallback. Returning default of null." % log_name)
		return null
	
	if current_level is Dictionary and _fallback != null:
		# If the path is partial (i.e. not a leaf value) it needs to be merged with fallback values
		# so defaults that haven't been overridden aren't missing
		
		var fallback_dict = _fallback.get_option_by_keys(keys, log_name) # TODO: suppress errors
		if fallback_dict is not Dictionary:
			return current_level # Nothing to merge
		
		# Duplicate so we don't pollute the GameOption's underlying dictionary with defaults.
		var new_dict = current_level.duplicate_deep(DeepDuplicateMode.DEEP_DUPLICATE_ALL)
		_dictionary_deep_merge(new_dict, fallback_dict)
		return new_dict
	
	return current_level


## Returns true if any option has been set on this GameOptions. If nothing has
## been set (i.e. it is empty, apart from any fallback) then returns false.
func has_any_options_set() -> bool:
	return not _options.keys().is_empty()


func _dictionary_deep_merge(dict: Dictionary, fallback: Dictionary) -> void:
	for key: Variant in dict.keys():
		if dict[key] is Dictionary and fallback.has(key) and fallback[key] is Dictionary:
			_dictionary_deep_merge(dict[key], fallback[key])
	
	for fallback_key in fallback.keys():
		if not dict.has(fallback_key):
			dict[fallback_key] = fallback[fallback_key]


## Sets the option at the given key to the given value. The value needs to be
## serializable to json.
##
## Options can be set nested multiple dictionaries deep by using a path formed
## of forward-slash-separated keys such as [code]"path/to/option"[/code]. Nested
## dictionaries will be created if they don't exist. Note that this may
## overwrite existing options with a dictionary.
func set_option(key_or_path: String, value: Variant) -> void:
	var keys := path_to_keys(key_or_path)
	set_option_by_keys(keys, value, key_or_path)

## As [member set_option], but provide the path as an array of keys. This is
## useful if you have a non-string type somewhere down the hierarchy. Otherwise,
## it is recommended to just use the set_option function as it has an easier
## contract.
func set_option_by_keys(keys: Array, value: Variant, log_name := "") -> void:
	log_name = log_name if not log_name.is_empty() else var_to_str(keys)
	
	var except_last = func (arr: Array) -> Array: return arr.slice(0, -1)
	
	var current_level: Dictionary = _options
	var current_path := ""
	for key in except_last.call(keys):
		current_path += str(key)
		
		if not current_level.has(key):
			current_level[key] = {}
		
		if current_level[key] is not Dictionary:
			push_warning("Found existing option at %s while trying to set option at %s. Overwriting." % [current_path, log_name])
			current_level[key] = {}
		
		current_level = current_level[key]
		current_path += "/"
	
	current_level[keys.back()] = value
	option_modified_by_keys.emit(keys, value)
	if keys.all(func (key): return key is String):
		option_modified.emit(current_path + str(keys.back()), value)


## Sets the fallback to the given [GameOptions]. This will be used to retrieve
## options if [method get_option] can't find it on the current [GameOptions].
func set_fallback(fallback: GameOptions) -> void:
	_fallback = fallback


## Serializes this [GameOptions] to a JSON-compatible [Dictionary]. Note: this
## does not serialize the fallback.
func serialize() -> Dictionary:
	return _options


## Creates a [GameOptions] from a [Dictionary].
static func deserialize(from: Dictionary) -> GameOptions:
	return GameOptions.new(from)


## Converts a path in the [code]"path/to/option"[/code] format to an array
## of strings.
static func path_to_keys(path: String) -> Array[String]:
	var temp: Array[String]
	temp.assign(path.split("/")) # Workaround to convert PackedStringArray to a typed Array
	return temp
