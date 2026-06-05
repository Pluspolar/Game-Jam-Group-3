extends Area2D

func _process(_delta: float) -> void:
	if Global.is_healing: $mark_hitbox.disabled = false
	else: $mark_hitbox.disabled = true
