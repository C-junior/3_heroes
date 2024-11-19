# arcane_shield.gd
extends Skill

@export var shield_duration: float = 5.0  # Shield lasts for 5 seconds
@export var defense_increase: int = 30  # Boost defense temporarily

var cooldown_timer: Timer = null
var shield_timer: Timer = null  # Timer for the duration of the shield

func init(character: BaseCharacter) -> void:
	# Setup cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

	# Setup shield duration timer
	shield_timer = Timer.new()
	shield_timer.one_shot = true
	shield_timer.wait_time = shield_duration
	character.add_child(shield_timer)
	shield_timer.connect("timeout", Callable(self, "_on_shield_end"))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown
	_trigger_arcane_shield(character)
	cooldown_timer.start()

# Trigger Arcane Shield effect
func _trigger_arcane_shield(character: BaseCharacter) -> void:
	character.defense += defense_increase
	character.sprite.modulate = Color(0, 0, 1)  # Change color to blue
	shield_timer.start()  # Start the shield duration timer

# End the shield after duration
func _on_shield_end():
	character.defense -= defense_increase  # Revert defense after duration
	character.sprite.modulate = Color(1, 1, 1)  # Restore original color

func _on_cooldown_ready():
	print("Arcane Shield is ready again!")
