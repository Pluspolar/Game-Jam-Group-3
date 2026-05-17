extends Node2D

var mouse_entered : bool = false

func _on_silky_wall_mouse_entered() -> void:
	mouse_entered = true

func _on_silky_wall_mouse_exited() -> void:
	mouse_entered = false
