extends Node

@export var hud: CanvasLayer = null

@export var station_scene: PackedScene
@export var min_distance_between_stations: float = 60.0
@export var max_spawn_attempts: int = 20

@export var initial_spawn_count := 4

@export
var max_recordings := 10
var previous_total := 0.0
var previous_rates : Array[float] = []


var shape_cast: ShapeCast2D

func _ready():
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

	for i in initial_spawn_count:
		spawn_station()
	
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

#func _process(_delta: float) -> void:
	## Calculate total emissions from all lines
	#var total_emissions = 0.0
	#var total_cost := 1000.0
	#for l in Line.list_of_lines:
		#total_emissions += l.calculate_emissions()
		#total_cost -= l.calculate_carbon_cost()
	#
	#if hud:
		#hud.total_carbon_emitted = total_emissions
		#hud.current_average_emissions = total_cost

func _on_game_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menus/mainmenu.tscn")

func _exit_tree() -> void:
	Station.stations.clear()
	Line.list_of_lines.clear()


func _on_refresh_stats_timer_timeout() -> void:
	var total := EmissionTracker.total_emitted
	hud.total_carbon_emitted = total
	var rate := (total - previous_total) / 0.5
	if previous_rates.size() == max_recordings:
		previous_rates.pop_front()
	previous_rates.push_back(rate)

	hud.current_average_emissions = previous_rates.reduce(func(f1: float, f2:float) -> float: return f1 + f2) / previous_rates.size()
	previous_total = total
