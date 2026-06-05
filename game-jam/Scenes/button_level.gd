extends Button

@export var level_id: int
var mouse_enter : bool = false
var speed_scale : float = 0
var target_scale : float = 1
@onready var random_value : float = randf_range(0, 10000) 

func _ready() -> void:
	text = str(level_id)
	
func _process(delta: float) -> void:
	if mouse_enter:
		target_scale = 1.15 + sin((Global.timer+random_value)/24)*0.02
	else: 
		target_scale = 1 + sin((Global.timer+random_value)/24)*0.02
	
	rotation_degrees += ((0+speed_scale*300) - rotation_degrees) * 0.5 * 60 * delta
	speed_scale = (((target_scale-scale.x) * 0.2) + (speed_scale * 0.6))
	scale += Vector2(speed_scale, speed_scale) * 60 * delta
	
func _on_mouse_entered() -> void:
	mouse_enter = true

func _on_mouse_exited() -> void:
	mouse_enter = false

func _on_button_down() -> void:
	await get_tree().create_timer(0.05).timeout
	Global.cur_level = level_id
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
