extends PathFollow2D
class_name Passenger

@export_range(0.1, 10, 0.1, "or_greater")
var icon_size := 5.0

#@export
#var icon_color := Color.WHITE

#@export_range(0, 10, 1, "or_greater")
var passenger_type := -1

var station_traffic := 0

func _draw() -> void:
	var color := Station.stations[passenger_type].icon_color
	if passenger_type == 0:
		draw_circle(Vector2.ZERO, icon_size, color)
		return

	var shape := create_regular(passenger_type + 2, icon_size * 1.2)
	draw_colored_polygon(shape, color)

func create_regular(vertices_count: int, size: float) -> PackedVector2Array:
	assert(vertices_count >= 3)
	var arc_angle := TAU / vertices_count
	var points := PackedVector2Array()
	points.resize(vertices_count)
	for i in vertices_count:
		points[i] = Vector2.UP.rotated(arc_angle * i) * size

	return points
