extends PanelContainer

## Set to true to auto-attempt to login and continue without user input the next
## time the menu is shown. This will switch back to false again after that
## attempt.
@export var attempt_skip := false
@export var username_line_edit: LineEdit
@export var token_line_edit: LineEdit
@export var login_container: Control
@export var logout_container: Control
@export var logout_button: Button
@export var fail_label: Label
@export var login_fail_animation_player: AnimationPlayer
@export var continue_button: Button
@export var login_button: Button
@export var auto_login_button: Button
const CONTINUE_BUTTON_TEXT = "Continue"
const SKIP_BUTTON_TEXT = "Skip"

var _attempting_to_skip := false

signal back

func _ready():
	GameJoltIntegration.connect("session_open", Callable(self, "_on_GameJoltIntegration_session_open"))
	GameJoltIntegration.connect("session_open_fail", Callable(self, "_on_GameJoltIntegration_session_open_fail"))


func _on_LoginButton_pressed():
	login_button.disabled = true
	auto_login_button.disabled = true
	
	var username = username_line_edit.get_text()
	var token = token_line_edit.get_text()
	GameJoltIntegration.login(username, token)

func _on_AutoLoginButton_pressed():
	login_button.disabled = true
	auto_login_button.disabled = true
	
	if not GameJoltIntegration.login_auto():
		login_fail_animation_player.play("login_fail")
		login_button.disabled = false
		auto_login_button.disabled = false

func _on_LogoutButton_pressed():
	GameJoltIntegration.logout()
	show_login()

func _on_GameJoltIntegration_session_open():
	show_logout()
	if _attempting_to_skip:
		go_back()

func _on_GameJoltIntegration_session_open_fail():
	login_fail_animation_player.play("login_fail")
	login_button.disabled = false
	auto_login_button.disabled = false

func _on_ContinueButton_pressed():
	go_back()


func go_back() -> void:
	emit_signal("back")


# Override
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action("ui_cancel"):
		go_back()

func show_login():
	login_container.set_visible(true)
	logout_container.set_visible(false)
	continue_button.set_text(SKIP_BUTTON_TEXT)
	login_button.disabled = false
	auto_login_button.disabled = false
	# UIFocusService.leave_focusable_ui()
	# UIFocusService.enter_focusable_ui(username_line_edit)

func show_logout():
	login_container.set_visible(false)
	logout_container.set_visible(true)
	continue_button.set_text(CONTINUE_BUTTON_TEXT)
	# UIFocusService.leave_focusable_ui()
	# UIFocusService.enter_focusable_ui(continue_button)


# Signal connection
func _on_visibility_changed() -> void:
	if not visible:
		return
	
	fail_label.set_visible(false)
	if GameJoltIntegration.is_integration_enabled():
		show_logout()
		# UIFocusService.enter_focusable_ui(username_line_edit)
	else:
		show_login()
		# UIFocusService.enter_focusable_ui(logout_button)
	
	if attempt_skip:
		attempt_skip = false
		if GameJoltIntegration.can_auto_login():
			if GameJoltIntegration.login_auto():
				_attempting_to_skip = true
			else:
				login_fail_animation_player.play("login_fail")
