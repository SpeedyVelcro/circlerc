extends Node

@onready var ping_timer = $PingTimer

var integration_enabled = false: get = is_integration_enabled, set = set_integration_enabled

var _failed_pings: int = 0

signal session_open
signal session_open_fail
signal session_closed

func _ready():
	GameJolt.sessions_open_completed.connect(_on_game_jolt_sessions_open_completed)
	GameJolt.sessions_ping_completed.connect(_on_game_jolt_sessions_ping_completed)
	GameJolt.sessions_close_completed.connect(_on_game_jolt_sessions_close_completed)
	GameJolt.users_auth_completed.connect(_on_game_jolt_users_auth_completed)

func login(username : String, token : String):
	GameJolt.set_user_name(username)
	GameJolt.set_user_token(token)
	GameJolt.users_auth()


## Returns true if login() was called successfully (the login could still fail after this)
func login_auto() -> bool:
	if OS.has_feature("web"):
		return login_auto_by_url_params()
	else:
		return login_auto_by_credentials_file()


## Returns true if login() was called successfully (the login could still fail after this)
func login_auto_by_url_params() -> bool:
	if not OS.has_feature("web"):
		push_error("Cannot auto-login to Game Jolt using URL params because this is not the web build of the game.")
		return false
	
	# Not sure this is actually documented anywhere, but you can check by watching the
	# network calls when playing an HTML5 Game Jolt game.
	var param_name = JavaScriptBridge.eval("new URL(window.location.href).searchParams.get('gjapi_username')")
	var param_token = JavaScriptBridge.eval("new URL(window.location.href).searchParams.get('gjapi_token')")
	
	if param_name == null or param_token == null:
		push_error("Cannot auto-login to Game Jolt because one or more URL params were missing.")
		return false
	
	var param_name_string := str(param_name)
	var param_token_string := str(param_token)
	
	login(param_name_string, param_token_string)
	return true


## Returns true if login() was called successfully (the login could still fail)
func login_auto_by_credentials_file() -> bool:
	if not OS.has_feature("pc"):
		push_error("Cannot auto-login to Game Jolt using the credentials file because this is not the desktop version of the game.")
		return false
	
	if not FileAccess.file_exists(_get_credentials_file_path()):
		push_error("Cannot auto-login to Game Jolt because the .gj-credentials file is missing.")
		return false
	
	var file := FileAccess.open(_get_credentials_file_path(), FileAccess.READ)
	
	if not file:
		push_error("Failed to open .gj-credentials file with error: %s" % FileAccess.get_open_error())
		return false
	
	var version := file.get_line()
	var username := file.get_line()
	var token := file.get_line()
	
	file.close()
	
	# We warn for both major and minor version bumps because, assuming they are
	# using semver, on 0.x.x minor versions can also bring breaking changes.
	if not version.begins_with("0.2"):
		# Only a warning because this is all fail safely anyway
		push_warning("The credentials file's version has had a major or minor version bump (v0.2.x is expected)")
	
	login(username, token)
	return true


func can_auto_login() -> bool:
	if OS.has_feature("web"):
		return true
	
	if OS.has_feature("pc") and FileAccess.file_exists(_get_credentials_file_path()):
		return true
	
	return false


func logout():
	GameJolt.sessions_close()


# Signal Connection
func _on_game_jolt_sessions_open_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if not success:
		var message := _get_message(response)
		push_error("Failed to open Game Jolt session. Message: %s" % message)
		session_open_fail.emit()
		return
	
	set_integration_enabled(true)
	session_open.emit()
	ping_timer.start(30.0)
	_failed_pings = 0


# Signal Connection
func _on_game_jolt_sessions_ping_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if success:
		return # Nothing wrong, continue on as usual.
	
	var message := _get_message(response)
	push_warning("Failed Game Jolt ping. Message: %s" % message)
	_failed_pings += 1
	
	# 4 failed pings is 120 seconds, which is the timeout for Game Jolt sessions.
	# See: https://gamejolt.com/game-api/doc/sessions/ping
	if _failed_pings >= 4:
		# Can assume session is closed now (we don't need to close it ourself
		# as Game Jolt times it out itself).
		set_integration_enabled(false)
		session_closed.emit()
		ping_timer.stop()


# Signal Connection
func _on_game_jolt_sessions_close_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if not success:
		var message := _get_message(response)
		push_error("Failed to close Game Jolt session. Message: %s" % message)
		return
	
	set_integration_enabled(false)
	session_closed.emit()
	ping_timer.stop()


# Signal Connection
func _on_game_jolt_users_auth_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if not success:
		var message := _get_message(response)
		push_error("Failed to authenticate Game Jolt user. Message: %s" % message)
		session_open_fail.emit()
		return
	
	GameJolt.sessions_open()


func _is_success(response: Dictionary) -> bool:
	if not response.has("success"):
		return false
	
	if response["success"] is String:
		return response["success"] == "true"
	
	if response["success"] is bool:
		return response["success"]
	
	push_error("Unrecognised type for success field in Game Jolt API response")
	return false


func _get_message(response: Dictionary) -> String:
	return str(response["message"]) if response.has("message") else ""


func _get_credentials_file_path() -> String:
	return OS.get_executable_path().get_base_dir() + "/.gj-credentials"


# Signal Connection
func _on_ping_timer_timeout() -> void:
	GameJolt.sessions_ping()


# Getters and setters
func set_integration_enabled(value : bool):
	integration_enabled = value
	AchievementService.sync_enabled = integration_enabled


func is_integration_enabled():
	return integration_enabled
