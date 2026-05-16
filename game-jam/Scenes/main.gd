extends Node2D
var line: Line2D

@onready var player := $Player
@onready var cam := $Cam
@onready var raycast := $RayCast
@export var string_amount : float = 40 #Use Even Number
@export var stretchiness : float = 400
@export var x_stretch : float = 0.75  #it's better to be between 0-1, it streches more based on the x axis
@export var vel_y_pitfall : float = 125 #Prevent infinite velocity at the absolute value of the velocity
@export var vel_y_air_resist : float = 0.98 #to get the value
@export var speed_limit: float = 10000
@export var string_power: float = 1.5

var last_raycast_point : Vector2 = Vector2(0,0)
var global_mouse_pos : Vector2
var strecth_amount : float = 0
#var mouse_point : Vector2
var distance : float

func _ready() -> void:
	line = Line2D.new()
	add_child(line)
	
	line.width = 4.5
	line.default_color = Color(1, 1, 1, 0.5)
	line.antialiased = true

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
		##var strecth_amount : float = pow(((string_amount/2)-abs(i-(string_amount/2)))*500, 0.5) * sin((((string_amount/2)-abs(i-(string_amount/2)))/string_amount)*3.14)
		strecth_amount = sin((i/string_amount)*3.14) * stretchiness *(pow(abs(player_pos.x-Global.string_target.x), x_stretch)/100) * 1/(((pow(distance, 2)*0.0001))+1) #1/((pow(abs(player.velocity.x), 0.3)*0.1)+1)
		line_coords = Vector2(line.get_point_position(i).x, line.get_point_position(i).y+strecth_amount) #+ cos(i/(3.14/2))*2.5)
		line.set_point_position(i, line_coords)
		
	line.add_point(Global.string_target)
	
func _process(delta: float) -> void:
	global_mouse_pos = get_global_mouse_position()
	
	if Global.is_swinging:
		var dir_vel = player.position.direction_to(Global.string_target)
		
		distance = pow(distance, 2)
		
		player.velocity += Vector2(dir_vel.x * distance/50, dir_vel.y * distance/50) * delta * string_power
		if abs(player.velocity.y) > vel_y_pitfall: player.velocity.y *= vel_y_air_resist / delta * delta #Patched infinite energy
		
		if abs(player.velocity.x) > speed_limit: player.velocity.x = speed_limit * abs(player.velocity.x)/player.velocity.x
		if abs(player.velocity.y) > speed_limit: player.velocity.y = speed_limit * abs(player.velocity.y)/player.velocity.y
		
		create_line(player.position)
		
		#print(angle)
		#print(player.velocity)
	else:
		line.clear_points()
	
	var cam_interpolation : float = 0.1*(1+(pow(abs(player.velocity.y), 1.2)*0.001))
	var player_velocity_limit : float = player.velocity.y
	player_velocity_limit /= 1+(player_velocity_limit*0.0003)
	player_velocity_limit = player_velocity_limit*0.1 + player.position.y + (get_viewport().get_mouse_position().y-(get_viewport().size.y/2))*0.2
	if cam_interpolation < 1: cam.position.y += (player_velocity_limit - cam.position.y) * cam_interpolation / delta * delta
	else: cam.position.y = player_velocity_limit

	raycast.global_position = player.global_position
	raycast.target_position = global_mouse_pos - player.global_position
	#print(raycast.get_collision_point())
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if raycast.is_colliding(): 
			Global.string_target = raycast.get_collision_point()
			Global.is_swinging = true
		elif $Silky_wall.mouse_entered: 
			Global.string_target = global_mouse_pos
			Global.is_swinging = true
	
		
		
