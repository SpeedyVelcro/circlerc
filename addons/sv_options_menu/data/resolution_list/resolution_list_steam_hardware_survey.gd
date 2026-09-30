class_name ResolutionListSteamHardwareSurvey
extends ResolutionList
## Resolution list containing common resolutions from the Steam Hardware Survey
##
## Resolution list containing common resolutions per the Steam Hardware &
## Software Survey (see [url=https://store.steampowered.com/hwsurvey]here[/url]).
## The list consists of all resolutions common enough to show up under "Primary
## Display Resolution" in the January 2026 survey.

# Override
func _init():
	super([
		Vector2i(800, 1280),
		Vector2i(1280, 720),
		Vector2i(1280, 800),
		Vector2i(1280, 1024),
		Vector2i(1360, 768),
		Vector2i(1366, 768),
		Vector2i(1440, 900),
		Vector2i(1470, 956),
		Vector2i(1512, 982),
		Vector2i(1600, 900),
		Vector2i(1680, 1050),
		Vector2i(1920, 1080),
		Vector2i(1920, 1200),
		Vector2i(2560, 1080),
		Vector2i(2560, 1440),
		Vector2i(2560, 1600),
		Vector2i(2880, 1800),
		Vector2i(3440, 1400),
		Vector2i(3840, 2160),
		Vector2i(5120, 1440)
	])
