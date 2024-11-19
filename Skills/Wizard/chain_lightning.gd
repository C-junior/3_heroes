# chain_lightning.gd
extends Skill

@export var base_damage: int = 183       # Starting damage for the initial target
@export var jump_count: int = 3               # Number of additional enemies to hit
@export var damage_reduction: float = 0.8     # Damage reduction per jump
@export var jump_radius: float = 300.0        # Radius within which to find the next target
@export var chain_lightning_effect: PackedScene = preload("res://Skills/Wizard/chain_lightning_effect.tscn")

var cooldown_timer: Timer = null

func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_on_cooldown_ready)

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown
	
	var initial_target = character.find_nearest_target("Enemies")
	if initial_target:
		_trigger_chain_lightning(character, initial_target)
		cooldown_timer.start()

func _trigger_chain_lightning(character: BaseCharacter, initial_target: Node2D) -> void:
	var current_target = initial_target
	var current_damage = base_damage

	for i in range(jump_count + 1):  # Include initial hit
		if current_target and current_target.has_method("take_damage"):
			# Apply damage to the current target
			current_target.take_damage(current_damage)

			# Create and display the lightning effect
			var effect = chain_lightning_effect.instantiate() as Node2D
			effect.start_position = character.global_position if i == 0 else current_target.global_position  # Start from character or last target
			effect.end_position = current_target.global_position
			character.get_parent().add_child(effect)

			# Reduce damage for the next jump
			current_damage *= damage_reduction

			# Find the next closest target within jump_radius
			current_target = _find_next_target(current_target)
			if current_target == null:
				character.get_parent().remove_child(effect)
				break

func _find_next_target(previous_target: Node2D) -> Node2D:
	var closest_enemy: Node2D = null
	var closest_distance = jump_radius

	var enemies = previous_target.get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy != previous_target:
			var distance = previous_target.global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_enemy = enemy
				closest_distance = distance

	return closest_enemy

func _on_cooldown_ready():
	print("Chain Lightning is ready again!")
