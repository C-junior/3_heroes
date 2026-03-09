# enemy.gd
extends BaseCharacter

@export var enemy_name: String = "Goblin"
@export var enemy_attack_damage: int = 28
@export var enemy_move_speed: int = 40
@export var goblin_max_health: int = 100
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var knockback_velocity: Vector2 = Vector2.ZERO  # Store the knockback force
var knockback_reduction_rate: float = 200  # Knockback reduction rate
var is_slowed: bool = false
var original_speed: int
var taunt_timer: Timer = null  # Timer to manage taunt duration
var taunt_target: Node2D = null

func _ready():
	base_attack_damage = enemy_attack_damage
	base_move_speed = enemy_move_speed
	base_max_health = goblin_max_health
	base_attack_cooldown = attack_cooldown
	super._ready()
	current_health = max_health
	original_speed = move_speed
	add_to_group("Enemies")

	# Initialize taunt timer
	taunt_timer = Timer.new()
	taunt_timer.one_shot = true
	add_child(taunt_timer)
	taunt_timer.connect("timeout", Callable(self, "_on_taunt_end"))

func apply_wave_scaling(multiplier: float) -> void:
	base_max_health = int(round(base_max_health * multiplier))
	base_attack_damage = int(round(base_attack_damage * multiplier))
	base_defense = int(round(max(1.0, base_defense * (1.0 + (multiplier - 1.0) * 0.5))))
	base_move_speed = int(round(base_move_speed * (1.0 + (multiplier - 1.0) * 0.15)))
	update_stats()
	current_health = max_health
	original_speed = move_speed
	xp_reward = int(round(xp_reward * (1.0 + (multiplier - 1.0) * 0.5)))
	min_gold_reward = int(round(min_gold_reward * multiplier))
	max_gold_reward = int(round(max_gold_reward * multiplier))

# Move towards and attack the target
func move_and_attack(target_node: Node2D, delta: float) -> void:
	if is_stunned:
		return
	
	var direction = (target_node.global_position - global_position).normalized()
	
	if global_position.distance_to(target_node.global_position) > attack_range:
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if attack_timer.is_stopped():
			attack(target_node)


# Override to skip dead heroes
func find_nearest_alive_target(group_name: String) -> Node2D:
	var nearest_node: Node2D = null
	var shortest_distance = INF
	for node in get_tree().get_nodes_in_group(group_name):
		if node is BaseCharacter and node.is_dead:
			continue
		var distance = global_position.distance_to(node.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_node = node
	return nearest_node

func _process(delta: float):
	if taunt_target and is_instance_valid(taunt_target) and (not taunt_target is BaseCharacter or not taunt_target.is_dead):
		target = taunt_target
	else:
		target = find_nearest_alive_target("PlayerCharacters")
	if target:
		move_and_attack(target, delta)
	else:
		velocity = Vector2.ZERO

	# Apply knockback if there is any force left
	if knockback_velocity.length() > 0:
		# Set the velocity and call move_and_slide
		velocity = knockback_velocity
		move_and_slide()  # Call move_and_slide without arguments
		
		# Gradually reduce the knockback velocity over time (friction)
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_reduction_rate * delta)

# Apply knockback force to the enemy
func knockback(force: Vector2) -> void:
	knockback_velocity = force  # Apply the force as velocity
	print("Enemy knocked back with force:", force)

# Method to slow the enemy
func slow(duration: float):
	if not is_slowed:
		is_slowed = true
		move_speed /= 2  # Halve the movement speed
		print("Enemy slowed:", move_speed)
		sprite.modulate = Color(0, 0, 1)

		# Create and start a timer
		var timer = Timer.new()
		timer.wait_time = duration
		timer.one_shot = true
		add_child(timer)  # Add Timer as a child to the enemy
		timer.start()

		# Wait for the timer to finish
		await timer.timeout

		restore_speed()  # Restore speed after duration
		timer.queue_free()  # Free the timer after use

# Restore the original speed
func restore_speed():
	move_speed = original_speed
	print("Enemy restored to original speed:", move_speed)
	sprite.modulate = Color(1, 1, 1)
	is_slowed = false

func force_attack(forced_target: Node2D, duration: float) -> void:
	taunt_target = forced_target
	taunt_timer.wait_time = duration
	taunt_timer.start()

func _on_taunt_end() -> void:
	taunt_target = null


@export var xp_reward: int = 100
@export var min_gold_reward: int = 10  # Minimum gold to drop
@export var max_gold_reward: int = 20  # Maximum gold to drop

# Override the die function to reward XP and random gold
func die():
	var party_members = get_tree().get_nodes_in_group("PlayerCharacters")
	var random_gold_reward = randi() % (max_gold_reward - min_gold_reward + 1) + min_gold_reward
	global.add_currency(random_gold_reward)
	for player in party_members:
		if player.level_system:
			player.level_system.add_xp(xp_reward)

	queue_free()
