extends Skill

@export var heal_percentage: float = 0.15  # Heals 15% of max health
#@export var cooldown_time: float = 5.0  # Cooldown duration
@export var cleanse_effects: Array = ["poison", "slow"]  # Effects that can be removed

var cooldown_timer: Timer = null

# Initialize the cooldown timer
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

# Apply the healing and cleansing effect to all allies
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_purifying_wave(character)
	cooldown_timer.start()

# Healing and cleansing for all allies
func _trigger_purifying_wave(character: BaseCharacter) -> void:
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	print("Purifying Wave applied to", allies)
	for ally in allies:
		# Heal the ally by a percentage of their max health
		var heal_amount = ally.max_health * heal_percentage
		ally.receive_heal(heal_amount)
		print("Purifying Wave applied to", ally.name, " and ", heal_amount)
		# Cleanse debuffs
		for effect in cleanse_effects:
			if ally.has_method("remove_status_effect"):
				ally.remove_status_effect(effect)
		print("Purifying Wave applied to", ally.name)

# Cooldown is ready
func _on_cooldown_ready() -> void:
	print("Purifying Wave is ready again!")
