extends Control

@onready
var station_popup : PopupPanel = %"StationMenu"

@onready
var line_popup : PopupPanel = %"LineMenu"

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var found_node := Picker.get_object_at(event.global_position)
		print(found_node)
		if found_node is Station:
			station_popup.popup_station(found_node as Station)
		if found_node is Line:
			line_popup.popup_line(found_node as Line)
			
