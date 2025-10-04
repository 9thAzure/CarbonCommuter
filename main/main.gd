extends Node

@export var station_scene: PackedScene

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
