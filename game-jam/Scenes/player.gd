extends CharacterBody2D
class_name Player

@export var speed: float = 200
@export var gravity: float = 1000

var already_on_wall : bool = false
var is_sticking: bool = false
var cast_entered: bool = false
var hitbox_half_width: float = 24/2

#func _ready() -> void:
#	position = Vector2(640, 360)
	
func _physics_process(delta: float) -> void:

	velocity.x *= pow(0.985, 60 * delta)
	var can_climb : bool = Input.is_action_pressed("climb") and abs(position.x-Global.string_target.x) < 13

	if can_climb and Global.is_swinging and position.y > Global.string_target.y and velocity.y*0.4 + position.y > Global.string_target.y and abs(velocity.x) + abs(velocity.y) <= 200:
		velocity.x *= pow(0.92, 60 * delta)
		velocity += position.direction_to(Global.string_target) * delta * 50
	elif not (is_on_wall() and abs(get_wall_normal().x) <= 0.8):
		if Global.is_swinging: velocity.y += gravity/1.35 * delta
		else: velocity.y += gravity * delta
		
	if is_sticking:
		velocity.y = 0
	
	if is_on_wall_only():
		velocity.y *= pow(0.4, 60 * delta)
	
	if is_on_floor() or is_on_ceiling(): #or (is_on_wall() and abs(get_wall_normal().x) <= 0.8):
		velocity.x *= pow(0.945, 60 * delta)
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
		
	move_and_slide()
		
	if abs(old_vel.x)*0.5 + abs(old_vel.y) >= 1000:
		if is_on_ceiling():
			$Reversable/particles/up.restart()
		if is_on_floor():
			$Reversable/particles/down.restart()
		
	if abs(old_vel.x) + abs(old_vel.y)*0.5 > 1250:
		if is_on_wall():
			if get_wall_normal().x < 0:
				$Reversable/particles/right.restart()
			else:
				$Reversable/particles/left.restart()
		
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

	if abs(velocity.x) > get_parent().speed_limit : velocity.x = get_parent().speed_limit * abs(velocity.x)/velocity.x
	if abs(velocity.y) > get_parent().speed_limit : velocity.y = get_parent().speed_limit * abs(velocity.y)/velocity.y

	if position.x < hitbox_half_width:
		position.x = hitbox_half_width
		velocity.x = old_vel.x*-0.5
		
	if position.x > get_viewport().size.x - hitbox_half_width:
		position.x = get_viewport().size.x - hitbox_half_width
		velocity.x = old_vel.x*-0.5

func _on_cast_point_area_entered(area: Area2D) -> void:
	cast_entered = true

func _on_cast_point_area_exited(area: Area2D) -> void:
	cast_entered = false
