# valhallas_call.gd
extends Skill

@export var attack_cooldown_reduction: float = 0.8  # Reduce attack cooldown by 0.5 seconds
@export var movement_speed_boost: float = 0.3  # 30% movement speed increase
@export var lifesteal_percentage: float = 0.15  # 15% lifesteal
@export var duration: float = 5.0  # Effect lasts for 5 seconds
@export var health_threshold: float = 0.9  # Trigger when health drops below 20%

var cooldown_timer: Timer = null
var effect_timer: Timer = null
var active_character: BaseCharacter = null  # Store reference to the character using the skill

# Initialize the skill within the Valkyrie character
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready").bind(character))

	effect_timer = Timer.new()
	effect_timer.one_shot = true
	effect_timer.wait_time = duration
	character.add_child(effect_timer)
	effect_timer.connect("timeout", Callable(self, "_on_effect_end").bind(character))

	print(character.name, "has learned Valhalla's Call.")
	active_character = character  # Store the reference to the character

# Apply the effect when the Valkyrie's health drops below the threshold
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	if character.current_health / character.max_health <= health_threshold:
		_trigger_valhallas_call(character)
		cooldown_timer.start()

# Trigger Valhalla's Call to boost stats and reduce attack cooldown
func _trigger_valhallas_call(character: BaseCharacter) -> void:
	character.attack_cooldown = max(0.2, character.attack_cooldown - attack_cooldown_reduction)  # Reduce attack cooldown but ensure it's above 0.5 sec
	character.move_speed += movement_speed_boost
	character.lifesteal_percentage = lifesteal_percentage  # Assign lifesteal during Valhalla's Call
	effect_timer.start()

	print(character.name, "activated Valhalla's Call! Attack cooldown reduced, move speed boosted, and lifesteal active.")

# End the effect after the duration
func _on_effect_end(character: BaseCharacter) -> void:
	character.attack_cooldown += attack_cooldown_reduction  # Restore attack cooldown
	character.move_speed -= movement_speed_boost
	character.lifesteal_percentage = 0  # Reset lifesteal
	print("Valhalla's Call effect ended for", character.name)

# Cooldown is over, skill can be triggered again
func _on_cooldown_ready(character: BaseCharacter):
	print("Valhalla's Call is ready again for", character.name)
