extends CanvasLayer

@onready var score_label = %ScoreLabel  # Use unique name for the score label

func _ready() -> void:
	# Display the final emission score
	score_label.text = "Your emission score was: %.1f kg of CO2" % Stats.total_carbon_emitted
	
	# Optional: Show other stats
	# "Carbon budget remaining: %.0f" % Stats.carbon_budget
