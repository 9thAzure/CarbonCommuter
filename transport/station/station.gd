extends Node2D
class_name Station

@export_range(0.1, 10, 0.1, "or_greater")
var icon_size := 10.0

@export
var icon_color := Color.WHITE

@export_range(0, 10, 1, "or_greater")
var station_type := 0

var connected_lines : Array[Line] = []

func _draw() -> void:
	var collision_shape : Shape2D
	if station_type == 0:
		draw_circle(Vector2.ZERO, icon_size, icon_color)
		collision_shape = CircleShape2D.new()
		collision_shape.radius = icon_size
		get_node("CollisionShape2D").shape = collision_shape
		return

	var shape := create_regular(station_type + 2, icon_size * 1.2)
	draw_colored_polygon(shape, icon_color)
	collision_shape = ConvexPolygonShape2D.new()
	collision_shape.points = shape
	get_node("CollisionShape2D").shape = collision_shape

func create_regular(vertices_count: int, size: float) -> PackedVector2Array:
	assert(vertices_count >= 3)
	var arc_angle := TAU / vertices_count
	var points := PackedVector2Array()
	points.resize(vertices_count)
	for i in vertices_count:
		points[i] = Vector2.UP.rotated(arc_angle * i) * size

	return points
