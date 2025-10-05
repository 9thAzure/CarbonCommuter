extends Node

@onready
var station_popup : PopupPanel = %"StationMenu"

@onready
var line_popup : PopupPanel = %"LineMenu"

signal create_line(start: Station)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var found_node := Picker.get_object_at(event.global_position)
		print(found_node)
		if found_node is Station:
			station_popup.popup_station(found_node as Station)
			get_viewport().set_input_as_handled()
		if found_node is Line:
			line_popup.popup_line(found_node as Line)
			get_viewport().set_input_as_handled()
			



func _on_line_menu_destroy_line(line: Line) -> void:
	line.get_parent().remove_child(line)
	line.queue_free()


func _on_station_menu_create_line(start: Station) -> void:
	create_line.emit(start)
