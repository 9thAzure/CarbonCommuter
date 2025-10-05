extends PathFollow2D
class_name Passenger

@export_range(0.1, 10, 0.1, "or_greater")
var icon_size := 5.0

@export_range(0.1, 10, 0.1, "or_greater")
var impatiance_countdown := 20.0

@export_range(0.1, 10, 0.1, "or_greater", "hide_slider")
var speed := 30

var direction := 1

var passenger_type := -1
var target_station : Station

var station_traffic := 0

var path : Array[Array] = []

func _ready() -> void:
	target_station = Station.stations[passenger_type]
	recalculate_path()

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

func _process(delta: float) -> void:
	var time_factor := 1.0
	if get_parent() is Station:
		if get_parent().is_overcrowded():
			time_factor *= 2

		var next_line := get_next_connection()
		if not next_line:
			time_factor *= 4
		elif randf() < 0.01:
			time_factor = 0.5
			var path2d := next_line.path_2d
			assert(path2d is Path2D)
			reparent(path2d, false)
			direction = 1 if is_same(next_line.station2, path[0][0]) else -1
			@warning_ignore("integer_division")
			progress_ratio = (-direction + 1) / 2

	elif get_parent() is Path2D:
		progress += delta * speed * get_parent().get_parent().travel_speed * direction
		time_factor = 0

		if direction == 1 and is_equal_approx(progress_ratio, 1) or direction == -1 and is_equal_approx(progress_ratio, 0):
			if is_same(path[0][0], target_station):
				print("arrived at destination")
				queue_free()
				return

			reparent(path[0][0], false)
			path.pop_front()

	impatiance_countdown -= time_factor


func get_next_connection() -> Line:
	if get_parent() is not Station:
		return
	var current_station := get_parent() as Station

	if path.is_empty():
		return null

	var connection_info := path[0]
	if is_same(connection_info[0], current_station):
		path.remove_at(0)
		return get_next_connection()

	var next_station := connection_info[0] as Station
	var travel_type := connection_info[1] as Line.LineType

	var index := current_station.connected_lines.find_custom(func(line: Line):
		return line.line_type == travel_type and is_same(line.get_other_station(current_station), next_station))

	if index >= 0:
		return current_station.connected_lines[index]

	return null

func recalculate_path() -> void:
	if get_parent() is not Station:
		return

	var current_station := get_parent() as Station
	var start_id : int = TransportGrid.grid.station_ids[current_station]
	var end_id : int = TransportGrid.grid.station_ids[target_station]

	var path_ids : PackedInt64Array = TransportGrid.grid.get_id_path(start_id, end_id)
	path.clear()
	var previous_id := start_id
	for id in path_ids:
		@warning_ignore("INTEGER_DIVISION")
		var station_id := id / 3 * 3
		if previous_id == station_id:
			continue

		var next_station : Station = TransportGrid.grid.station_ids.find_key(station_id)
		path.push_back([next_station, id % 3])
