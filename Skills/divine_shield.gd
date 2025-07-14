# divine_shield.gd
extends Skill

@export var shield_duration: float = 3.0  # Duration of immunity in seconds
@export var divine_shield_effect_scene: PackedScene = preload("res://Skills/Cleric/divine_shield_effect.tscn")  # Visual effect

var cooldown_timer: Timer = null

# Initialize the cooldown timer
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

# Apply the Divine Shield effect
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_divine_shield(character)
	cooldown_timer.start()

# Find the lowest health ally and apply the shield
func _trigger_divine_shield(character: BaseCharacter) -> void:
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	var lowest_health_ally: Node2D = null
	var lowest_health: int = 60000

	# Find the ally with the lowest health
	for ally in allies:
		if ally != character and ally.get_health() < lowest_health:
			lowest_health_ally = ally
			lowest_health = ally.get_health()

	# Apply the shield to the lowest health ally
	if lowest_health_ally:
		print("Divine Shield applied to:", lowest_health_ally.name)
		_apply_shield_effect(lowest_health_ally)

# Apply immunity and attach the visual effect
func _apply_shield_effect(ally: BaseCharacter) -> void:
	# Set ally to invincible
	ally.set_invincible(shield_duration)

	# Add the visual effect to the ally
	var shield_effect = divine_shield_effect_scene.instantiate() as Node2D
	shield_effect.position = Vector2.ZERO
	ally.add_child(shield_effect)

func _on_cooldown_ready():
	print("Divine Shield is ready again!")
