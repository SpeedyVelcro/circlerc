extends PanelContainer

signal back

# Signal connection
func _on_back_button_pressed() -> void:
	back.emit()
