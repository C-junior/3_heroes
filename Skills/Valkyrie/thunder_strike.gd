extends Skill

@export var lightning_damage: int = 100
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

	_trigger_thunder_strike(character)
	cooldown_timer.start()

# Deal lightning damage to a random enemy
func _trigger_thunder_strike(character: BaseCharacter) -> void:
	var enemies = character.get_tree().get_nodes_in_group("Enemies")
	if enemies.size() > 0:
		var random_enemy = enemies[randi() % enemies.size()]
		if random_enemy.has_method("take_damage"):
			random_enemy.take_damage(lightning_damage)
			print("Thunder Strike hit:", random_enemy.name)

func _on_cooldown_ready():
	print("Thunder Strike is ready again!")
