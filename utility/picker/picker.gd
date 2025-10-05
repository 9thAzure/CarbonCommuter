extends ShapeCast2D

func get_object_at(at_position: Vector2) -> Area2D:
	position = at_position
	force_shapecast_update()
	
	if not is_colliding():
		return null
		
	var count := get_collision_count()
	var first_line : Line = null
	
	for i in count:
		var node := get_collider(i)
		if node is Station:
			return node as Area2D
		if node is Line and !first_line:
			first_line = node as Line	
			
	return first_line as Area2D
	
