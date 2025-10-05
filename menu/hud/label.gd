class_name Stats extends CanvasLayer

# References to game state (set these from your main game script)
static var current_average_emissions := 0.0
static var total_carbon_emitted := 0.0
static var max_units := 1000.0
static var emissions_per_car = 10

@onready var average_emissions_label = %AverageEmissionLabel
@onready var total_emissions_label = %TotalEmissionLabel
#@onready var budget_bar =
func _ready() -> void:
	# Make UI non-blocking
	
	# Make all children ignore mouse too
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			# Recursively set for nested children
			_set_mouse_filter_recursive(child)
	
	update_display()

func _set_mouse_filter_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_mouse_filter_recursive(child)

func _process(_delta: float) -> void:
	update_display()

func update_display() -> void:
	# Update emissions
	average_emissions_label.text = "Current Average Emissions: %.1f CO2/s" % current_average_emissions
	
	# Update budget
	total_emissions_label.text = "Total Carbon Emissions: %.0f" % [total_carbon_emitted]

func set_current_average_emissions(value: float) -> void:
	current_average_emissions = value
	
func add_current_average_emissions(value: float) -> void:
	current_average_emissions += value

func set_total_carbon_emissions(value: float) -> void:
	total_carbon_emitted = clamp(value, 0, max_units)

static func add_units(value: float) -> void:
	total_carbon_emitted = clamp(total_carbon_emitted + value, 0, max_units)

static func remove_units(value: float) -> void:
	total_carbon_emitted = clamp(total_carbon_emitted - value, 0, max_units)

func update_units(amount: float) -> bool:
	if total_carbon_emitted <= amount:
		total_carbon_emitted += amount
		return true
	return false
