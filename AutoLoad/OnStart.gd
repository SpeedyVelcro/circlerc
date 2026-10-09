extends Node
## Autoload for on-start functionality
##
## This script should be registered as the final autoload. It can be used
## for all initialization that is required regardless of the main scene (i.e.
## regardless of whether the game was started normally or started through
## "Run Current Scene" through the editor).
##
## Appropriate initialization tasks for this script include loading settings,
## reading secrets, calling init methods on other autoloads, etc. Tasks such
## as choosing the starting scene that are only applicable when running the game
## normally are better done in the main scene.

const _LEVEL_LIST: LevelList = preload("res://Level/LevelList.tres")


# Override
func _ready() -> void:
	Profile.load_profile()
	
	# Earlier versions of CircleRC did not have achievements. We check if any
	# achievements should have been unlocked.
	_fix_achievement_progress()
	
	var options_config := OptionsConfigProvider.get_config()
	options_config.manage_window_mode = not OS.has_feature("web")
	options_config.manage_screen = not OS.has_feature("web")
	OptionsLifecycle.start_up()
	
	if OS.has_feature("newgrounds"):
		ProjectSettings.set_setting("newgrounds.io/app_id", Secrets.NEWGROUNDS_APP_ID)
		ProjectSettings.set_setting("newgrounds.io/AES-128_key", Secrets.NEWGROUNDS_AES_128_ENCRYPTION_KEY)
		NG.init()
		
		LeaderboardService.backend = LeaderboardService.Backend.NEWGROUNDS
	
	if OS.has_feature("game_jolt"):
		GameJolt.private_key = Secrets.GAME_JOLT_PRIVATE_KEY
		
		LeaderboardService.backend = LeaderboardService.Backend.GAME_JOLT


func _fix_achievement_progress() -> void:
	var finish_all_achievement := AchievementService.get_achievement("finish-all")
	var no_hit_all_achievement := AchievementService.get_achievement("no-hit-all")
	var par_all_achievement := AchievementService.get_achievement("par-all")
	var no_hit_par_all_achievement := AchievementService.get_achievement("no-hit-par-all")
	
	var number_of_levels := _LEVEL_LIST.get_number_of_levels()
	
	for n in range(1, number_of_levels + 1):
		var finish_objective: AchievementObjective = finish_all_achievement.objective.objectives[n - 1]
		var no_hit_objective: AchievementObjective = no_hit_all_achievement.objective.objectives[n - 1]
		var par_objective: AchievementObjective = par_all_achievement.objective.objectives[n - 1]
		var no_hit_par_objective: AchievementObjective = no_hit_par_all_achievement.objective.objectives[n - 1]
		
		if Profile.is_level_finished(n):
			finish_objective.complete()
		
		if Profile.is_level_no_hit(n):
			no_hit_objective.complete()
		
		if Profile.is_level_best_time_under_par(n):
			par_objective.complete()
		
		if Profile.is_level_par_and_no_hit(n):
			no_hit_par_objective.complete()
