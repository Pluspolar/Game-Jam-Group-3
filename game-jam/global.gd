extends Node

var string_target: Vector2
var is_swinging: bool = false
var timer: float = 0
var health: float = 100

func _process(delta: float) -> void:
	timer += 100 * delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_swinging:
		await get_tree().create_timer(0.01).timeout
		is_swinging = false
		
