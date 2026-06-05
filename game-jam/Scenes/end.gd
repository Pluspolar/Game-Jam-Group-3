extends Area2D

func _on_body_entered(body: Node2D) -> void:
	Global.health = 999999
	await get_tree().create_timer(0.1).timeout
	Global._nextlevel()
