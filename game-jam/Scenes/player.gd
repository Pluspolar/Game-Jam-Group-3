extends CharacterBody2D
class_name Player

@export var speed: float = 200
@export var speed_limit: float = 10000

func _ready() -> void:
	position = Vector2(640, 360)
	
func _physics_process(delta: float) -> void:
	position.y += ((int(Input.is_action_pressed("up"))*-1) + (int(Input.is_action_pressed("down")))) * delta * speed
	position.x += ((int(Input.is_action_pressed("left"))*-1) + (int(Input.is_action_pressed("right")))) * delta * speed

	velocity.x *= 0.985 / delta * delta
	velocity.y += 1000 * delta
	position += velocity * delta

	if abs(velocity.x) > speed_limit: velocity.x = speed_limit * abs(velocity.x)/velocity.x
	if abs(velocity.y) > speed_limit: velocity.y = speed_limit * abs(velocity.y)/velocity.y
