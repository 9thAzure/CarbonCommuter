extends Node
@export var hud: CanvasLayer = null
const line_scene := preload("res://transport/line/line.tscn")

@export
var line_root: Node = null

@onready
var line_type_selector := %"LineTypeSelector"

var station1: Station = null:
	set(value):
		station1 = value
		if value:
			get_child(0).show()
		else:
			get_child(0).hide()
		
func _ready() -> void:
	station1 = null
	line_type_selector.select(0)
	
func _on_popup_manager_create_line(start: Station) -> void:
	station1 = start

func _unhandled_input(event: InputEvent) -> void:
	if not station1:
		return
	
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton:
		if not event.pressed:
			return

		var station := Picker.get_object_at(event.global_position)
		if station is not Station:
			return
		
		if station == station1:
			return

		var line_type := line_type_selector.get_selected_items()[0] as int
		for line in station1.connected_lines:
			if line.get_other_station(station1) == station and line.line_type == line_type:
				return
		
		# create line
		print(["Bus", "subway", "bike"][line_type_selector.get_selected_items()[0]])
		var line: Line = line_scene.instantiate()
		line.station1 = station1
		line.station2 = station
		line.line_type = line_type as Line.LineType
		
		assert(line_root)
		line_root.add_child(line)
		
		station1 = null
		


func _on_cancel_button_pressed() -> void:
	station1 = null
