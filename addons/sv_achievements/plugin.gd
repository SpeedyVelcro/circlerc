@tool
extends EditorPlugin

const _ACHIEVEMENT_SERVICE_AUTOLOAD_NAME := "AchievementService"


# Override
func _enter_tree() -> void:
	SVAchievementsProjectSettings.configure()
	
	add_autoload_singleton(_ACHIEVEMENT_SERVICE_AUTOLOAD_NAME, "res://addons/sv_achievements/autoload/achievement_service.gd")


# Override
func _exit_tree() -> void:
	remove_autoload_singleton(_ACHIEVEMENT_SERVICE_AUTOLOAD_NAME)
