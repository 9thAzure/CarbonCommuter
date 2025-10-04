extends Area2D
class_name Line

@export
var station1 : Station

@export
var station2 : Station

@export
var line_type := LineType.BUS

enum LineType { BUS, METRO, BIKE }

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

const MODE_PROPERTIES = {
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
	apply_line_mode()

	station1.connected_lines.push_back(self)
	station2.connected_lines.push_back(self)

func apply_line_mode() -> void:
	var props = MODE_PROPERTIES[line_type]
	
	# Apply multipliers
	emission_factor = base_emission_factor * props.emission_multiplier
	travel_speed = base_travel_speed * props.speed_multiplier
	
	# Set color based on mode
	line_color = props.color
	assert(distance > 0)
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
	
	if carbon_cost == 0.0:  # Only calculate once
		var props = MODE_PROPERTIES[line_type]
		carbon_cost = distance * base_carbon_cost * props.cost_multiplier

	draw_polyline(points, line_color, line_width)
	var collision_shape := ConcavePolygonShape2D.new()
	points.insert(1, points[1])
	collision_shape.segments = points
	get_node("CollisionShape2D").shape = collision_shape

func get_construction_cost() -> float:
	return carbon_cost
