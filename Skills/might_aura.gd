# might_aura.gd
extends Skill

@export var debuff_amount: int = 10  # Reduce attack and defense by 10%
@export var aura_duration: float = 5.0  # Duration of the debuff effect in seconds

var cooldown_timer: Timer = null

func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_might_aura(character)
	cooldown_timer.start()

# Apply debuffs to enemies and start a timer to reset their stats later
func _trigger_might_aura(character: BaseCharacter) -> void:
	var enemies = character.get_tree().get_nodes_in_group("Enemies")
	
	for enemy in enemies:
		# Reduce enemy attack and defense by debuff_amount%
		enemy.attack_damage -= (enemy.attack_damage * debuff_amount / 100)
		enemy.defense -= (enemy.defense * debuff_amount / 100)
		print("Might Aura applied to", enemy.name, " ", enemy.attack_damage, " ", enemy.defense)

		# Create a timer to reset the debuff after the aura_duration
		var reset_timer = Timer.new()
		reset_timer.one_shot = true
		reset_timer.wait_time = aura_duration
		character.add_child(reset_timer)
		reset_timer.connect("timeout", Callable(self, "_reset_enemy_stats").bind(enemy))
		reset_timer.start()

func _reset_enemy_stats(enemy: Node) -> void:
	# Restore the enemy's original attack and defense
	enemy.attack_damage += (enemy.attack_damage * debuff_amount / 100)
	enemy.defense += (enemy.defense * debuff_amount / 100)
	print("Might Aura debuff removed from", enemy.name, " ", enemy.attack_damage, " ", enemy.defense)

func _on_cooldown_ready():
	print("Might Aura is ready again!")
