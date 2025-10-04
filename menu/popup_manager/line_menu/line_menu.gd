extends PopupPanel

var current_line : Line = null
signal destroy_line(line: Line)

func popup_line(line: Line) -> void:
	assert(line)
	current_line = line
	var popup_size := Rect2i(line.get_global_mouse_position(), size)
	popup.call_deferred(popup_size)

func _on_about_to_popup() -> void:
	assert(current_line)

func _on_destroy_button_pressed() -> void:
	destroy_line.emit(current_line)
