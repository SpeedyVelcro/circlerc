class_name OptionsRepository
extends Object
## Orchestrates saving and loading options
##
## Abstraction layer for saving and loading options files from a given file
## path on disk. The path - and the intended fallback options (if any, usually
## some default settings) are injected at construction.

var _path: String
var _fallback: GameOptions


# Override
func _init(path: String, fallback: GameOptions = null):
	_path = path
	_fallback = fallback


## Saves the user-configured options to the file assocsiated with this
## [OptionsRepository]. Does not save any values from fallback.
func save_options(options: GameOptions) -> void:
	_write_options_to_disk(options)


## Saves options in the same way as [method save_options], but only if the
## [GameOptions] has any options set.
func save_options_if_any(options: GameOptions) -> void:
	if not options.has_any_options_set():
		return
	
	_write_options_to_disk(options)


## Loads the user-configured options from the file associated with this
## [OptionsRepository], and assigns the fallback, if any.
func load_options() -> GameOptions:
	var options = _read_options_from_disk()
	
	if _fallback != null:
		options.set_fallback(_fallback)
	
	return options


func _read_options_from_disk() -> GameOptions:
	if not FileAccess.file_exists(_path):
		push_warning("Options file did not exist at path \"%s\", using new options instead." % _path)
		return GameOptions.new()
	
	var file := FileAccess.open(_path, FileAccess.READ)
	
	if not file:
		push_error("Failed to read options file at path \"%s\" with error code %s, using new options instead." % [_path, FileAccess.get_open_error()])
		return GameOptions.new()
	
	var contents := file.get_as_text()
	file.close()
	
	var dict := JSON.parse_string(contents)
	
	if dict is not Dictionary:
		push_error("Failed to parse options file at path \"%s\". Maybe the JSON is malformed? Using new options instead." % _path)
		return GameOptions.new()
	
	var options = GameOptions.deserialize(dict)
	return options


func _write_options_to_disk(options: GameOptions) -> void:
	_make_dir()
	
	var file := FileAccess.open(_path, FileAccess.WRITE)
	
	if not file:
		push_error("Failed to open options file for writing at path \"%s\" with error code %s. Any changes to options will not be saved." % [_path, FileAccess.get_open_error()])
		return
	
	if not file.store_string(JSON.stringify(options.serialize(), "\t")):
		push_error("Failed to write to options file at path \"%s\". Options file may now be corrupted or malformed." % _path)
	
	file.close()


func _make_dir() -> void:
	var dir = _path.rsplit("/", true, 1)[0]
	
	if dir.ends_with(":/"):
		return # base dirs like user:// or res:// do not need creating, and indeed would be left malformed by splitting on slashes
	
	if DirAccess.dir_exists_absolute(dir):
		return # No action necessary
	
	var err = DirAccess.make_dir_recursive_absolute(dir)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("Failed to create directory \"%s\" for options file with error code %s. Continuing anyway as directory may already exist." % [dir, err])
