extends Node

var string_target: Vector2
var is_swinging: bool = false
var timer: float = 0
var health: float = 100
var cur_level: int = 0
var unlocked_level: int = 0

func _process(delta: float) -> void:
	timer += 100 * delta
	
	if Global.health > 100:
		Global.health = 100

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_swinging:
		await get_tree().create_timer(0.01).timeout
		is_swinging = false

func _loadlevel(index: int):
	get_tree().call_group('load_level', '_loadlevel', index)
	
func _nextlevel():
	if cur_level == unlocked_level: unlocked_level += 1
	cur_level += 1
	_reset()

func _reset():
	health = 100
	is_swinging = false
	get_tree().reload_current_scene()
	#await get_tree().create_timer(0.01).timeout
	#_loadlevel(cur_level)
	
	
	
