extends Area2D

@export var speed: float = 500.0  # Speed of the fireball
@export var damage: int = 0  # This will be set based on the Wizard's attack damage

@onready var sprite = $AnimatedSprite2D  # Reference to the sprite

var direction: Vector2  # Direction to move the fireball

# Set the direction for the projectile
func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

# Set the damage for the projectile
func set_damage(new_damage: int):
	damage = new_damage

func _ready():
	set_physics_process(true)
	connect("body_entered", Callable(self, "_on_body_entered"))  # Detect when it hits an enemy

func _physics_process(delta: float):
	# Move the fireball in the given direction
	position += direction * speed * delta

	# Optional: Remove fireball if it goes offscreen (to save memory)
	if position.x > 600 or position.x < -600:
		queue_free()

# When the fireball hits something
func _on_body_entered(body):
	if body.is_in_group("Enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		 # Destroy the fireball after it hits
