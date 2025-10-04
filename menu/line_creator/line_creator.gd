extends Node

const line_scene := preload("res://transport/line/line.tscn")

@export
var line_root : Node = null

var station1: Station = null
func _on_popup_manager_create_line(start: Station) -> void:
	station1 = start

func _unhandled_input(event: InputEvent) -> void:
	if not station1:
		return
	
	if event is InputEventMouseButton:
		if not event.pressed:
			return

		var station := Picker.get_object_at(event.global_position)
		if station is not Station:
			return
		
		if station == station1:
			return
		
		for line in station1.connected_lines:
			if line.get_other_station(station1) == station:
				return
		
		# create line
		get_viewport().set_input_as_handled()
		var line: Line = line_scene.instantiate()
		line.station1 = station1
		line.station2 = station
		
		assert(line_root)
		line_root.add_child(line)
		
		station1 = null
		
