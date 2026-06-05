extends Area2D

func _process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			Global.health -= 80 * delta
			get_parent().get_node("Player").position.y -= 100 * delta
			get_parent().get_node("Player").velocity.y -= 4000 * delta
			
	position.y -= 100 * delta
