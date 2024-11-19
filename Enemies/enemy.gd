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

func _ready():
	attack_damage = enemy_attack_damage
	move_speed = enemy_move_speed
	original_speed = enemy_move_speed
	current_health = goblin_max_health
	health_progress_bar.max_value = goblin_max_health  # Set max value for the progress bar
	health_progress_bar.value = current_health  # Initialize progress bar value
	add_to_group("Enemies")

	# Initialize taunt timer
	taunt_timer = Timer.new()
	taunt_timer.one_shot = true
	add_child(taunt_timer)
	taunt_timer.connect("timeout", Callable(self, "_on_taunt_end"))

func _process(delta: float):
	# If taunt is active, attack the knight
	if target and taunt_timer and taunt_timer.time_left > 0:
		move_and_attack(target, delta)
	else:
		# Find nearest player character to attack if not taunted
		target = find_nearest_target("PlayerCharacters")
		if target:
			move_and_attack(target, delta)

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

# Force the enemy to attack the taunting knight
func force_attack(taunting_character: BaseCharacter, duration: float) -> void:
	# Set the knight as the new target
	target = taunting_character
	taunt_timer.start(duration)  # Start the taunt timer to ensure the target stays the same
	print("Forced to attack knight:", target.name)

# Called when the taunt duration ends
func _on_taunt_end() -> void:
	target = null  # Reset the target after taunt ends

@export var xp_reward: int = 100
@export var min_gold_reward: int = 10  # Minimum gold to drop
@export var max_gold_reward: int = 20  # Maximum gold to drop

# Override the die function to reward XP and random gold
func die():
	# Grant XP and random gold to all player characters
	var party_manager = get_tree().root.get_node("MainGame/PlayerCharacters")
	
	# Calculate random gold reward
	var random_gold_reward = randi() % (max_gold_reward - min_gold_reward + 1) + min_gold_reward

	for player in party_manager.get_children():
		if player.has_method("add_xp_to_party"):
			player.add_xp_to_party(xp_reward)
			player.add_gold(random_gold_reward)
			print(random_gold_reward," receberam")

	queue_free()
