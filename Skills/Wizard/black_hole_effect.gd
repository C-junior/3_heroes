# black_hole_effect.gd
extends Area2D

@export var damage_per_second: int = 50
@export var effect_radius: float = 400.0
@export var duration: float = 5.0  # Total duration of the black hole effect

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var effect_timer: Timer = $Timer  # Timer to control the lifetime of the effect
@onready var damage_timer: Timer = Timer.new()  # Timer for damage ticks

func _ready():
	# Set up the collision shape and start the lifetime timer
	$CollisionShape2D.shape.radius = effect_radius
	effect_timer.wait_time = duration
	effect_timer.one_shot = true
	effect_timer.timeout.connect(Callable(self, "_end_black_hole"))
	effect_timer.start()
	
	# Initialize and start the damage timer for 1-second intervals
	damage_timer.wait_time = 1.0
	damage_timer.one_shot = false
	damage_timer.timeout.connect(Callable(self, "_apply_damage_tick"))
	add_child(damage_timer)
	damage_timer.start()

	# Start the black hole animation
	sprite.rotation = 360

func _apply_damage_tick():
	# Apply damage to all enemies within the effect radius every second
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) <= effect_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage_per_second)
				print("Black Hole dealt", damage_per_second, "damage to", enemy.name)

func _process(delta):
	sprite.rotation += 0.2  # Rotate by 1 degree per frame
	# Continuously apply attraction to enemies within the radius
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) <= effect_radius:
			_attract_enemy(enemy, delta)

func _attract_enemy(enemy: Node2D, delta: float):
	# Pull the enemy towards the black hole center
	var attraction_force = (global_position - enemy.global_position).normalized() * 200 * delta
	enemy.position += attraction_force

func _end_black_hole():
	sprite.stop()
	damage_timer.stop()
	queue_free()
