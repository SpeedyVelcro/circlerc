class_name ResolutionListModernStandards
extends ResolutionList
## Resolution list containing various modern standards
##
## Resolution list containing a variety of modern standards based on my own
## research.

# Override
func _init():
	super([
		Vector2i(1280, 720), # HD 720 / 720p
		# TODO: Am I missing a couple between 720p and 1080p?
		Vector2i(1920, 1080), # Full HD / HD 1080 / 1080p
		Vector2i(2560, 1080), # UWFHD
		Vector2i(2560, 1440), # QHD / 1440p
		Vector2i(3440, 1440), # UWQHD
		Vector2i(3840, 2160), # 4K / 4K UHD / UHDTV
		Vector2i(4320, 1800), # UW4K
		# TODO: Should the following be separated off into a future standards list?
		Vector2i(5120, 2160), # UW5K / WUHD
		Vector2i(5120, 2880), # 5K / 5K UHD
		Vector2i(7680, 4320), # 8K / 8K UHD / UHDTV
		Vector2i(8640, 3600), # UW8K
		Vector2i(15360, 8640), # 16K
		Vector2i(30720, 17280), # 32K (the future is now, old man)
	])
