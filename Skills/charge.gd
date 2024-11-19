# charge.gd
extends Skill

@export var knockback_force: float = 100.0  # Knockback force
@export var slow_duration: float = 3.0  # Duration of the slow effect
@export var charge_duration: float = 0.5  # Duration of the charge movement
@export var skill_popup_scene: PackedScene  # Scene for the skill popup

var cooldown_timer: Timer = null
var charge_active: bool = false
var charge_time_left: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO


# Initialize the charge skill within the knight
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_charge(character)
	cooldown_timer.start()

# Move the character forward and knockback enemies
func _trigger_charge(character: BaseCharacter) -> void:
	var enemies = character.get_tree().get_nodes_in_group("Enemies")
	var target_enemy: Node = null
	var max_distance: float = 0.0


	# Find the most distant enemy
	for enemy in enemies:
		var distance = character.global_position.distance_to(enemy.global_position)
		if distance > max_distance:
			max_distance = distance
			target_enemy = enemy

	if target_enemy:
		charge_direction = (target_enemy.global_position - character.global_position).normalized()
		charge_time_left = charge_duration
		charge_active = true
		character.sprite.modulate = Color(0, 1, 0)
		print("Charge activated, moving character.")

		# Knockback the most distant enemy
		if target_enemy.has_method("knockback"):
			target_enemy.knockback(charge_direction * knockback_force)
			print("Charged knockback to:", target_enemy.name)

		# Apply slow effect to the enemy
		if target_enemy.has_method("slow"):
			target_enemy.slow(slow_duration)  # Call the slow method

func _on_cooldown_ready() -> void:
	print("Charge is ready again!")

# Check if the charge is active and how much time is left for it
func update_charge(delta: float, character: BaseCharacter) -> void:
	if charge_active:
		if charge_time_left > 0:
			var move_step = knockback_force * delta / charge_duration
			character.position += charge_direction * move_step
			charge_time_left -= delta
		else:
			charge_active = false
			print("Charge completed.")
			character.sprite.modulate = Color(1, 1, 1)  # Reset color
