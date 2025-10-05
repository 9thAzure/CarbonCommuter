extends AStar2D
class_name TransportNavigator

var line_types := 3
var station_ids : Dictionary[Station,int] = {}

var transfer_cost := 10

func _compute_cost(from_id: int, to_id: int) -> float:
	if from_id % line_types == to_id % line_types:
		assert(absi(to_id - from_id) <= 3)
		return transfer_cost

	var line_type := from_id % 3 as Line.LineType
	var line_stats : Dictionary = Line.MODE_PROPERTIES[line_type]

	var speed := line_stats["speed_multiplier"] as float

	return ((get_point_position(from_id) - get_point_position(to_id)) / speed).length_squared()

func add_station(station: Station) -> void:
	var id := get_available_point_id()
	for i in line_types:
		assert(not has_point(id + i), str(id + i))

	var position := station.global_position
	for i in line_types:
		add_point(id + i, position)

	for i in line_types:
		for i2 in line_types - i - 1:
			i2 += i + 1
			connect_points(id + i, id + i2, true)

	station_ids.set(station, id)

func connect_stations(station1: Station, station2: Station, line_type: Line.LineType) -> void:
	assert(station1 in station_ids)
	assert(station2 in station_ids)
	assert(line_type < line_types)

	var id1 := station_ids[station1] + line_type as int
	var id2 := station_ids[station2] + line_type as int

	connect_points(id1, id2, true)

func disconnect_stations(station1: Station, station2: Station, line_type: Line.LineType) -> void:
	assert(station1 in station_ids)
	assert(station2 in station_ids)
	assert(line_type < line_types)

	var id1 := station_ids[station1] + line_type as int
	var id2 := station_ids[station2] + line_type as int

	disconnect_points(id1, id2, true)

func set_station_weight_scale(station: Station, weight: float) -> void:
	assert(station in station_ids)

	var id := station_ids[station]
	for i in line_types:
		set_point_weight_scale(id + i, weight)
