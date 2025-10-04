extends Node

@export var station_scene: PackedScene
@export var passenger_scene: PackedScene

#Adding the stations
@onready var station: Station = $Station
@onready var station_2: Station = $Station2
@onready var station_3: Station = $Station3
@onready var station_4: Station = $Station4
@onready var station_5: Station = $Station5
@onready var station_6: Station = $Station6
@onready var station_7: Station = $Station7
@export var hud: CanvasLayer = null


func _ready():
	var starting_stations: Array[Station] = [station, station_2, station_3, station_4, station_5, station_6, station_7]
	Station.stations.append_array(starting_stations)
	print(Station.stations[0])


func _on_timer_timeout() -> void:
	spawn_station()

func spawn_station():
	var newStation = station_scene.instantiate()
	newStation.position = get_random_spawn_position()
	print(newStation.position)
	newStation.station_type = randi_range(0, 2)
	add_child(newStation)
	Station.stations.append(newStation)

func get_random_spawn_position() -> Vector2:
	var x = randf_range(0, 1152)  # Adjust to your game size
	var y = randf_range(0, 648)
	return Vector2(x, y)

func spawn_passenger():
	var passenger = passenger_scene.instantiate()
	var stationNumber = randi_range(0, Station.stations.size() - 1)
	var stationChosen = Station.stations[stationNumber]
	if (stationChosen != null):
		passenger.position.x = stationChosen.position.x + 30  + 20 * (stationChosen.station_traffic)
		passenger.position.y = stationChosen.position.y
		print(passenger.position.x)
	passenger.passenger_type = randi_range(0, 2)
	while (passenger.passenger_type == stationChosen.station_type):
		passenger.passenger_type = randi_range(0, 2)
	add_child(passenger)
	print("Station Number: " + str(stationNumber))
	Station.stations[stationNumber].add_traffic()
		
	print("Traffic: " + str(Station.stations[stationNumber].station_traffic))
	print("Traffic: " + str(station.station_traffic))

func _on_passenger_creation_timer_timeout() -> void:
	spawn_passenger()

func _process(_delta: float) -> void:
	# Calculate total emissions from all lines
	var total_emissions = 0.0
	for l in Line.list_of_lines:
		total_emissions += l.calculate_emissions()
	
	if hud:
		hud.current_emissions = total_emissions
		
		
