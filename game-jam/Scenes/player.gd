extends CharacterBody2D
class_name Player

@export var speed: float = 200
@export var gravity: float = 1000
@export var fall_multiplier: float = 0.0035
@export var movement_damage: float = 0.035
@export var wall_jump_dmg: float = 2
@export var jump_dmg: float = 8.0

var vel_x : float = 0.0
var already_on_wall : bool = false
var is_sticking: bool = false
var cast_entered: bool = false
var hitbox_half_width: float = 24.0/2.0
var hurt_timer: float = 0
var hurtjump_timer: float = 0
var thread: Thread
@onready var sprite_anim := $Reversable/animation

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
	
	if hurt_timer <= 0:
		vel_x = 0
		if is_on_floor() or is_on_ceiling(): #or (is_on_wall() and abs(get_wall_normal().x) <= 0.8):
			velocity.x *= pow(0.945, 60 * delta)
			vel_x = ((int(Input.is_action_pressed("left"))*-1) + (int(Input.is_action_pressed("right")))) * delta * speed
			if abs(vel_x) > 0: 
				sprite_anim.call_deferred("set_modulate", Color(0.8, 0, 0, 1))
			elif hurtjump_timer <= 0: sprite_anim.call_deferred("set_modulate", Color(1, 1, 1, 1))
			
			Global.health -= abs(vel_x) * movement_damage
			
		else: 
			vel_x = 0.2 * ((int(Input.is_action_pressed("left"))*-1) + (int(Input.is_action_pressed("right")))) * delta * speed
			if hurtjump_timer <= 0: sprite_anim.call_deferred("set_modulate", Color(1, 1, 1, 1))
			
		velocity.x += vel_x
		
	if not Global.is_swinging and is_on_floor() and Input.is_action_just_pressed("jump"):
		_hurt_jump(jump_dmg)
		velocity.y = -300
	
	if not Global.is_swinging and is_on_ceiling() and Input.is_action_just_pressed("jump"):
		is_sticking = false
		velocity.y = 100
			
	if not Global.is_swinging and is_on_wall() and Input.is_action_just_pressed("jump"):
		velocity.y = -300
		_hurt_jump(wall_jump_dmg)
		
		if get_wall_normal().x < 0:
			velocity.x -= 200
		else:
			velocity.x += 200
		
	var old_vel := velocity
		
	if velocity.x > 0:
		$Reversable.scale.x = 1
	elif velocity.x < 0:
		$Reversable.scale.x = -1
		
	if is_on_ceiling():
		$Reversable.scale.y = -1
	else: $Reversable.scale.y = 1
		
	move_and_slide()
		
	if is_on_wall() and abs(old_vel.x) + abs(old_vel.y)*0.5 > 1250 and not already_on_wall:
		velocity.x = old_vel.x*-0.1
		already_on_wall = true
		_hurt(abs(old_vel.x)*fall_multiplier)
		if get_wall_normal().x < 0:
			$Reversable/particles/right.restart()
		else:
			$Reversable/particles/left.restart()
	elif not is_on_wall():
		already_on_wall = false
	
	if is_on_ceiling():
		if abs(old_vel.x)*0.5 + abs(old_vel.y) >= 1000:
			_hurt(abs(old_vel.y)*fall_multiplier)
			$Reversable/particles/up.restart()
			velocity.y = old_vel.y*-0.1
			is_sticking = false
		elif abs(old_vel.x)*0.5 + abs(old_vel.y) < 1000:
			velocity.y = 0
			if Global.is_swinging and position.distance_to(Global.string_target) > 400:
				is_sticking = false
			else: is_sticking = true
		
	else: is_sticking = false
			
	if is_on_floor() or (is_on_wall() and abs(get_wall_normal().x) < 0.8):
		if abs(old_vel.x)*0.5 + abs(old_vel.y) >= 1000:
			_hurt(abs(old_vel.y)*fall_multiplier)
			velocity.y = old_vel.y*-0.2
			is_sticking = false
			$Reversable/particles/down.restart()

	if abs(velocity.x) > get_parent().speed_limit : velocity.x = get_parent().speed_limit * abs(velocity.x)/velocity.x
	if abs(velocity.y) > get_parent().speed_limit : velocity.y = get_parent().speed_limit * abs(velocity.y)/velocity.y

	if position.x < hitbox_half_width:
		position.x = hitbox_half_width
		velocity.x = old_vel.x*-0.5
		
	if position.x > get_viewport_rect().size.x - hitbox_half_width:
		position.x = get_viewport_rect().size.x - hitbox_half_width
		velocity.x = old_vel.x*-0.5
		
	var overlapping_areas = $cast_point.get_overlapping_areas()
	if overlapping_areas.size() > 0: cast_entered = true
	else: cast_entered = false
	
	if hurt_timer > 0:
		hurt_timer -= 1 * delta
		sprite_anim.play("hurt")
	elif not is_on_floor() and not is_on_ceiling(): 
		if velocity.y > 650 and not Global.is_swinging:
			sprite_anim.play("fall")
		else:
			sprite_anim.play("jump")
	else:
		if abs(vel_x) > 0:
			sprite_anim.play("walk")
		else: sprite_anim.play("idle")
	
	if hurtjump_timer > 0:
		hurtjump_timer -= 1 * delta
	
	if Global.health <= 0:
		hurt_timer = 1
		is_sticking = false
		sprite_anim.call_deferred("set_modulate", Color(0.5, 0, 0, 1))
		sprite_anim.play("fall")

func _hurt(damage : float) -> void:
	thread = Thread.new()
	hurt_timer = 0.3
	Global.is_swinging = false
	Global.health -= pow(damage, 2)
	thread.start(_hurt_white)
	
func _hurt_jump(damage : float) -> void:
	thread = Thread.new()
	hurtjump_timer = damage * 0.04375
	Global.is_swinging = false
	Global.health -= damage
	thread.start(_hurt_white)
	
func _hurt_white():
	if hurt_timer <= 0: 
		sprite_anim.call_deferred("set_modulate", Color(1.5-(hurtjump_timer*1.5), 0, 0, 1))
		await get_tree().create_timer(hurtjump_timer).timeout
	else: 
		sprite_anim.call_deferred("set_modulate", Color(2, 0, 0, 1))
		await get_tree().create_timer(hurt_timer).timeout
	if Global.health > 0: sprite_anim.call_deferred("set_modulate", Color(1, 1, 1, 1))

	
