class_name LeaderboardPageButton
extends Button

@export var ui_controller: LeaderboardUIController:
	set(value):
		_disconnect_ui_controller_signals()
		ui_controller = value
		_update_disabled_status()
		_connect_ui_controller_signals()
	get:
		return ui_controller

@export var direction: Direction = Direction.NEXT:
	set(value):
		direction = value
		_update_disabled_status()
	get:
		return direction

var _readied := false

enum Direction {
	PREVIOUS,
	NEXT
}


# Override
func _ready() -> void:
	_readied = true
	
	_connect_pressed_signal()
	_update_disabled_status()
	_connect_ui_controller_signals()


func _connect_pressed_signal() -> void:
	if not pressed.is_connected(_on_self_pressed):
		pressed.connect(_on_self_pressed)


func _disconnect_pressed_signal() -> void:
	if pressed.is_connected(_on_self_pressed):
		pressed.disconnect(_on_self_pressed)


func _update_disabled_status() -> void:
	if not _readied:
		return
	
	if ui_controller == null:
		return
	
	if ui_controller.is_loading():
		disabled = true
		return
	
	if ui_controller.is_hidden():
		disabled = true
		return
	
	if not LeaderboardService.is_supported():
		disabled = true
		return
	
	match direction:
		Direction.PREVIOUS:
			disabled = ui_controller.is_on_first_page()
		Direction.NEXT:
			disabled = ui_controller.is_on_last_page()


func _connect_ui_controller_signals() -> void:
	if not _readied:
		return
	
	if ui_controller == null:
		return
	
	if not ui_controller.reached_first_page.is_connected(_on_ui_controller_reached_first_page):
		ui_controller.reached_first_page.connect(_on_ui_controller_reached_first_page)
	
	if not ui_controller.reached_last_page.is_connected(_on_ui_controller_reached_last_page):
		ui_controller.reached_last_page.connect(_on_ui_controller_reached_last_page)
	
	if not ui_controller.reached_middle_page.is_connected(_on_ui_controller_reached_middle_page):
		ui_controller.reached_middle_page.connect(_on_ui_controller_reached_middle_page)
	
	if not ui_controller.started_loading.is_connected(_on_ui_controller_started_loading):
		ui_controller.started_loading.connect(_on_ui_controller_started_loading)
	
	if not ui_controller.scores_hidden.is_connected(_on_ui_controller_scores_hidden):
		ui_controller.scores_hidden.connect(_on_ui_controller_scores_hidden)


func _disconnect_ui_controller_signals() -> void:
	if not _readied:
		return
	
	if ui_controller == null:
		return
	
	if ui_controller.reached_first_page.is_connected(_on_ui_controller_reached_first_page):
		ui_controller.reached_first_page.disconnect(_on_ui_controller_reached_first_page)
	
	if ui_controller.reached_last_page.is_connected(_on_ui_controller_reached_last_page):
		ui_controller.reached_last_page.disconnect(_on_ui_controller_reached_last_page)
	
	if ui_controller.reached_middle_page.is_connected(_on_ui_controller_reached_middle_page):
		ui_controller.reached_middle_page.disconnect(_on_ui_controller_reached_middle_page)


# Signal connection
func _on_self_pressed() -> void:
	if ui_controller == null:
		return
	
	match direction:
		Direction.PREVIOUS:
			ui_controller.go_to_previous_page()
		Direction.NEXT:
			ui_controller.go_to_next_page()


# Signal connection
func _on_ui_controller_reached_first_page() -> void:
	_update_disabled_status()


# Signal connection
func _on_ui_controller_reached_last_page() -> void:
	_update_disabled_status()


# Signal connection
func _on_ui_controller_reached_middle_page() -> void:
	_update_disabled_status()


# Signal connection
func _on_ui_controller_started_loading() -> void:
	_update_disabled_status()


# Signal connection
func _on_ui_controller_scores_hidden() -> void:
	_update_disabled_status()


# Override
func _exit_tree() -> void:
	_disconnect_pressed_signal()
	_disconnect_ui_controller_signals()
