extends Button

var mouse_enter : bool = false
var speed_scale : float = 0
var target_scale : float = 1
	
func _on_cast_point_area_entered(_area: Area2D) -> void:
	pass #cast_entered = true

func _on_cast_point_area_exited(_area: Area2D) -> void:
	pass #cast_entered = false
	
func _process(delta: float) -> void:
	if mouse_enter:
		target_scale = 1.15
		#if speed_scale <= 0.04:
		#	rotation_degrees += (sin(Global.timer/12) * 5 - rotation_degrees) * 0.2 * 60 * delta
	else: 
		target_scale = 1
		#rotation_degrees += ((0+speed_scale*300) - rotation_degrees) * 0.5 * 60 * delta
	
	rotation_degrees += ((0+speed_scale*300+(sin(Global.timer/21)*2)) - rotation_degrees) * 0.5 * 60 * delta
	speed_scale = (((target_scale-scale.x) * 0.2) + (speed_scale * 0.6))
	#speed_scale = ((target_scale-scale.x) * 0.15)
	scale += Vector2(speed_scale, speed_scale) * 60 * delta
	
func _on_mouse_entered() -> void:
	mouse_enter = true

func _on_mouse_exited() -> void:
	mouse_enter = false

func _on_button_down() -> void:
	await get_tree().create_timer(0.05).timeout
	get_tree().quit()
	
#print(get_viewport().size)
'''func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if raycast_wall.is_colliding() or raycast_silky.is_colliding():
			if str(raycast_wall.get_collider()).containsn("solid"): 
				Global.string_target = raycast_wall.get_collision_point()
				Global.is_swinging = true
				
			elif player.cast_entered: 
				Global.string_target = raycast_silky.get_collision_point()
				Global.is_swinging = true'''
