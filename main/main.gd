extends Node

@export var station_scene: PackedScene
@export var hud: CanvasLayer = null

func _on_timer_timeout() -> void:
	spawn_station()

func spawn_station():
	var station = station_scene.instantiate()
	station.position = get_random_spawn_position()
	print(station.position)
	station.station_type = randi_range(0, 2)
	add_child(station)

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
		
		
