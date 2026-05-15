extends CharacterBody2D
class_name Player

@export var speed: float = 200

var already_on_wall : bool = false
var is_sticking: bool = false

func _ready() -> void:
	position = Vector2(640, 360)
	
func _physics_process(delta: float) -> void:
	#var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	#position.y += ((int(Input.is_action_pressed("up"))*-1) + (int(Input.is_action_pressed("down")))) * delta * speed
	#position.x += ((int(Input.is_action_pressed("left"))*-1) + (int(Input.is_action_pressed("right")))) * delta * speed

	velocity.x *= 0.985 / delta * delta
	var can_climb : bool = Input.is_action_pressed("climb") and abs(position.x-Global.string_target.x) < 13
	var dir_to_mouse : Vector2 = position.direction_to(Global.string_target)
	
	if can_climb:
		#position.direction_to(get_viewport().get_mouse_position())
		velocity.x += delta * dir_to_mouse.x * 300
		
	#var temp_vel_y : float = delta * dir_to_mouse.y * 100
	if can_climb and Global.is_swinging and position.y > Global.string_target.y and velocity.y + position.y > Global.string_target.y and abs(velocity.x) + abs(velocity.y) <= 200:
		velocity.x *= 0.95 / delta * delta 
	elif not (is_on_wall() and abs(get_wall_normal().x) <= 0.8):
		velocity.y += 1000 * delta
	#position += velocity * delta
	
	#print(abs(velocity.x) + abs(velocity.y))
	
	if is_sticking:
		velocity.y = 0
	
	if is_on_wall_only():
		velocity.y *= 0.4 / delta * delta
	
	if is_on_floor() or is_on_ceiling(): #or (is_on_wall() and abs(get_wall_normal().x) <= 0.8):
		velocity.x *= 0.945 / delta * delta
		velocity.x += ((int(Input.is_action_pressed("left"))*-1) + (int(Input.is_action_pressed("right")))) * delta * speed
	else: velocity.x += 0.2 * ((int(Input.is_action_pressed("left"))*-1) + (int(Input.is_action_pressed("right")))) * delta * speed
		
	if not Global.is_swinging and is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -300
	
	if not Global.is_swinging and is_on_ceiling() and Input.is_action_just_pressed("jump"):
		is_sticking = false
		velocity.y = 100
			
	if not Global.is_swinging and is_on_wall() and Input.is_action_just_pressed("jump"):
		velocity.y = -300
		
		if get_wall_normal().x < 0:
			velocity.x -= 200
		else:
			velocity.x += 200
		
	var old_vel := velocity
		
		#velocity.y *= -1
		#position.x += velocity.x
			
	#if (is_on_ceiling() or is_on_floor()) and abs(total_velocity) < 500:
	#	velocity.y = 0
		
	move_and_slide()
		
	if is_on_wall() and abs(old_vel.x) + abs(old_vel.y)*0.5 > 1250 and not already_on_wall:
		velocity.x = old_vel.x*-0.1
		already_on_wall = true
	elif not is_on_wall():
		already_on_wall = false
	
	if is_on_ceiling():
		if abs(old_vel.x)*0.5 + abs(old_vel.y) >= 1000:
			velocity.y = old_vel.y*-0.1
			is_sticking = false
		elif abs(old_vel.x)*0.5 + abs(old_vel.y) < 1000:
			velocity.y = 0
			if Global.is_swinging and position.distance_to(Global.string_target) > 400:
				is_sticking = false
			else: is_sticking = true
	else:
		is_sticking = false
		
	#print(velocity.x)
	
	
