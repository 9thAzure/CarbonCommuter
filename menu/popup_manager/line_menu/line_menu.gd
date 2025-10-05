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
	
	%VehicleCountEditorContainer.hide()
	if current_line.line_type == Line.LineType.BIKE:
		%VehicleCountEditButton.hide()
	else:
		%VehicleCountEditButton.show()
		%VehicleCountEditButton.text = "Vehicles: " + str(current_line.vehicles_on_line)
		%VehicleCountEditor.value = current_line.vehicles_on_line
		%VehicleCountEditor.max_value = Line.MODE_PROPERTIES[current_line.line_type]["max_vehicles"]
		

func _on_destroy_button_pressed() -> void:
	destroy_line.emit(current_line)
	hide()


func _on_confirm_pressed() -> void:
	var new_count := %VehicleCountEditor.value as int
	%VehicleCountEditButton.text = "Vehicles: " + str(new_count)
	var change := new_count - current_line.vehicles_on_line
	current_line.vehicles_on_line = new_count
	EmissionTracker.total_emitted += max(0, change) * Line.MODE_PROPERTIES[current_line.line_type]["vehicle_cost"]

func _on_cancel_pressed() -> void:
	%VehicleCountEditor.value = current_line.vehicles_on_line
