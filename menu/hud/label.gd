extends CanvasLayer

# References to game state (set these from your main game script)
var current_emissions := 0.0
var carbon_budget := 1000.0
var max_budget := 1000.0

@onready var panel = $Panel
@onready var emissions_label = $Panel/VBoxContainer/EmissionsLabel
@onready var budget_label = $Panel/VBoxContainer/BudgetLabel
@onready var budget_bar = $Panel/VBoxContainer/BudgetBar

func _ready() -> void:
	setup_ui()

func setup_ui() -> void:
	# Create panel if it doesn't exist
	if not has_node("Panel"):
		panel = Panel.new()
		panel.position = Vector2(10, 10)
		panel.size = Vector2(300, 120)
		add_child(panel)
		
		# Create container for layout
		var vbox = VBoxContainer.new()
		vbox.position = Vector2(10, 10)
		vbox.add_theme_constant_override("separation", 10)
		panel.add_child(vbox)
		
		# Emissions label
		emissions_label = Label.new()
		emissions_label.add_theme_font_size_override("font_size", 16)
		vbox.add_child(emissions_label)
		
		# Budget label
		budget_label = Label.new()
		budget_label.add_theme_font_size_override("font_size", 16)
		vbox.add_child(budget_label)
	
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
