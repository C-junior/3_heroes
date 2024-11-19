# mass_heal.gd
extends Skill

@export var heal_percentage: float = 0.2  # Heal 20% of max health

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

	_trigger_mass_heal(character)
	cooldown_timer.start()

func _trigger_mass_heal(character: BaseCharacter) -> void:
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	for ally in allies:
		var heal_amount = ally.get_max_health() * heal_percentage
		ally.receive_heal(heal_amount)
		print("Mass Heal healed", ally.name, "for", heal_amount)

func _on_cooldown_ready():
	print("Mass Heal is ready again!")
