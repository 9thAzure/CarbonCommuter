extends Area2D
class_name Line

@export
var station1 : Station

@export
var station2 : Station

@export
var line_type := LineType.BUS

enum LineType { BUS = 0, METRO, BIKE }

@export
var line_width := 10.0

@export
var line_color := Color.WHITE

var distance := -1.0

@export var base_emission_factor := 1.0
var traffic := 0.0
var passengers_in_transit := []  # Array of {destination: Station, travel_time: float}
@export var base_travel_speed := 50.0  # Units per second
@export var base_carbon_cost := 10.0

var emission_factor := 0
var carbon_cost := 0
var travel_speed := 0

const MODE_PROPERTIES := {
	LineType.BUS: {
		"emission_multiplier": 1.0,
		"cost_multiplier": 1.0,
		"speed_multiplier": 1.0,
		"color": Color.RED
	},
	LineType.METRO: {
		"emission_multiplier": 0.5,  # Metro is cleaner
		"cost_multiplier": 3.0,      # But expensive to build
		"speed_multiplier": 2.0,     # And faster
		"color": Color.BLUE
	},
	LineType.BIKE: {
		"emission_multiplier": 0.0,  # No emissions!
		"cost_multiplier": 0.3,      # Cheap to build
		"speed_multiplier": 0.5,     # But slower
		"color": Color.GREEN
	}
}

func _ready() -> void:
	assert(station1)
	assert(station2)

	set_distance()
	apply_line_mode()

	station1.connected_lines.push_back(self)
	station2.connected_lines.push_back(self)
	queue_redraw()

func get_other_station(this: Station) -> Station:
	assert(this in [station1, station2])

	return station1 if station2 == this else station2

func set_distance() -> void:
	distance = 0
	var path := get_line_path()
	for i in path.size() - 1:
		distance += path[i].distance_to(path[i + 1])

func apply_line_mode() -> void:
	var props = MODE_PROPERTIES[line_type]

	# Apply multipliers
	emission_factor = base_emission_factor * props.emission_multiplier
	travel_speed = base_travel_speed * props.speed_multiplier

	# Set color based on mode
	line_color = props.color
	#assert(distance > 0)

	# Calculate construction cost (will be accurate after _draw calculates distance)
	carbon_cost = distance * base_carbon_cost * props.cost_multiplier

func add_passenger(destination: Station) -> void:
	assert(distance > 0)

	var travel_time = distance / travel_speed
	passengers_in_transit.append({
		"destination": destination,
		"time_remaining": travel_time
	})
	traffic = passengers_in_transit.size()
	
func _process(delta: float) -> void:
	# Update all passengers traveling on this line
	for i in range(passengers_in_transit.size() - 1, -1, -1):
		passengers_in_transit[i].time_remaining -= delta
		
		if passengers_in_transit[i].time_remaining <= 0:
			# Passenger arrived!
			var destination = passengers_in_transit[i].destination
			destination.arrive_passenger()
			passengers_in_transit.remove_at(i)
	
	traffic = passengers_in_transit.size()

func calculate_emissions() -> float:
	assert(distance > 0)
	
	return distance * traffic * emission_factor

func _exit_tree() -> void:
	station1.connected_lines.remove_at(station1.connected_lines.find(self))
	station2.connected_lines.remove_at(station2.connected_lines.find(self))

## Returns an array representing the path between the 2 stations, in global coordinates
func get_line_path() -> PackedVector2Array:
	var position1 := station1.global_position
	var position2 := station2.global_position
	if position2.length_squared() < position1.length_squared():
		var t := position1
		position1 = position2
		position2 = t

	var difference := position2 - position1
	var middle := difference.sign() * difference.abs()[difference.abs().min_axis_index()] / 2
	var points := PackedVector2Array([position1, position1 + middle, position2 - middle, position2])
	return points


func _draw() -> void:
	var points := get_line_path()

	var offset := line_type - 1
	for i in points.size():
		var cross_direction : Vector2
		if i == 0:
			cross_direction = points[0].direction_to(points[1]).orthogonal().normalized()
		elif i == points.size() - 1:
			cross_direction = points[-2].direction_to(points[-1]).orthogonal().normalized()
		else:
			cross_direction = points[i - 1].direction_to(points[i + 1]).orthogonal().normalized()

		points[i] += cross_direction * offset * line_width * 1.5

	for i in points.size():
		points[i] = to_local(points[i])

	draw_polyline(points, line_color, line_width)

	var collision_shape := ConcavePolygonShape2D.new()
	var original_size := points.size()
	points.resize(points.size() * 2 - 2)
	for i in original_size - 1:
		var index := -1 - 2 * i
		points[index] = points[original_size - 1 - i]
		points[index - 1] = points[original_size - 2 - i]
	print(points)
	#points.insert(1, points[1])
	collision_shape.segments = points
	get_node("CollisionShape2D").shape = collision_shape

func get_construction_cost() -> float:
	return carbon_cost
