# resurrection.gd
extends Skill

@export var health_restore_percentage: float = 50.0  # Restore 50% health upon resurrection

var cooldown_timer: Timer = null

# Initialize the cooldown timer
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

# Apply the resurrection effect
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_resurrection(character)
	cooldown_timer.start()

# Check for a dead ally and resurrect them
func _trigger_resurrection(character: BaseCharacter) -> void:
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	var resurrected = false

	for ally in allies:
		if ally.is_dead and ally.has_method("resurrect"):
			ally.resurrect()  # Call the resurrect function on the dead ally
			resurrected = true
			print(ally.name, "has been resurrected.")
			break  # Only resurrect one ally at a time

	if not resurrected:
		print("No dead allies to resurrect.")

# Cooldown is ready
func _on_cooldown_ready():
	print("Resurrection is ready again!")
