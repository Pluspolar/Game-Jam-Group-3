extends Area2D

@export var speed: float = 200

func _process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			Global.health -= 550 * delta
			get_parent().get_node("Player").position.y -= 100 * delta
			get_parent().get_node("Player").velocity.y = -700
		
	position.y -= speed * delta
