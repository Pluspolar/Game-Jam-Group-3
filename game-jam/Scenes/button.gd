extends Button

var mouse_enter : bool = false
	
func _process(delta: float) -> void:
	if mouse_enter:
		rotation_degrees += (sin(Global.timer/12) * 5 - rotation_degrees) * 0.2 / delta * delta
	else: rotation_degrees += (0 - rotation_degrees) * 0.2 / delta * delta

func _on_mouse_entered() -> void:
	mouse_enter = true

func _on_mouse_exited() -> void:
	mouse_enter = false

func _on_button_down() -> void:
	await get_tree().create_timer(0.05).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
