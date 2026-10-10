class_name LeaderboardDisplay
extends Control

@export var ui_controller: LeaderboardUIController:
	set(value):
		_disconnect_signals()
		ui_controller = value
		_connect_signals()
		_force_update()
	get:
		return ui_controller

@export var highlight_current_user_color: Color = Color.YELLOW

@onready var _scores_label: RichTextLabel = $ScoresRichTextLabel
@onready var _loading_label: Label = $LoadingLabel
@onready var _hidden_label: Label = $HiddenLabel
@onready var _unsupported_label: Label = $UnsupportedLabel
@onready var _loading_animation_timer: Timer = $LoadingAnimationTimer
var _readied := false
var _state: State = State.HIDDEN:
	set(value):
		_on_state_exit()
		_state = value
		_on_state_enter(value)
	get:
		return _state

enum State {
	HIDDEN,
	UNSUPPORTED,
	LOADING,
	SHOWING
}


# Override
func _ready() -> void:
	_readied = true
	_on_state_enter(_state)


func _on_state_enter(state: State) -> void:
	if not _readied:
		return
	
	match state:
		State.HIDDEN:
			_hidden_label.visible = true
		State.UNSUPPORTED:
			_unsupported_label.visible = true
		State.LOADING:
			_loading_label.visible = true
			_loading_label.text = "Loading..."
			_loading_animation_timer.start()
		State.SHOWING:
			_scores_label.visible = true


func _on_state_exit() -> void:
	if not _readied:
		return
	
	match _state:
		State.HIDDEN:
			_hidden_label.visible = false
		State.UNSUPPORTED:
			_unsupported_label.visible = false
		State.LOADING:
			_loading_label.visible = false
			_loading_animation_timer.stop()
		State.SHOWING:
			_scores_label.visible = false


func _force_update() -> void:
	if ui_controller == null:
		_state = State.UNSUPPORTED
		return
	
	if not LeaderboardService.is_supported():
		_state = State.UNSUPPORTED
		return
	
	if ui_controller.is_loading():
		_state = State.LOADING
		return
	
	if ui_controller.is_hidden():
		_state = State.HIDDEN
		return
	
	_show_scores(ui_controller.get_scores())


func _show_scores(scores: Array[LeaderboardScore]) -> void:
	if ui_controller == null:
		push_error("Cannot show scores when UI controller is not assigned.")
		return
	
	var current_user := LeaderboardService.get_current_user()
	
	var text := "[table=3]"
	
	for score in scores:
		var is_current_user = (score.user != null) and current_user.is_same_user(score.user)
		
		var cell_open := "[cell]"
		var expand_cell_open := "[cell expand=2 shrink=false]"
		var cell_close := "[/cell]"
		
		if is_current_user:
			var color_open := "[color=%s]" % highlight_current_user_color.to_html()
			cell_open = cell_open + color_open
			expand_cell_open = expand_cell_open + color_open
			cell_close = "[/color]" + cell_close
		 
		text += cell_open
		if score.rank >= 0:
			text += "%d." % score.rank
		text += cell_close
		
		text += expand_cell_open
		text += _sanitize_bbcode(score.user.get_display_name()) if score.user != null else LeaderboardUserNone.new().get_display_name()
		text += cell_close
		
		text += cell_open
		text += ui_controller.format_score(score.score)
		text += cell_close
	
	text += "[/table]"
	
	_scores_label.text = text
	
	_state = State.SHOWING


func _sanitize_bbcode(text: String) -> String:
	return text.replace("[", "[lb]")


func _advance_loading_animation() -> void:
	var dots := _loading_label.text.count(".")
	
	match dots:
		3:
			_loading_label.text = "Loading."
		1:
			_loading_label.text = "Loading.."
		2, _:
			_loading_label.text = "Loading..."


func _connect_signals() -> void:
	if ui_controller == null:
		return
	
	if not ui_controller.started_loading.is_connected(_on_ui_controller_started_loading):
		ui_controller.started_loading.connect(_on_ui_controller_started_loading)
	
	if not ui_controller.scores_hidden.is_connected(_on_ui_controller_scores_hidden):
		ui_controller.scores_hidden.connect(_on_ui_controller_scores_hidden)
	
	if not ui_controller.scores_shown.is_connected(_on_ui_controller_scores_shown):
		ui_controller.scores_shown.connect(_on_ui_controller_scores_shown)


func _disconnect_signals() -> void:
	if ui_controller == null:
		return
	
	if ui_controller.started_loading.is_connected(_on_ui_controller_started_loading):
		ui_controller.started_loading.disconnect(_on_ui_controller_started_loading)
	
	if ui_controller.scores_hidden.is_connected(_on_ui_controller_scores_hidden):
		ui_controller.scores_hidden.disconnect(_on_ui_controller_scores_hidden)
	
	if ui_controller.scores_shown.is_connected(_on_ui_controller_scores_shown):
		ui_controller.scores_shown.disconnect(_on_ui_controller_scores_shown)


# Signal connection
func _on_ui_controller_started_loading() -> void:
	_state = State.LOADING


# Signal connection
func _on_ui_controller_scores_hidden() -> void:
	_state = State.HIDDEN


# Signal connection
func _on_ui_controller_scores_shown(scores: Array[LeaderboardScore]) -> void:
	_show_scores(scores)


# Signal connection
func _on_loading_animation_timer_timeout() -> void:
	_advance_loading_animation()


# Override
func _exit_tree() -> void:
	_disconnect_signals()
