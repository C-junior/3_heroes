extends Node2D

@export var start_position: Vector2
@export var end_position: Vector2
@export var lifetime: float = 0.2  # Duration for the lightning effect to stay on screen

@onready var line = $Line2D

func _ready():
	# Set up the lightning line to connect start and end points
	line.clear_points()
	line.add_point(start_position)
	line.add_point(end_position)

	# Start a timer to remove the entire effect after its lifetime
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime
	add_child(timer)
	timer.timeout.connect(self.queue_free)  # Remove entire effect node when timer expires
	timer.start()  # Start the timer right away
	
	# Add random jaggedness for a lightning effect
	_add_lightning_jaggedness()

func _add_lightning_jaggedness():
	var mid_point = (start_position + end_position) / 2.1
	mid_point += Vector2(randf_range(-3, 3), randf_range(-3, 3))  # Adds offset for jagged look
	var mid_point2 = (start_position + end_position) / 2.5
	mid_point2 += Vector2(randf_range(-5, 5), randf_range(-5, 5))  # Adds offset for jagged look
	line.clear_points()
	line.add_point(start_position)
	line.add_point(mid_point)
	line.add_point(mid_point2)
	line.add_point(end_position)
