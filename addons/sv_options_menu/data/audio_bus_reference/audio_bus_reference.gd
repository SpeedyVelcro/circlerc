@abstract class_name AudioBusReference
extends Resource
## Reference to an audio bus
##
## A (reasonably) type-safe reference to an audio bus. Use [AudioBusId] or
## [AudioBusName] to reference audio buses by ID or name respectively. This
## provides no guarantees the audio bus actually exists, though.


## Returns the name of the audio bus
@abstract func get_name() -> String


## Returns the ID of the audio bus
@abstract func get_id() -> int


## Returns the specific variant that is being used as the source-of-truth for
## which audio bus this references. Will be either an int or a String.
@abstract func to_variant() -> Variant
