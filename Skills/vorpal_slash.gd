# vorpal_slash.gd
extends Skill  # Make sure Vorpal Slash extends the base Skill class

@export var damage_percentage: float = 5.0  # 80% of attack damage
@export var skill_range: int = 250
var cooldown_timer: Timer = null

# Initialize the cooldown timer within the character
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_vorpal_slash_ready"))

# Override apply_effect for the Vorpal Slash
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is still in cooldown
	_trigger_vorpal_slash(character)
	cooldown_timer.start()  # Start cooldown

# Trigger the Vorpal Slash attack
func _trigger_vorpal_slash(character: BaseCharacter) -> void:
	var enemies = character.get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		var distance = character.global_position.distance_to(enemy.global_position)
		if distance <= character.attack_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(character.attack_damage * damage_percentage)
				print("Vorpal Slash hit enemy:", enemy.name)

# Cooldown is over, skill is ready again
func _on_vorpal_slash_ready():
	print("Vorpal Slash is ready again!")
