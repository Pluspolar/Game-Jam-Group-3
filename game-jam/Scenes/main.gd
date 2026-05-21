extends Node2D
var line: Line2D

@onready var player := $Player
@onready var cam := $Cam
@onready var raycast_wall := $Player/RayCast_wall
@onready var raycast_point := $Player/cast_point/point
@onready var raycast_silky := $Player/RayCast_silky
@export var string_amount : float = 40 #Use Even Number
@export var stretchiness : float = 400
@export var x_stretch : float = 0.75  #it's better to be between 0-1, it streches more based on the x axis
@export var vel_y_pitfall : float = 125 #Prevent infinite velocity at the absolute value of the velocity
@export var vel_y_air_resist : float = 0.98 #to get the value
@export var speed_limit: float = 10000
@export var string_power: float = 1.5
@export var player_range: float = 400.0
@onready var old_cam : Vector2 = cam.position

var global_mouse_pos : Vector2
var strecth_amount : float = 0
var distance : float
var cam_wobble : Vector2 = Vector2(0,0)

func _ready() -> void:
	
	line = Line2D.new()
	add_child(line)
	
	line.width = 4.5
	line.default_color = Color(1, 1, 1, 0.5)
	line.antialiased = true
	
func _process(delta: float) -> void:
	global_mouse_pos = get_global_mouse_position()
	
	_swing_velocity(delta)
	_cam(delta)
	_raycast()
	
func create_line(player_pos: Vector2):
	distance = player_pos.distance_to(Global.string_target)
	line.width = 4.5/(((pow(distance, 1.5)*0.000075))+1)
	line.clear_points()
	line.add_point(player_pos)
	var line_coords : Vector2 = player_pos
	var mouse_0 := Vector2(Global.string_target.x - player_pos.x, Global.string_target.y - player_pos.y)
	
	for i in range (string_amount-1):
		line_coords += Vector2(mouse_0.x/string_amount, mouse_0.y/string_amount)
		line.add_point(line_coords)
		
	for i in range (1, string_amount):
		strecth_amount = sin((i/string_amount)*3.14) * stretchiness *(pow(abs(player_pos.x-Global.string_target.x), x_stretch)/100) * 1/(((pow(distance, 2)*0.0001))+1) #1/((pow(abs(player.velocity.x), 0.3)*0.1)+1)
		line_coords = Vector2(line.get_point_position(i).x, line.get_point_position(i).y+strecth_amount) #+ cos(i/(3.14/2))*2.5)
		line.set_point_position(i, line_coords)
		
	line.add_point(Global.string_target)
	
func _swing_velocity(delta : float) -> void:
	if Global.is_swinging:
		var dir_vel = player.position.direction_to(Global.string_target)
		
		distance = pow(distance, 2)
		
		player.velocity += Vector2(dir_vel.x * distance/50, dir_vel.y * distance/50) * delta * string_power
		if abs(player.velocity.y) > vel_y_pitfall: player.velocity.y *= pow(vel_y_air_resist, 60 * delta) #Patched infinite energy
		
		if abs(player.velocity.x) > speed_limit: player.velocity.x = speed_limit * abs(player.velocity.x)/player.velocity.x
		if abs(player.velocity.y) > speed_limit: player.velocity.y = speed_limit * abs(player.velocity.y)/player.velocity.y
		
		create_line(player.position)
	else:
		line.clear_points()

func _cam(delta : float) -> void:
	if player.velocity.y > 1000: cam_wobble = Vector2((player.velocity.y-1000)*0.003 * sin(Global.timer/4), (player.velocity.y-1000)*0.003 * sin(Global.timer/(3.1415)))
	var cam_interpolation : float = pow(0.1*(1+(pow(abs(player.velocity.y), 1.2)*0.001)), 1 / delta / 60)
	var player_velocity_limit : float = player.velocity.y
	player_velocity_limit /= 1+(player_velocity_limit*0.0003)
	player_velocity_limit = player_velocity_limit*0.1 + player.position.y + (get_viewport().get_mouse_position().y-(get_viewport().size.y/2))*0.2
	if cam_interpolation < 1: old_cam.y += (player_velocity_limit - old_cam.y) * cam_interpolation
	else: old_cam.y = player_velocity_limit
	cam.position = old_cam
	cam.position += cam_wobble

func _raycast() -> void:
	raycast_wall.target_position = global_mouse_pos - raycast_wall.global_position
	var dis_raycast_target = raycast_wall.global_position.distance_to(global_mouse_pos)
	if dis_raycast_target > player_range:
		raycast_wall.target_position = raycast_wall.global_position.direction_to(global_mouse_pos) * player_range
		
	raycast_silky.position = raycast_wall.target_position
	raycast_silky.target_position = player.global_position - raycast_silky.global_position
	raycast_point.position = raycast_wall.target_position
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if raycast_wall.is_colliding() or raycast_silky.is_colliding():
			if str(raycast_wall.get_collider()).containsn("solid"): 
				Global.string_target = raycast_wall.get_collision_point()
				Global.is_swinging = true
				
			elif player.cast_entered: 
				Global.string_target = raycast_silky.get_collision_point()
				Global.is_swinging = true
