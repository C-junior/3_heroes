# magic_bolt.gd
extends Area2D

@export var speed: float = 500.0  # Speed of the projectile
@onready var sprite = $AnimatedSprite2D  # The sprite for the projectile

var direction: Vector2
var damage: int = 0  # Will be set based on wizard's attack damage

func _ready():
	set_physics_process(true)
	connect("body_entered", Callable(self, "_on_body_entered"))

# Set the direction for the projectile
func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

# Set the damage based on the wizard's attack damage
func set_damage(new_damage: int):
	damage = new_damage

func _physics_process(delta: float):
	position += direction * speed * delta
	if position.x > 2000 or position.x < -2000:
		queue_free()  # Free the projectile if it moves out of bounds

# When the projectile hits an enemy
func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()  # Destroy the projectile after hitting
