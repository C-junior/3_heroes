extends Area2D

@export var speed: float = 600.0 # Speed of the spear
@export var damage: int = 0 # Damage dealt by the spear

var target: Node2D = null # Target enemy



func setup(target_node: Node2D, damage_value: int) -> void:
	target = target_node
	damage = damage_value
	 # Point the spear towards the target initially
	if target:
		look_at(target.global_position)


func _process(delta: float) -> void:
	if target and target.is_inside_tree():
		var direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta
		 # Point the spear towards the target while moving
		look_at(target.global_position)

	# Check if we reached close to the target
	if position.distance_to(target.global_position) < 10:
		_hit_target()
		
func _hit_target() -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage)
	queue_free() # Destroy spear after impact
