extends Node2D
var line: Line2D

@onready var player := $Player

func _ready() -> void:
	line = Line2D.new()
	add_child(line)
	
	line.width = 4
	line.default_color = Color(1, 1, 1, 0.5) # Red line
	line.antialiased = true

	# Add initial points
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		line.clear_points()
		line.add_point(player.position)
		line.add_point(get_viewport().get_mouse_position())
	
