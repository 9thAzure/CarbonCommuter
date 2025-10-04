extends Area2D
class_name Station
var passenger_scene = preload("res://passengers/passenger.tscn")


@export_range(0.1, 10, 0.1, "or_greater")
var icon_size := 10.0

@export
var icon_color := Color.WHITE

@export_range(0, 10, 1, "or_greater")
var station_type := 0

static var stations : Array[Station] = []

var connected_lines : Array[Line] = []

var station_traffic := 0
	
	
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
	var wait_time := randf() * 10 + 2
	await get_tree().create_timer(wait_time).timeout
	spawn_passenger()

func arrive_passenger() -> void:
	# Passenger has arrived and despawns
	pass

func add_traffic() -> void:
	station_traffic += 1
	print("Station Traffic" + str(station_traffic))

func spawn_passenger():
	var passenger = passenger_scene.instantiate()
	print(passenger.position.x)
	passenger.position.x = 30 + 20 * (station_traffic)
	passenger.position.y = 0
	print(passenger.position.x)
	print(position.x)
	passenger.passenger_type = randi_range(0, 2)
	while (passenger.passenger_type == station_type):
		passenger.passenger_type = randi_range(0, 2)
	add_child(passenger)
	add_traffic()
	print(passenger.position.x)
	print(position.x)
