# meteor.gd
extends Area2D

@export var damage: int = 300           # Damage dealt by the meteor
@export var impact_radius: float = 150.0  # Radius of the meteor's impact
@export var fall_speed: float = 600.0     # Speed of the meteor falling downwards

@onready var timer: Timer = $Timer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var target_position: Vector2  # The final impact position

func _ready():
	# Set collision radius to match impact area
	$CollisionShape2D.shape.radius = impact_radius
	sprite.play("fall")  # Play fall animation

	# Start the timer to trigger the impact and then remove the meteor
	timer.wait_time = 1
	timer.one_shot = true
	timer.timeout.connect(_on_impact)
	timer.start()

func _process(delta):
	# Move the meteor downwards toward the target position
	if global_position.y < target_position.y:
		global_position.y += fall_speed * delta

		# Check if the meteor has reached the target position or overshot
		if global_position.y >= target_position.y:
			_on_impact()  # Trigger the impact effect
	else:
		_on_impact()  # Trigger the impact immediately if already at target

# Trigger impact damage when the meteor animation finishes
func _on_impact():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
			print("Meteor Strike damaged:", body.name)
	
	queue_free()  # Remove the meteor after impact
