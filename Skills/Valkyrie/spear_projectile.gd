extends Area2D

@export var speed: float = 600.0  # Speed of the spear
@export var damage: int = 0  # Damage dealt by the spear

var target: Node2D = null  # Target enemy

func setup(target_node: Node2D, damage_value: int) -> void:
	target = target_node
	damage = damage_value
	
	# Point the spear towards the target initially
	if is_instance_valid(target):  # Check if the target is valid
		look_at(target.global_position)

func _process(delta: float) -> void:
	if is_instance_valid(target):  # Ensure the target still exists
		var direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta
		
		# Point the spear towards the target while moving
		look_at(target.global_position)

		# Check if we reached close to the target
		if position.distance_to(target.global_position) < 10:
			_hit_target()
	else:
		# If the target no longer exists, destroy the spear
		queue_free()

func _hit_target() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):  # Ensure target is valid before dealing damage
		target.take_damage(damage)
	queue_free()  # Destroy spear after impact
