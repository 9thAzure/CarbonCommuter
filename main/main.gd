extends Node

@export var hud: CanvasLayer = null

@export var station_scene: PackedScene
@export var passenger_scene: PackedScene
@export var min_distance_between_stations: float = 60.0
@export var max_spawn_attempts: int = 20

var shape_cast: ShapeCast2D

#Adding the stations
@onready var station: Station = $Station
@onready var station_2: Station = $Station2
@onready var station_3: Station = $Station3
@onready var station_4: Station = $Station4
@onready var station_5: Station = $Station5
@onready var station_6: Station = $Station6
@onready var station_7: Station = $Station7



func _ready():
	var starting_stations: Array[Station] = [station, station_2, station_3, station_4, station_5, station_6, station_7]
	Station.stations.append_array(starting_stations)
	print(Station.stations[0])


	# Collision checking to preventn overlapping spawn
	shape_cast = ShapeCast2D.new()
	add_child(shape_cast)
	
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = min_distance_between_stations
	shape_cast.shape = circle_shape
	shape_cast.target_position = Vector2.ZERO
	
	shape_cast.enabled = true
	shape_cast.collide_with_areas = true
	shape_cast.set_collision_mask_value(15, true)  # Only detect station layer
	
func _on_timer_timeout() -> void:
	spawn_station()

func spawn_station():
	var spawn_pos = find_valid_spawn_position()
	
	if spawn_pos == Vector2.ZERO:
		print("Could not find valid spawn")
		return
	
	var newStation = station_scene.instantiate()
	newStation.position = spawn_pos
	print(newStation.position)
	newStation.station_type = randi_range(0, 2)
	add_child(newStation)
	Station.stations.append(newStation)

func find_valid_spawn_position() -> Vector2:
	for attempt in range(max_spawn_attempts):
		var test_pos = get_random_spawn_position()
		
		shape_cast.position = test_pos
		shape_cast.force_shapecast_update()
		
		if not shape_cast.is_colliding():
			return test_pos
		
		# Optional: print collision info for debugging
		# print("Collision detected at ", test_pos, " with ", shape_cast.get_collider(0))
	
	return Vector2.ZERO
	
func get_random_spawn_position() -> Vector2:
	var x = randf_range(0, 1152)  # Adjust to your game size
	var y = randf_range(0, 648)
	return Vector2(x, y)

func _process(_delta: float) -> void:
	# Calculate total emissions from all lines
	var total_emissions = 0.0
	for l in Line.list_of_lines:
		total_emissions += l.calculate_emissions()
	
	if hud:
		hud.current_emissions = total_emissions
		
		
