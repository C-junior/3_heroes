extends Skill

@export var massive_damage: int = 200
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

	_trigger_ragnarok(character)
	cooldown_timer.start()

# Deal massive damage to all enemies
func _trigger_ragnarok(character: BaseCharacter) -> void:
	var enemies = character.get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(massive_damage)
			print("Ragnarök dealt", massive_damage, "damage to", enemy.name)

func _on_cooldown_ready():
	print("Ragnarök is ready again!")
