class_name EditableBusConfig
extends Resource
## Configuration of an editable audio bus
##
## Configuration of an editable audio bus in SV Options Menu. Indicates the
## audio bus and includes settings that govern its editing, such as
## defaults.

## Reference to the audio bus this config governs. Can be a name or an ID.
@export var reference: AudioBusReference

## User-readable name of the audio bus (usually presented to the player in the
## options menu). Purely cosmetic; has no functional impact.
@export var name: String = ""

## Default volume for the audio bus as a linear volume. See
## [method AudioServer.get_bus_volume_linear] for a description of linear
## volume.
@export var default_volume_linear: float = 1.0

## Maximum volume that can be configured by the player as a linear volume. See
## [method AudioServer.get_bus_volume_linear] for a description of linear
## volume.
@export var max_volume_linear: float = 1.0

## Default mute status of the audio bus. Usually there is no reason you would
## want this to be true.
@export var default_mute: bool = false


# Constructor
func _init(reference: AudioBusReference = null, name: String = ""):
	self.reference = reference if reference != null else AudioBusId.new(0)
	self.name = name
