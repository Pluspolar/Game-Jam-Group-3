extends Label


func _process(delta: float) -> void:
	rotation_degrees += (sin(Global.timer/24) * 1.5 - rotation_degrees) * 0.4 / delta * delta
	scale.x += (1.025-(sin(Global.timer/12) * 0.025) - scale.x) * 0.4 / delta * delta
	scale.y = scale.x
