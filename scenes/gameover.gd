extends Control


func _on_button_pressed() -> void:
	Stats.current_average_emissions = 0.0
	Stats.total_carbon_emitted = 0
	get_tree().change_scene_to_file("res://scenes/ui/menus/mainmenu.tscn")
