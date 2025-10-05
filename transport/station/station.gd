extends Area2D
class_name Station
var passenger_scene := preload("res://passengers/passenger.tscn")

@export_range(0.1, 10, 0.1, "or_greater")
var icon_size := 10.0

@export
var icon_color := Color.WHITE

@export_range(0, 10, 1, "or_greater")
var station_type := 0

@export
var passenger_weight := 10.0

static var stations : Array[Station] = []

var connected_lines : Array[Line] = []

var waiting_passengers : Array[Passenger] = []

var station_traffic := 0

var station_max_capacity := 6

func is_overcrowded() -> bool : return waiting_passengers.size() > station_max_capacity

func _ready() -> void:
	station_type = stations.size()
	icon_color.h = fmod(icon_color.h + 1.61803 * station_type, 1)
	stations.push_back(self)
	TransportGrid.grid.add_station(self)

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

func send_passenger():
	if station_traffic <= 0:
		return
	if connected_lines.is_empty():
		return
	var random_line = connected_lines.pick_random()
	var destination = random_line.station1 if random_line.station2 == self else random_line.station2
	station_traffic -= 1
	random_line.add_passenger(destination)

func _on_spawn_traffic_timer_timeout() -> void:
	var next_time := randf() * 10 + 2
	%"SpawnTrafficTimer".wait_time = next_time
	spawn_passenger()

func arrive_passenger() -> void:
	# Passenger has arrived and despawns
	pass

func spawn_passenger():
	var passenger := passenger_scene.instantiate()
	passenger.position.x = 30 + 20 * (station_traffic)
	passenger.position.y = 0

	passenger.passenger_type = station_type
	while passenger.passenger_type == station_type:
		passenger.passenger_type = randi_range(0, stations.size() - 1)

	add_child(passenger)

func _on_child_entered_tree(node: Node) -> void:
	if node is Passenger:
		var insert_i := waiting_passengers.bsearch_custom(node as Passenger, func(p1: Passenger, p2: Passenger) -> bool:
			return p1.get_index() <= p2.get_index())

		waiting_passengers.insert(insert_i, node)
		update_passenger_positions()

func _on_child_exiting_tree(node: Node) -> void:
	if node is Passenger:
		waiting_passengers.erase(node)
		update_passenger_positions()

func update_passenger_positions() -> void:
	const PASSENGER_SHRINK_THRESHOLD := 4
	var seperation := 20.0
	TransportGrid.grid.set_station_weight_scale(self, waiting_passengers.size() * passenger_weight)
	if waiting_passengers.size() > PASSENGER_SHRINK_THRESHOLD:
		seperation /= waiting_passengers.size() * 1.0 / PASSENGER_SHRINK_THRESHOLD
	
	for i in waiting_passengers.size():
		var passenger := waiting_passengers[i]
		passenger.position.x = 30 + seperation * i
		passenger.position.y = 0
