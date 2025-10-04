extends Node2D
class_name Line

@export
var station1 : Station

@export
var station2 : Station

@export
var line_type := 0

@export
var line_width := 10.0

@export
var line_color := Color.WHITE

var distance := -1.0

func _ready() -> void:
	assert(station1)
	assert(station2)

	station1.connected_lines.push_back(self)
	station2.connected_lines.push_back(self)

func _exit_tree() -> void:
	station1.connected_lines.remove_at(station1.connected_lines.find(self))
	station2.connected_lines.remove_at(station2.connected_lines.find(self))

## Returns an array representing the path between the 2 stations, in global coordinates
func get_line_path() -> PackedVector2Array:
	var position1 := station1.global_position
	var position2 := station2.global_position
	if position2.length_squared() < position2.length_squared():
		var t := position1
		position1 = position2
		position2 = t

	var difference := position2 - position1
	var middle := difference.sign() * difference[difference.min_axis_index()]

	var points := PackedVector2Array([position1, position1 + middle, position2])
	return points


func _draw() -> void:
	var points := get_line_path()

	distance = 0
	for i in points.size() - 1:
		distance += points[i].distance_to(points[i + 1])
		points[i] = to_local(points[i])
	points[-1] = to_local(points[-1])

	draw_polyline(points, line_color, line_width)
