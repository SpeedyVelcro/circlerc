extends VBoxContainer

@export var ui_controller: LeaderboardUIController

@onready var _submit_button: Label = $SubmitButton
@onready var _status_failed_label: Label = $StatusFailedLabel
@onready var _status_uploading_label: Label = $StatusUploadingLabel
@onready var _status_success_label: Label = $StatusSuccessLabel

enum State {
	DISABLED,
	ENABLED,
	UPLOADING,
	FAILED,
	SUCCESS
}

var _state: State = State.DISABLED:
	set(value):
		_on_state_exit()
		_state = value
		_on_state_enter(value)
	get:
		return _state

var _readied := false


# Override
func _ready() -> void:
	_readied = true
	_on_state_enter(_state)


func _on_state_enter(state: State):
	if not _readied:
		return
	
	match state:
		State.DISABLED:
			_set_button_text_submit()
			_submit_button.disabled = true
		State.ENABLED:
			_set_button_text_submit()
			_submit_button.disabled = false
		State.UPLOADING:
			_submit_button.disabled = true
			_status_uploading_label.visible = true
			# TODO: start animation timer
		State.FAILED:
			_set_button_text_retry()
			_submit_button.disabled = false
			_status_failed_label.visible = true
		State.SUCCESS:
			_set_button_text_submit()
			_submit_button.disabled = true
			_status_success_label.visible = true


func _on_state_exit():
	if not _readied:
		return
	
	match _state:
		State.UPLOADING:
			_status_uploading_label.visible = false
			# TODO: Stop animation timer
		State.FAILED:
			_status_failed_label.visible = false
		State.SUCCESS:
			_status_success_label.visible = false


func _set_button_text_submit() -> void:
	if _submit_button == null:
		return
	
	_submit_button.text = "Submit Score"


func _set_button_text_retry() -> void:
	if _submit_button == null:
		return
	
	_submit_button.text = "Try Again"


func _connect_signals() -> void:
	if ui_controller == null:
		return
	
	if not ui_controller.ready_to_submit.is_connected(_on_ui_controller_ready_to_submit):
		ui_controller.ready_to_submit.connect(_on_ui_controller_ready_to_submit)
	
	if not ui_controller.started_submitting.is_connected(_on_ui_controller_started_submitting):
		ui_controller.started_submitting.connect(_on_ui_controller_started_submitting)
	
	if not ui_controller.submit_succeeded.is_connected(_on_ui_controller_submit_succeeded):
		ui_controller.submit_succeeded.connect(_on_ui_controller_submit_succeeded)
	
	if not ui_controller.submit_failed.is_connected(_on_ui_controller_submit_failed):
		ui_controller.submit_failed.connect(_on_ui_controller_submit_failed)


func _disconnect_signals() -> void:
	if ui_controller == null:
		return
	
	if ui_controller.ready_to_submit.is_connected(_on_ui_controller_ready_to_submit):
		ui_controller.ready_to_submit.disconnect(_on_ui_controller_ready_to_submit)
	
	if ui_controller.started_submitting.is_connected(_on_ui_controller_started_submitting):
		ui_controller.started_submitting.disconnect(_on_ui_controller_started_submitting)
	
	if ui_controller.submit_succeeded.is_connected(_on_ui_controller_submit_succeeded):
		ui_controller.submit_succeeded.disconnect(_on_ui_controller_submit_succeeded)
	
	if ui_controller.submit_failed.is_connected(_on_ui_controller_submit_failed):
		ui_controller.submit_failed.disconnect(_on_ui_controller_submit_failed)


# Signal connection
func _on_ui_controller_ready_to_submit() -> void:
	if _state == State.DISABLED:
		_state = State.ENABLED


# Signal connection
func _on_ui_controller_started_submitting() -> void:
	_state = State.UPLOADING


# Signal connection
func _on_ui_controller_submit_succeeded() -> void:
	_state = State.SUCCESS


# Signal connection
func _on_ui_controller_submit_failed() -> void:
	_state = State.FAILED


# Signal connection
func _on_submit_button_pressed() -> void:
	if ui_controller == null:
		push_error("Cannot submit score as submit score UI does not have a UI controller set.")
		return
	
	ui_controller.submit_score()
