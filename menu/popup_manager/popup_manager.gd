extends Control

@onready
var station_popup : PopupPanel = %"StationMenu"

@onready
var line_popup : PopupPanel = %"LineMenu"

signal create_line(start: Station)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var found_node := Picker.get_object_at(event.global_position)
		print(found_node)
		if found_node is Station:
			station_popup.popup_station(found_node as Station)
		if found_node is Line:
			line_popup.popup_line(found_node as Line)
			



func _on_line_menu_destroy_line(line: Line) -> void:
	line.queue_free()


func _on_station_menu_create_line(start: Station) -> void:
	create_line.emit(start)
