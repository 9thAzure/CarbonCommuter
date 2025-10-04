extends Node

@export var station_scene: PackedScene
@export var min_distance_between_stations: float = 60.0
@export var max_spawn_attempts: int = 20

var shape_cast: ShapeCast2D

func _ready():
	shape_cast = ShapeCast2D.new()
	add_child(shape_cast)
	
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = min_distance_between_stations
	shape_cast.shape = circle_shape
	
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
	
	var station = station_scene.instantiate()
	station.position = spawn_pos
	station.station_type = randi_range(0, 2)
	add_child(station)

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
