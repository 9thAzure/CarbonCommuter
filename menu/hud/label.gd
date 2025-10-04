extends CanvasLayer

# References to game state (set these from your main game script)
var current_emissions := 0.0
var carbon_budget := 1000.0
var max_budget := 1000.0

@onready var emissions_label = %EmissionLabel
@onready var budget_label = %BudgetLabel
#@onready var budget_bar =

func _ready() -> void:
	update_display()

func _process(_delta: float) -> void:
	update_display()

func update_display() -> void:
	# Update emissions
	emissions_label.text = "Current Emissions: %.1f CO2/s" % current_emissions
	
	# Update budget
	budget_label.text = "Carbon Budget: %.0f / %.0f" % [carbon_budget, max_budget]

func set_emissions(value: float) -> void:
	current_emissions = value

func set_budget(value: float) -> void:
	carbon_budget = clamp(value, 0, max_budget)

func spend_budget(amount: float) -> bool:
	if carbon_budget >= amount:
		carbon_budget -= amount
		return true
	return false
