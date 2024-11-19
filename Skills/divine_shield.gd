# divine_shield.gd
extends Skill

@export var shield_duration: float = 3.0  # Duration of immunity in seconds

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

	_trigger_divine_shield(character)
	cooldown_timer.start()

func _trigger_divine_shield(character: BaseCharacter) -> void:
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	var lowest_health_ally: Node2D = null
	var lowest_health: int = 60000  # Use MAX_VALUE for comparison

	# Find ally with the lowest health
	for ally in allies:
		# Skip the character using the skill (e.g., cleric) if necessary
		if ally != character and ally.get_health() < lowest_health:
			lowest_health_ally = ally
			lowest_health = ally.get_health()
			print("Checking ally:", ally.name, " Health:", lowest_health)

	if lowest_health_ally:
		lowest_health_ally.set_invincible(shield_duration)
		print("Divine Shield applied to:", lowest_health_ally.name)

func _on_cooldown_ready():
	print("Divine Shield is ready again!")
