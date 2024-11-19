# holy_hands.gd
extends Skill

@export var extra_damage: int = 21
@export var attack_count: int = 3

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

	_trigger_holy_hands(character)
	cooldown_timer.start()

func _trigger_holy_hands(character: BaseCharacter) -> void:
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	var valid_allies = []
	
	# Collect allies excluding the cleric
	for ally in allies:
		if ally != character:  # Exclude the cleric
			valid_allies.append(ally)
	if valid_allies.size() > 0:
		var selected_ally = valid_allies[randi() % valid_allies.size()]  # Randomly select an ally
		selected_ally.attack_damage += extra_damage
		print("Holy Hands applied to: ", selected_ally.name)

func _on_cooldown_ready():
	print("Holy Hands is ready again!")
