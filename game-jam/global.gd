extends Node

var string_target: Vector2
var is_swinging: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		string_target = get_viewport().get_mouse_position()
		is_swinging = true
	if event.is_action_pressed("jump") and is_swinging:
		await get_tree().create_timer(0.01).timeout
		is_swinging = false
		
