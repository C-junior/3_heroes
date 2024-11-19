# taunt.gd
extends Skill

@export var taunt_duration: float = 5.0  # Duration enemies are forced to attack the knight
@export var taunt_radius: float = 300.0  # Radius around the knight for taunt effect

var cooldown_timer: Timer = null

# Initialize the skill and its cooldown timer
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

# Apply the taunt effect to nearby enemies
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_taunt(character)
	cooldown_timer.start()

# Force enemies within the radius to attack the knight
func _trigger_taunt(character: BaseCharacter) -> void:
	var enemies = character.get_tree().get_nodes_in_group("Enemies")
	
	# Find enemies within the taunt radius
	for enemy in enemies:
		var distance = character.global_position.distance_to(enemy.global_position)
		if distance <= taunt_radius:
			if enemy.has_method("force_attack"):
				enemy.force_attack(character, taunt_duration)
				print("Taunted enemy:", enemy.name)

func _on_cooldown_ready() -> void:
	print("Taunt is ready again!")
