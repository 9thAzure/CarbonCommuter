extends PopupPanel

var current_station : Station = null
signal create_line(start: Station)

func popup_station(station: Station) -> void:
	assert(station)
	current_station = station
	var popup_size := Rect2i(station.global_position as Vector2i, size)
	popup.call_deferred(popup_size)

func _on_about_to_popup() -> void:
	assert(current_station)
	

func _on_create_line_button_pressed() -> void:
	create_line.emit(current_station)
	hide()
