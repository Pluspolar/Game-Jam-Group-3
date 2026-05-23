extends Label


func _process(delta: float) -> void:
	rotation_degrees += (sin(Global.timer/29) * 1.5 - rotation_degrees) * 0.4 * 60 * delta
	scale.x += (1.02-(sin(Global.timer/18) * 0.02) - scale.x) * 0.4 * 60 * delta
	scale.y = scale.x
