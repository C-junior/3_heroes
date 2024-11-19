extends Skill

@export var shield_amount: int = 200
@export var duration: float = 5.0
@export var arcane_shield_scene: PackedScene = preload("res://Skills/Wizard/arcane_shield_effect.tscn")
@export var radius: float = 500.0

var cooldown_timer: Timer = null
var shield_effect: Node2D = null
var current_shield_amount: int = 0

func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_on_cooldown_ready)

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	var ally_to_shield = _find_best_ally_to_shield(character)
	if ally_to_shield:
		_activate_shield(ally_to_shield)
		cooldown_timer.start()

func _activate_shield(character: BaseCharacter) -> void:
	current_shield_amount = shield_amount
	character.shield_active = true  # Indicate that the shield is active
	character.arcane_shield_skill = self  # Link this skill instance for damage absorption

	# Attach the shield visual effect
	shield_effect = arcane_shield_scene.instantiate() as Node2D
	shield_effect.position = Vector2.ZERO
	character.add_child(shield_effect)

	# Set a timer to remove the shield effect after the duration
	var duration_timer = Timer.new()
	duration_timer.one_shot = true
	duration_timer.wait_time = duration
	character.add_child(duration_timer)
	duration_timer.timeout.connect(Callable(self, "_deactivate_shield").bind(character, shield_effect))
	duration_timer.start()
	print("Arcane Shield activated with", shield_amount, "HP for", character.name)
# Identify the ally with the most nearby enemies
# Identify the ally with the most nearby enemies
func _find_best_ally_to_shield(character: BaseCharacter) -> BaseCharacter:
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	var max_enemies_nearby = 0
	var best_ally = null

	for ally in allies:
		var enemy_count = _count_enemies_near(ally)
		if enemy_count > max_enemies_nearby:
			max_enemies_nearby = enemy_count
			best_ally = ally
			print(best_ally)

	return best_ally

# Count the number of enemies within a specified radius of the ally
func _count_enemies_near(ally: BaseCharacter) -> int:
	var enemies = ally.get_tree().get_nodes_in_group("Enemies")
	var count = 0
	for enemy in enemies:
		if ally.global_position.distance_to(enemy.global_position) <= radius:
			count += 1
	return count


func absorb_damage(damage: int, character: BaseCharacter) -> int:
	print("Arcane Shield absorbing damage...")
	if current_shield_amount > 0:
		var absorbed = min(damage, current_shield_amount)
		current_shield_amount -= absorbed
		damage -= absorbed
		print("Arcane Shield absorbed", absorbed, "damage. Remaining shield:", current_shield_amount)

		if current_shield_amount <= 0:
			_deactivate_shield(character, shield_effect)  # Deactivate if shield is depleted
	return damage

func _deactivate_shield(character: BaseCharacter, shield_effect: Node2D) -> void:
	if is_instance_valid(shield_effect):
		shield_effect.queue_free()
	character.shield_active = false
	character.arcane_shield_skill = null  # Clear the shield skill reference
	current_shield_amount = 0
	print("Arcane Shield deactivated for", character.name)

func _on_cooldown_ready():
	print("Arcane Shield is ready again!")
