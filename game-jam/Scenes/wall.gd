extends CharacterBody2D

func _process(delta: float) -> void:
	position.y = get_parent().get_node("Player").position.y - 240
