class_name AudioBusName
extends AudioBusReference
## Reference to an audio bus by name
##
## A (reasonably) type-safe reference to an audio bus by name. Note that this
## provides no guarantees that the audio bus actually exists.


## The name of the audio bus. See [AudioServer]
@export var bus_name: String


# Constructor
func _init(bus_name: String = ""): # User should always provide a name but resource loading seems to error out if you can't use the empty constructor
	# _init() takes place before @export initialisation, so this will be overwritten
	# when deserialized from .tres. This is fine - it is desired behaviour that allows
	# configuring through the editor.
	self.bus_name = bus_name


# Override
func get_name() -> String:
	return bus_name


# Override
func get_id() -> int:
	return AudioServer.get_bus_index(bus_name)


# Override
func to_variant() -> String:
	return bus_name
