extends CharacterBody2D
class_name Player

@export var speed: float = 200

func _ready() -> void:
	position = Vector2(640, 360)
	
func _physics_process(delta: float) -> void:
	position.y += ((int(Input.is_action_pressed("up"))*-1) + (int(Input.is_action_pressed("down")))) * delta * speed
	position.x += ((int(Input.is_action_pressed("left"))*-1) + (int(Input.is_action_pressed("right")))) * delta * speed
