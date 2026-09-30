extends PanelContainer

signal back


# Signal connection
func _on_button_back_pressed() -> void:
	back.emit()
