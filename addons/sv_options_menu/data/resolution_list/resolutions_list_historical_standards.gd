class_name ResolutionListHistoricalStandards
extends ResolutionList
## Resolution list containing various historical standards
##
## Resolution list containing a variety of historical standards based on my own
## research. Some of them are super small, so there's probably not much reason
## to support them unless you're doing something super retro.

# Override
func _init():
	super([
		Vector2i(320, 200), # CGA
		Vector2i(320, 240), # QVGA
		Vector2i(640, 360), # nHD (quarter HD) / 360p
		Vector2i(640, 480), # VGA
		Vector2i(768, 576), # PAL
		Vector2i(800, 480), # WVGA
		Vector2i(800, 600), # SVGA
		Vector2i(854, 480), # FWVGA
		Vector2i(1024, 600), # WSVGA
		Vector2i(1024, 768), # XGA
		Vector2i(1280, 720), # HD 720 / 720p
		Vector2i(1280, 768), # WXGA
		Vector2i(1280, 800), # WXGA
		Vector2i(1280, 1024), # SXGA
		Vector2i(1920, 1080), # Full HD / HD 1080 / 1080p
	])
